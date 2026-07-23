# terminal-dotfiles

macOS 터미널 환경 설정. Ghostty + Starship + Zsh(Oh My Zsh · Zinit).

## 설치

새 맥에서 아래 세 줄이면 끝난다.

```bash
git clone https://github.com/HOYUN-Y/terminal-dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

끝나면 `exec zsh`로 현재 터미널에 적용한다.

`install.sh`는 자기 위치를 기준으로 동작하므로 clone 경로는 어디든 상관없다.

## 구성

| 파일 | 내용 |
|---|---|
| `.zshrc` | Homebrew PATH, fastfetch, Oh My Zsh, Zinit 플러그인 3종, Starship |
| `.config/starship.toml` | Night Owl 팔레트 한 줄 프롬프트 |
| `.config/ghostty/config` | Ghostty 테마·폰트·키바인딩 |
| `Brewfile` | starship, fastfetch + ghostty, 폰트 2종 |
| `install.sh` | 위 전부를 설치·배치하는 스크립트 |

## install.sh가 하는 일

1. Homebrew 설치 (없을 때만)
2. `brew bundle`로 패키지·앱·폰트 설치
3. Oh My Zsh 설치 (`KEEP_ZSHRC=yes`로 기존 `.zshrc` 보존)
4. Zinit 설치 (있으면 `git pull --ff-only`)
5. 설정 파일 배치 — **덮어쓰기 전 `~/.dotfiles-backup/<타임스탬프>/`에 백업**
6. `zsh -n` 문법 검사 + `starship explain` 검증

모든 단계가 멱등적이라 여러 번 실행해도 안전하다.

## Ghostty 설정 위치 주의

Ghostty는 macOS에서 **두 경로를 모두 읽는다.**

```
~/.config/ghostty/config                                    ← 이 저장소가 관리
~/Library/Application Support/com.mitchellh.ghostty/config  ← 있으면 같이 적용됨
```

둘 다 내용이 있으면 `font-family`·`palette`·`keybind` 같은 누적형 항목이 **중복 적용된다.**
(실제로 폰트가 2개에서 4개로 늘어나는 걸 확인했다.)

`~/.config/ghostty/config` 하나만 두고, Application Support 쪽에 파일이 있으면 이름을 바꾸거나 지운다.

## 분할 창 단축키

| 키 | 동작 |
|---|---|
| `cmd+d` / `cmd+shift+d` | 오른쪽 / 아래로 분할 |
| `cmd+w` | 현재 분할 닫기 |
| `cmd+opt+방향키` | 분할 간 이동 |
| `cmd+ctrl+방향키` | 크기 조절 |
| `cmd+ctrl+=` | 크기 균등화 |
| `cmd+shift+enter` | 현재 분할만 확대 / 복귀 |

아래 4개는 Ghostty 기본값이라 설정 파일에 없어도 동작한다.

## 로컬 전용 설정

머신마다 다른 값이나 비밀정보는 저장소에 넣지 말고 `~/.zshrc.local`에 두고 `.zshrc` 끝에서 불러온다.
`.gitignore`가 `*.local`과 `.env*`를 제외하도록 돼 있다.
