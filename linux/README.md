# Pop!_OS / COSMIC 터미널 설정

Ghostty 1.3.1과 Pop!_OS 24.04용 독립 구성입니다. macOS 설정을 복사하지 않습니다.

## 설치

Ghostty와 Linux Homebrew가 이미 설치된 환경에서 실행합니다.

```bash
cd ~/Documents/GitHub/terminal-dotfiles
./linux/install.sh
```

APT는 Zsh, zoxide, Zsh 자동 제안·문법 강조 플러그인, JetBrains Mono와 Noto CJK 글꼴을 설치합니다. Homebrew는 Starship과 fastfetch를 설치합니다. 스크립트는 변경될 사용자 설정을 `~/.dotfiles-backup/linux-*`에 백업한 뒤 Ghostty, Starship, fastfetch, Zsh 설정을 배치하고 기본 셸을 Zsh로 변경합니다. 다시 실행해도 동일한 파일과 패키지는 유지합니다.

설치 후 Ghostty에서 `Ctrl+Shift+,`로 설정을 다시 읽고 `Ctrl+Shift+T`로 새 탭을 여세요. 새 탭에서 다음을 확인합니다. 이미 열려 있던 Bash 탭은 그대로 유지됩니다.

```bash
echo $0
ghostty +validate-config
starship --version
zoxide --version
fastfetch
```

Ghostty의 Linux 기본 단축키를 사용합니다. `Ctrl+Shift+O`는 오른쪽 분할, `Ctrl+Shift+E`는 아래 분할, `Ctrl+Alt+방향키`는 분할 사이 이동입니다. 대화형 Zsh 터미널을 열면 fastfetch가 Pop!_OS 로고와 주요 시스템 정보를 한 번 출력합니다.

Ghostty는 세션의 `SHELL` 환경 변수가 예전 Bash를 가리켜도 `/usr/bin/zsh`를 직접 실행하도록 설정합니다. `echo $0`에 `zsh`가 표시되면 정상입니다. 로그인 세션의 `SHELL` 환경 변수까지 바꾸려면 로그아웃 후 다시 로그인하세요.

개인 Ghostty 설정은 `~/.config/ghostty/config.local`에 넣을 수 있습니다. 저장소 파일이 바뀌면 `./linux/install.sh`를 다시 실행해 적용합니다.

## 되돌리기

백업된 설정은 설치 시 출력된 `~/.dotfiles-backup/linux-*`에서 복원합니다. 기본 셸을 Bash로 되돌릴 때는 `chsh -s /bin/bash`를 실행하고 다시 로그인하세요. 패키지는 이 스크립트가 자동 제거하지 않습니다.
