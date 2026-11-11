# Codex CLI를 herdr 안에서 쓸 때 드래그 복사 복구

작업일·문서 작성일: 2026-11-12 · 대상 버전: Codex CLI 0.167.0, herdr 0.8.2, Ghostty 1.3.1 (macOS)

## 결과

`~/.codex/config.toml`의 기존 `[tui]` 섹션에 한 줄을 추가했다.

```toml
[tui]
copy_on_select = "always"
```

Codex를 재시작하면 Fullscreen 모드를 유지한 채로 그냥 드래그해서 복사할 수 있다. Shift 같은 보조키는 필요 없다.

> `[tui]` 섹션이 이미 있다면 그 안에 넣는다. `[tui]`를 한 번 더 쓰면 TOML 문법 오류가 난다.

## 증상

- herdr pane 안의 Codex CLI에서 드래그하면 선택 표시(하이라이트)가 생기지 않고 복사도 되지 않는다.
- 같은 herdr 안의 Claude Code CLI에서는 정상적으로 동작한다.
- 예전에는 Codex에서도 됐는데, 어느 업데이트 이후부터 안 된다.

## 원인

1. **Codex 0.157.0(2026-09-25)부터 기본 화면이 Fullscreen으로 바뀌었다** ([PR #47178](https://github.com/openai/codex/pull/47178)).
   - 이 모드에서는 Codex가 vim이나 lazygit처럼 화면 전체를 직접 그린다.
   - 마우스 입력도 Codex가 직접 받는다.
2. **pane 안의 앱이 마우스를 요청하면 herdr는 그 앱에 마우스 입력을 넘긴다.** 그래서 드래그가 herdr를 거치지 않고 Codex로 가고, herdr의 `copy_on_select`는 실행되지 않는다.
3. **Codex 자체의 copy-on-select는 기본값이 `auto`다.** `auto`는 tmux와 Zellij 같은 알려진 환경에서만 선택 즉시 복사한다. herdr는 이 목록에 없어서, 선택해도 복사가 되지 않았던 것으로 보인다(추정).

## 안 통했던 방법

| 시도 | 결과 |
|---|---|
| Ghostty `mouse-shift-capture = never` + Shift+드래그 | 선택 표시가 생기지 않음 |
| herdr `mouse_capture = false` | 시도하지 않음. herdr 기본 설정 설명에 따르면 이 경우에도 pane 앱이 요청하면 마우스가 앱으로 간다 |
| Ghostty `copy-on-select = clipboard` | 관련 없음. herdr 안에서는 Ghostty가 아니라 herdr나 Codex가 선택을 처리한다 |

## 대안: Scrollback 모드

예전처럼 터미널(herdr)이 선택과 복사를 처리하게 되돌리는 방법도 있다.

- Codex 안에서 `/tui` → **Scrollback** 선택 → 재시작
- 또는 `config.toml`의 `[tui]`에 `fullscreen_transcript = false`를 넣는다.
- 한 번만 쓸 때는 `codex --no-alt-screen`으로 실행한다.

이 경우 Fullscreen 전용 기능은 쓸 수 없다. 입력창 고정, 긴 출력 접기·펼치기, `F3` 검색, 마크다운과 서식을 함께 넣는 복사가 여기에 해당한다.

## 왜 `copy_on_select = "always"`를 택했나

- 공식 문서에 나온 옵션이다. Codex 팀 글에 "Codex가 터미널을 알아보지 못하면 `[tui]`의 `copy_on_select`를 `auto` / `always` / `never` 중에서 직접 정하라"고 되어 있다.
- Fullscreen의 이점을 그대로 유지할 수 있다.
- 선택 범위가 Codex 화면 안으로 한정되어서, herdr 사이드바나 옆 pane의 글자가 같이 선택되지 않는다.

알려진 한계:

- Codex를 종료하면 대화 내용이 터미널 기록에 남지 않는다. 다시 보려면 `codex resume`을 쓴다.
- SSH 원격 세션에서는 서식 없이 원본 마크다운만 복사된다고 한다.
- [#48664](https://github.com/openai/codex/issues/48664)에는 herdr 안에서 Codex 쪽 복사가 클립보드에 확실히 전달되지 않는다는 보고가 있다. 이 환경(macOS, 로컬)에서는 정상 동작을 확인했다.

## 참고

- [Discussion #49129 "Codex CLI goes fullscreen"](https://github.com/openai/codex/discussions/49129): 변경 이유, 두 모드 비교표, `copy_on_select` 옵션 설명
- [Issue #48664](https://github.com/openai/codex/issues/48664): herdr에서 마우스를 넘겨받지 못하는 문제. Fullscreen과 별도로 마우스 가로채기만 끄는 옵션을 요청한 이슈로, 아직 열려 있다
- [Issue #47996](https://github.com/openai/codex/issues/47996), [#48125](https://github.com/openai/codex/issues/48125): 0.157.0 이후 복사 문제 보고와 메인테이너의 `/tui` → Scrollback 안내
- [PR #47178](https://github.com/openai/codex/pull/47178): Fullscreen을 기본값으로 바꾼 PR
