#!/usr/bin/env bash
set -Eeuo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREW_BIN=/home/linuxbrew/.linuxbrew/bin/brew
BACKUP_DIR=

fail() {
  printf '오류: %s\n' "$1" >&2
  exit 1
}

run_as_root() {
  if [[ -t 0 ]]; then
    sudo "$@"
  elif command -v pkexec >/dev/null 2>&1; then
    pkexec "$@"
  else
    fail '대화형 터미널 또는 pkexec가 필요합니다.'
  fi
}

install_file() {
  local source_file="$1" target_file="$2"
  mkdir -p "$(dirname "$target_file")"
  if [[ -f "$target_file" ]] && cmp -s "$source_file" "$target_file"; then
    printf '유지: %s\n' "$target_file"
    return
  fi
  if [[ -e "$target_file" || -L "$target_file" ]]; then
    if [[ -z "$BACKUP_DIR" ]]; then
      mkdir -p "$HOME/.dotfiles-backup"
      BACKUP_DIR="$(mktemp -d "$HOME/.dotfiles-backup/linux-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
    fi
    cp -a -- "$target_file" "$BACKUP_DIR/$(basename "$target_file")"
    printf '백업: %s\n' "$target_file"
  fi
  cp --remove-destination -- "$source_file" "$target_file"
  printf '설치: %s\n' "$target_file"
}

[[ "$(uname -s)" == Linux ]] || fail 'Linux 전용 설치 스크립트입니다.'
[[ -x "$BREW_BIN" ]] || fail 'Linux Homebrew가 필요합니다: https://brew.sh/'
command -v ghostty >/dev/null || fail 'Ghostty를 먼저 설치해야 합니다.'

run_as_root apt-get update
run_as_root apt-get install -y zsh zoxide zsh-autosuggestions zsh-syntax-highlighting fonts-jetbrains-mono fonts-noto-cjk

for formula in starship fastfetch; do
  if ! "$BREW_BIN" list --versions "$formula" >/dev/null 2>&1; then
    "$BREW_BIN" install "$formula"
  fi
done

ghostty +validate-config --config-file="$SOURCE_DIR/config.ghostty"
zsh -n "$SOURCE_DIR/zshrc"
STARSHIP_CONFIG="$SOURCE_DIR/starship.toml" "$("$BREW_BIN" --prefix)/bin/starship" explain >/dev/null
"$("$BREW_BIN" --prefix)/bin/fastfetch" --config "$SOURCE_DIR/fastfetch.jsonc" --format json >/dev/null

install_file "$SOURCE_DIR/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
install_file "$SOURCE_DIR/starship.toml" "$HOME/.config/starship.toml"
install_file "$SOURCE_DIR/fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"
install_file "$SOURCE_DIR/zshrc" "$HOME/.zshrc"

if [[ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  if [[ -t 0 ]]; then
    chsh -s "$(command -v zsh)" || fail '기본 셸 변경에 실패했습니다. 설치된 설정은 유지됩니다.'
  else
    run_as_root chsh -s "$(command -v zsh)" "$(id -un)" || fail '기본 셸 변경에 실패했습니다. 설치된 설정은 유지됩니다.'
  fi
fi

printf '\n설치 완료. Ghostty 설정을 다시 읽고 새 탭에서 echo $0으로 Zsh를 확인하세요.\n'
if [[ -n "$BACKUP_DIR" ]]; then
  printf '기존 설정 백업: %s\n' "$BACKUP_DIR"
fi
