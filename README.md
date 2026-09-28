# terminal-dotfiles

Pop!_OS / COSMIC용 새 터미널 환경은 [Linux 설치 안내](linux/README.md)를 참고한다. 아래 내용은 macOS용이다.

macOS 터미널 환경 설정. **Ghostty + Starship + Zsh**(Oh My Zsh · Zinit).

새 맥에서 명령어 세 줄로 동일한 터미널 환경을 재현한다.

![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon%20%7C%20Intel-000000?logo=apple&logoColor=white)
![Shell](https://img.shields.io/badge/shell-zsh-89e051)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## 다른 컴퓨터에서 설치하기

### 준비물

새 맥에 필요한 건 이것뿐이다. 나머지는 스크립트가 알아서 설치한다.

| 항목 | 확인 방법 | 없으면 |
|---|---|---|
| macOS | — | 이 저장소는 macOS 전용 (`install.sh`가 Darwin이 아니면 중단) |
| Xcode Command Line Tools | `xcode-select -p` | `xcode-select --install` |
| 인터넷 연결 | — | Homebrew·플러그인을 내려받는다 |

> **Homebrew는 미리 설치할 필요 없다.** 없으면 `install.sh`가 설치한다.

### 설치

```bash
git clone https://github.com/HOYUN-Y/terminal-dotfiles.git ~/Documents/GitHub/terminal-dotfiles
cd ~/Documents/GitHub/terminal-dotfiles
./install.sh
```

clone 경로는 어디든 상관없다. `install.sh`가 `BASH_SOURCE` 기준으로 자기 위치를 찾는다.

설치가 끝나면 현재 터미널에 적용한다.

```bash
exec zsh
```

### 마지막 한 단계 — Ghostty에서 열기

`install.sh`가 Ghostty를 설치하지만, **지금 쓰는 터미널이 기본 앱(Terminal.app 등)이면 테마와 폰트가 적용된 걸 볼 수 없다.**

1. Spotlight(`cmd+space`)에서 **Ghostty** 실행
2. 폰트가 깨져 보이면 Ghostty를 완전히 종료(`cmd+q`)했다가 다시 연다
   — Nerd Font가 방금 설치돼 폰트 캐시가 아직 갱신되지 않았을 수 있다

### 설치 확인

```bash
starship --version        # 프롬프트
fastfetch                 # 시스템 정보 (셸 시작 시 자동 실행)
echo $ZSH                 # /Users/<이름>/.oh-my-zsh
ls ~/.local/share/zinit   # Zinit 설치 위치

z --help                  # zoxide가 .zshrc에서 로드됐는지 (없으면 exec zsh)
git config --get core.pager   # delta 가 나와야 정상
```

프롬프트가 아래처럼 보이면 성공이다.

```
 ~/Documents/GitHub  main ❯
```

---

## 무엇이 설치되나

### Homebrew 패키지 (`Brewfile`)

#### 프롬프트 · 터미널

| 패키지 | 용도 |
|---|---|
| `starship` | 크로스 셸 프롬프트 |
| `fastfetch` | 셸 시작 시 시스템 정보 표시 |
| `ghostty` (cask) | GPU 가속 터미널 에뮬레이터 |
| `font-hack-nerd-font` (cask) | 프롬프트 아이콘용 Nerd Font |
| `font-noto-sans-cjk-kr` (cask) | 한글 폰트 |

#### CLI 도구

기존 명령을 더 편한 버전으로 갈아끼우거나, 터미널 작업을 돕는 도구들이다.

| 패키지 | 대체 대상 | 쓰는 법 |
|---|---|---|
| `btop` | `top` | `btop` — CPU·메모리·네트워크를 그래프로 보는 시스템 모니터 |
| `duf` | `df` | `duf` — 디스크 여유공간을 색상 표로 |
| `dust` | `du` | `dust` — 어느 폴더가 용량을 먹는지 막대그래프로 (`dust ~/Downloads`) |
| `gh` | — | `gh pr create`, `gh repo clone` 등 GitHub CLI |
| `git-delta` | — | 직접 실행하지 않는다. `git diff`·`git show` 출력에 자동 적용 |
| `lazygit` | — | `lazygit` — 터미널 안에서 뜨는 Git UI. 커밋·브랜치·스테이징을 키보드로 |
| `neovim` | `vi` | `nvim` — 터미널 편집기 |
| `zoxide` | `cd` | `z dotfiles` — 한 번 간 경로를 학습해 일부 이름만으로 점프 |

`git-delta`와 `zoxide`는 **설치만으로는 동작하지 않아** 별도 연결이 필요하다. 이 저장소가 대신 처리한다.

| 도구 | 연결 지점 | 하는 일 |
|---|---|---|
| `git-delta` | `install.sh` → `configure_git_delta()` | `git config --global`로 `core.pager` 등 4개 키 설정 |
| `zoxide` | `.zshrc` | `eval "$(zoxide init zsh)"` — 이게 있어야 `z` 명령이 생긴다 |

### Zsh 플러그인

Oh My Zsh(`git` 플러그인) 위에 Zinit으로 세 개를 얹는다.

| 플러그인 | 효과 |
|---|---|
| `fast-syntax-highlighting` | 명령어를 입력하는 동안 문법 강조 (오타 즉시 확인) |
| `zsh-autosuggestions` | 히스토리 기반 자동완성 제안 (`→`로 수락) |
| `zsh-completions` | 추가 자동완성 정의 |

---

## AI 코딩 CLI (수동 설치)

**`install.sh`는 이들을 설치하지 않는다.** 로그인·인증이 필요하고 업데이트 주기가 저장소와 따로 돌기 때문에, 새 맥을 세팅한 뒤 필요할 때 직접 설치한다.

### Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

`~/.local/bin/claude`에 설치되고 스스로 업데이트한다. `.zshrc`가 `~/.local/bin`을 PATH에 넣으므로 `exec zsh` 후 바로 잡힌다.

Homebrew를 선호하면 이쪽도 된다. 다만 cask는 네이티브 설치보다 버전이 조금 뒤처진다.

```bash
brew install --cask claude-code
```

> **두 방식을 같이 쓰지 않는다.** 경로가 달라(`~/.local/bin` vs `$(brew --prefix)/bin`) `claude`가 둘 다 잡히면 PATH 순서에 따라 어느 쪽이 실행될지 헷갈린다. `which -a claude`로 하나만 나오는지 확인한다.

### Codex

```bash
brew install --cask codex
```

### 설치 확인

```bash
claude --version
codex --version
which -a claude    # 경로가 하나만 나와야 정상
```

---

## 저장소 구성

```
terminal-dotfiles/
├── install.sh              설치 스크립트
├── Brewfile                Homebrew 패키지 목록
├── .zshrc                  zsh 설정
├── .gitignore
└── .config/
    ├── starship.toml       프롬프트 테마 (Night Owl)
    └── ghostty/config      터미널 테마·폰트·키바인딩
```

| 파일 | 배치 위치 |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.config/starship.toml` | `~/.config/starship.toml` |
| `.config/ghostty/config` | `~/.config/ghostty/config` |

## install.sh가 하는 일

1. **Homebrew 설치** — 없을 때만. Apple Silicon은 `/opt/homebrew`, Intel은 `/usr/local`
2. **`brew bundle`** — `Brewfile`의 패키지·앱·폰트 설치
3. **git-delta 연결** — `~/.gitconfig` 백업 후 `git config --global`로 delta 관련 키만 설정
4. **Oh My Zsh 설치** — `KEEP_ZSHRC=yes`라 기존 `.zshrc`를 건드리지 않는다
5. **Zinit 설치** — 이미 있으면 `git pull --ff-only`로 업데이트
6. **설정 파일 배치** — 덮어쓰기 **전에** `~/.dotfiles-backup/<타임스탬프>/`로 백업
7. **검증** — `zsh -n`으로 문법 검사, `starship explain`으로 설정 검사

3번은 `user.name`·`user.email` 같은 기존 항목을 건드리지 않는다. `core.pager`, `interactive.diffFilter`, `delta.navigate`, `delta.line-numbers` 4개만 쓴다. `.gitconfig`를 통째로 덮어쓰지 않는 이유는 머신마다 사용자 정보가 다르기 때문이다.

모든 단계가 멱등적이라 **여러 번 실행해도 안전하다.**

### 기존 설정 되돌리기

`install.sh`는 덮어쓰기 전에 항상 백업한다.

```bash
ls ~/.dotfiles-backup/          # 타임스탬프별 백업 목록
cp ~/.dotfiles-backup/<타임스탬프>/.zshrc ~/.zshrc
exec zsh
```

`.gitconfig`도 delta 설정 전에 같은 위치로 백업된다. delta만 떼어내려면 아래처럼 키를 지운다.

```bash
git config --global --unset core.pager
git config --global --unset interactive.diffFilter
git config --global --unset delta.navigate
git config --global --unset delta.line-numbers
```

---

## 설정 바꾸기

이 저장소에서 고치고, 적용하고, 푸시한다.

```bash
cd ~/Documents/GitHub/terminal-dotfiles
# 파일 수정...
./install.sh                              # 이 맥에 적용
git add -A && git commit -m "..." && git push
```

다른 맥에서는 아래로 따라온다.

```bash
git pull && ./install.sh && exec zsh
```

### 머신마다 다른 설정 · 비밀정보

**API 키나 토큰은 이 저장소에 절대 넣지 않는다.** `~/.zshrc.local`에 두고 `.zshrc` 끝에서 불러온다.

```bash
# .zshrc 마지막 줄에 추가
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

`.gitignore`가 `*.local`, `.env*`, `secrets/`를 제외하도록 돼 있다.

---

## Ghostty

### 분할 창 단축키

| 키 | 동작 |
|---|---|
| `cmd + d` | 오른쪽으로 분할 |
| `cmd + shift + d` | 아래로 분할 |
| `cmd + w` | 현재 분할 닫기 |
| `cmd + opt + ←↑↓→` | 분할 간 이동 |
| `cmd + [` / `cmd + ]` | 이전 / 다음 분할 |
| `cmd + ctrl + ←↑↓→` | 크기 조절 |
| `cmd + ctrl + =` | 크기 균등화 |
| `cmd + shift + enter` | **현재 분할만 확대 / 복귀** |

위 8개 중 설정 파일에 정의된 건 앞의 4개뿐이고, 나머지는 Ghostty 기본값이라 어디서든 동작한다.

`cmd + w`는 탭이 아니라 **분할**을 닫는다. 분할이 하나뿐일 때 누르면 창이 닫힌다.

### ⚠️ 설정 파일 위치 함정

Ghostty는 macOS에서 **두 경로를 모두 읽는다.**

```
~/.config/ghostty/config                                    ← 이 저장소가 관리
~/Library/Application Support/com.mitchellh.ghostty/config  ← 있으면 같이 적용됨
```

둘 다 내용이 있으면 `font-family`·`palette`·`keybind` 같은 **누적형 항목이 중복 적용된다.** 실제로 폰트가 2개에서 4개로 늘어나는 걸 확인했다.

앱 UI에서 설정을 만졌다면 Application Support 쪽에 파일이 생겼을 수 있다. 확인하고 정리한다.

```bash
ls ~/Library/Application\ Support/com.mitchellh.ghostty/
# config 또는 config.ghostty가 있으면 이름을 바꾸거나 지운다

ghostty +show-config | grep font-family    # 폰트가 2줄이면 정상
```

### 적용된 설정 요약

- **테마** Night Owl (`#011627` 배경) — `starship.toml` 팔레트와 동일
- **폰트** Hack Nerd Font Mono 16pt + Noto Sans CJK KR 폴백
- **창** 반투명 0.9 + 블러 20, 패딩 12/10, 탭 스타일 타이틀바
- **스크롤백** 100,000줄 (에이전트 CLI처럼 출력이 긴 작업 대비)
- **기타** 선택 시 자동 복사, 붙여넣기 확인창 해제, `option`을 `alt`로

---

## 문제 해결

| 증상 | 원인과 해결 |
|---|---|
| 프롬프트 아이콘이 □로 깨짐 | Nerd Font 미적용. Ghostty를 `cmd+q`로 완전 종료 후 재실행 |
| 한글이 깨짐 | `font-noto-sans-cjk-kr` 설치 확인 → `brew list --cask \| grep noto` |
| `brew: command not found` | 셸 재시작(`exec zsh`). 그래도 안 되면 `.zshrc`의 Homebrew PATH 블록 확인 |
| 프롬프트가 그대로 | starship이 로드 안 됨. `.zshrc`에서 starship이 **맨 마지막**인지 확인 (Oh My Zsh가 덮어씀) |
| 플러그인이 동작 안 함 | `ls ~/.local/share/zinit/zinit.git` 확인 후 `./install.sh` 재실행 |
| 설정을 되돌리고 싶음 | `~/.dotfiles-backup/` 참조 (위 "기존 설정 되돌리기") |
| `z: command not found` | zoxide는 `.zshrc`의 `eval "$(zoxide init zsh)"`가 있어야 생긴다. `exec zsh` 후 재확인 |
| `z`를 쳐도 점프 안 함 | 학습 기록이 없어서다. `cd`로 몇 번 다녀오면 그때부터 잡힌다 |
| `git diff`가 그대로 | `git config --get core.pager`가 비었으면 `./install.sh` 재실행 |
| `claude: command not found` | 네이티브 설치는 `~/.local/bin`에 들어간다. `exec zsh` 후 `which -a claude` 확인 |

### Homebrew가 두 개인 경우

Apple Silicon 맥에서 `/opt/homebrew`(네이티브)와 `/usr/local`(Rosetta) 양쪽에 Homebrew가 있으면, `.zshrc`가 `/opt/homebrew`를 먼저 잡는다. 실제 패키지가 `/usr/local`에 있다면 `brew bundle`이 중복 설치를 시도한다.

```bash
brew config | grep -E 'HOMEBREW_PREFIX|Rosetta'   # 어느 쪽을 쓰는지 확인
file $(which starship)                            # arm64인지 x86_64인지
```

Apple Silicon에서는 `/opt/homebrew` + `arm64`가 정상이다.

---

## 라이선스

MIT
