# Claude Code statusline에 Fable 모델 사용량 표시

작업일: 2026-08-11 · 문서 작성일: 2026-08-13 · 대상 버전: Claude Code 2.1.227 (macOS, Apple Silicon)

statusline에 Opus/Sonnet 등과 섞이지 않는 **Fable 모델 전용 사용량**을 별도 항목으로 붙인 작업 기록.

## 결과

```
synergylabs | Opus 5 (1M context) | Ctx: 5% | 5h:17%(→2h14m) 7d:13%(→3d23h) | Fable7d:97.7M
```

마지막 `Fable7d:` 항목이 이번에 추가된 부분이다. 최근 7일간 Fable 모델이 쓴 토큰 총합을 표시한다.

| 항목 | 값 |
|---|---|
| 표시 형식 | 토큰 절대값 (`97.7M`, `412k`, `999`) |
| 집계 범위 | 최근 7일 |
| 데이터 출처 | 로컬 트랜스크립트 `~/.claude/projects/**/*.jsonl` |
| 색상 | 초록 (`rgb(173,219,103)`) — 노란색 rate limit 항목과 구분 |
| Fable 사용량이 0이면 | 항목 자체를 숨김 |

---

## 왜 퍼센트(%)가 아닌 토큰 절대값인가

처음 목표는 기존 `5h:17%` / `7d:13%` 처럼 **퍼센트**로 붙이는 것이었다. 결론부터: **현재 로컬 환경에서는 불가능**하다. 근거를 순서대로 정리한다.

### 1. statusline 입력 JSON에 모델별 사용량이 없다

statusline 명령은 stdin으로 JSON을 받는다. 실제로 덤프해서 확인한 `rate_limits` 필드는 다음이 전부였다.

```json
"rate_limits": {
  "five_hour": { "used_percentage": 17, "resets_at": 1786449600 },
  "seven_day": { "used_percentage": 13, "resets_at": 1786784400 }
}
```

Claude Code 바이너리 내부 문자열에는 `seven_day_opus`, `seven_day_sonnet`, `seven_day_sonnetPF`, `seven_day_overage_included` 같은 **모델별 한도 키가 존재**한다. 하지만 statusline 스키마 문서(바이너리 내장)에는 `five_hour`와 `seven_day` 두 개만 노출된다고 명시돼 있다.

그리고 **Fable은 애초에 퍼센트 한도가 아니라 크레딧(credit) 기반**이다. 바이너리에서 확인된 식별자·문구:

- `fableCreditsRequired`, `isFableCreditsRequired`
- `fable_overage_consent_prompt`, `model_fable_consent`
- `"Buy more to keep using Fable 5, or switch models to keep working."`

즉 `seven_day_fable` 같은 퍼센트 필드는 존재하지 않는다.

### 2. `/usage` API는 있지만 로컬 토큰으로 인증이 안 된다

`/usage` 화면과 외부 도구(orca 등)가 읽는 엔드포인트는 확인됐다.

| 항목 | 값 |
|---|---|
| 엔드포인트 | `GET https://api.anthropic.com/api/oauth/usage` |
| 응답 필드 | `utilization`, `percent`, `resets_at`, `weekly_scoped`, `is_enabled` |

여기에 Fable 항목이 있다면 퍼센트 표시가 가능하다. 그런데 호출이 막혔다.

```
{ "type": "error", "error": { "type": "authentication_error",
  "message": "Invalid authentication credentials" } }
```

원인 조사 결과:

| 확인 대상 | 결과 |
|---|---|
| 키체인 `Claude Code-credentials`의 `expiresAt` | 2026-07-25 — **만료** |
| 같은 키체인 항목의 수정일(`mdat`) | 2026-07-24 이후 **변동 없음** |
| `~/.claude/.credentials.json` | 동일하게 2026-07-24 기준, 만료 |
| `settings.json`의 `apiKeyHelper` / `ANTHROPIC_API_KEY` | 없음 |

실행 중인 Claude Code는 갱신된 액세스 토큰을 **메모리에서만** 쓰고 디스크/키체인에 되쓰지 않는 것으로 보인다. 그래서 외부 스크립트가 가져다 쓸 유효한 토큰이 없다.

orca가 퍼센트를 보여주는 이유는 **자체 OAuth 로그인으로 별도의 유효한 토큰을 들고 있기 때문**이다. Claude Code의 토큰을 빌려 쓰는 구조가 아니다.

### 3. 직접 리프레시하지 않은 이유

리프레시 토큰은 남아 있으므로 스크립트가 직접 토큰 갱신을 시도할 수는 있다. 하지만 **리프레시 토큰이 회전(rotation)되면 실행 중인 Claude Code 세션이 들고 있는 토큰과 어긋나 로그인이 깨질 수 있다.** statusline처럼 수시로 실행되는 스크립트가 인증 상태를 건드리는 것은 위험 대비 이득이 없다고 판단해 진행하지 않았다.

**남은 선택지**: 퍼센트가 꼭 필요하면 (a) 토큰 리프레시 로직을 감수하거나, (b) Claude Code가 statusline 페이로드에 모델별 사용량을 노출할 때까지 기다린다.

---

## 구현

파일 2개. 무거운 JSONL 집계는 Python, statusline 조립은 기존 bash 스크립트 그대로.

| 파일 | 내용 |
|---|---|
| `~/.claude/statusline-fable.py` | 신규. 트랜스크립트에서 Fable 토큰을 7일 창으로 합산해 `97.7M` 형태로 출력 |
| `~/.claude/statusline-command.sh` | 기존 파일에 색상 상수 1줄 + 출력 세그먼트 3줄 추가 |

### statusline-command.sh 변경분

```bash
# 색상 상수 (기존 YELLOW 아래)
GREEN='\033[1;38;2;173;219;103m'

# 출력 조립 마지막, printf 직전
# fable usage is not in the statusline payload, so it comes from the transcripts
fable=$(python3 ~/.claude/statusline-fable.py 2>/dev/null)
[ -n "$fable" ] && out="$out | ${GREEN}Fable7d:${fable}${RESET}"
```

`2>/dev/null`과 `[ -n ... ]` 조합이라 Python이 없거나 스크립트가 깨져도 statusline은 기존 항목만 정상 출력한다.

### statusline-fable.py 동작

1. `~/.claude/projects/**/*.jsonl` 중 **mtime이 8일 이내**인 파일만 후보로 삼는다 (7일 창 + 경계 하루 여유).
2. 각 파일을 **캐시된 바이트 오프셋부터만** 읽는다. 마지막 개행 이후의 미완성 줄은 버리고 다음 실행 때 다시 읽는다.
3. `claude-fable` 문자열이 없는 줄은 JSON 파싱 전에 버린다 (바이트 단위 프리필터).
4. `message.model`이 `claude-fable`로 시작하는 레코드만 채택하고, `usage`의 `input_tokens` + `output_tokens` + `cache_creation_input_tokens` + `cache_read_input_tokens`를 합산한다.
5. **`message.id`를 키로 저장**한다 (중복 제거, 아래 참조).
6. 7일보다 오래된 레코드와 사라진 파일 항목을 정리한 뒤 `~/.claude/cache/fable-usage.json`에 원자적으로(tmp → `os.replace`) 저장한다.
7. 캐시 TTL 60초. 그 안에 다시 호출되면 재스캔 없이 캐시 값만 출력한다.

### 핵심 판단: message id 기준 중복 제거

가장 중요한 부분이다. 트랜스크립트를 그냥 합산하면 **약 2배로 부풀려진다.**

최근 7일치 트랜스크립트 실측:

| 항목 | 건수 |
|---|---|
| assistant 메시지 총합 | 3,342 |
| 고유 `message.id` | 1,683 |
| 중복분 | **1,659** |

세션을 fork하거나 resume하면 이전 대화 기록이 새 `.jsonl` 파일로 **복사**되기 때문이다. 그래서 파일별 합산이 아니라 `message.id`를 키로 하는 딕셔너리에 `[날짜, 토큰수]`를 넣어 자연히 덮어쓰이게 했다.

참고로 서브에이전트 트랜스크립트(`<session>/subagents/agent-*.jsonl`)와 부모 트랜스크립트 사이에는 중복이 없음을 별도로 확인했다 (부모 12건 / 서브 34건 / 겹침 0건). 즉 서브에이전트 파일을 제외하면 오히려 누락이 생긴다.

---

## 검증

| 검증 | 명령 | 결과 |
|---|---|---|
| 자체 점검 | `python3 ~/.claude/statusline-fable.py --demo` | `ok` (중복 제거·기간 정리·숫자 포맷) |
| 콜드 스캔 (캐시 삭제 후) | `time python3 ~/.claude/statusline-fable.py` | **0.107s** |
| 웜 스캔 (캐시 히트) | 동일 | **0.019s** |
| statusline 전체 렌더 | 샘플 JSON을 stdin으로 주입 | 정상 출력 확인 |

집계된 실제 값 (2026-08-11 기준, Fable 메시지 472건):

| 날짜 | 토큰 |
|---|---|
| 2026-08-07 | 40.36M |
| 2026-08-08 | 1.52M |
| 2026-08-09 | 1.23M |
| 2026-08-10 | 42.20M |
| 2026-08-11 | 12.39M |

콜드 스캔 대상은 53개 파일 32MB였다. 전체 `~/.claude/projects`는 323MB지만 mtime 필터로 대부분 걸러진다.

---

## 알려진 한계

- **퍼센트가 아니다.** 위 "왜 퍼센트가 아닌가" 참조. 남은 할당량 대비 비율은 알 수 없다.
- **비용($) 미표시.** Fable 단가를 하드코딩한 추정치가 되므로 넣지 않았다. 트랜스크립트의 `cost` 필드는 세션 누적 합계라 모델별로 분리되지 않는다.
- **캐시 읽기 토큰이 총합을 크게 부풀린다.** 4종 토큰을 단순 합산하므로 `cache_read_input_tokens`가 대부분을 차지한다. 실제 과금 부담과 비례하지 않는다. 체감에 맞추려면 `USAGE_KEYS`에서 `cache_read_input_tokens`를 빼면 된다.
- **7일보다 오래 열려 있던 파일.** mtime이 8일을 넘긴 파일은 스캔하지 않으므로, 아주 오래 방치된 트랜스크립트 안의 최근 기록은 누락될 수 있다. 실사용에서 문제된 적은 없다.
- **로컬 전용.** 다른 기기에서 쓴 Fable 사용량은 잡히지 않는다.

## 다른 맥에서 재현하려면

이 문서는 기록용이고, 실제 파일 2개는 아직 이 저장소에 포함돼 있지 않다. 재현하려면 `~/.claude/statusline-fable.py`와 `~/.claude/statusline-command.sh`를 이 저장소로 복사하고 `install.sh`에서 심볼릭 링크를 걸어야 한다.

## 참고

- statusline 설정: `~/.claude/settings.json` → `statusLine.command`
- 캐시 파일: `~/.claude/cache/fable-usage.json` (삭제해도 다음 실행 때 재생성)
- 색상은 `~/.config/starship.toml`의 night_owl 팔레트를 따른다
