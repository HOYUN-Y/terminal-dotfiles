#!/usr/bin/env bash

set -Eeuo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR=""

log() {
  printf '\n\033[1;34m==>\033[0m %s\n' "$1"
}

warn() {
  printf '\033[1;33m경고:\033[0m %s\n' "$1"
}

fail() {
  printf '\033[1;31m오류:\033[0m %s\n' "$1" >&2
  exit 1
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew가 이미 설치되어 있습니다."
    return
  fi

  log "Homebrew를 설치합니다."
  /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    fail "Homebrew 설치 경로를 찾지 못했습니다."
  fi
}

install_packages() {
  log "Homebrew 패키지와 앱을 설치합니다."

  if [[ ! -f "$DOTFILES_DIR/Brewfile" ]]; then
    fail "Brewfile을 찾을 수 없습니다."
  fi

  brew bundle --file="$DOTFILES_DIR/Brewfile"
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "Oh My Zsh가 이미 설치되어 있습니다."
    return
  fi

  log "Oh My Zsh를 설치합니다."

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
}

install_zinit() {
  local zinit_dir="$HOME/.local/share/zinit/zinit.git"

  if [[ -d "$zinit_dir/.git" ]]; then
    log "Zinit이 이미 설치되어 있습니다."
    git -C "$zinit_dir" pull --ff-only || \
      warn "Zinit 업데이트를 건너뛰었습니다."
    return
  fi

  log "Zinit을 설치합니다."
  mkdir -p "$(dirname "$zinit_dir")"

  git clone \
    https://github.com/zdharma-continuum/zinit.git \
    "$zinit_dir"
}

configure_git_delta() {
  if ! command -v delta >/dev/null 2>&1; then
    warn "delta가 없어 git 페이저 설정을 건너뜁니다."
    return
  fi

  log "git이 delta를 쓰도록 설정합니다."

  local git_config="${GIT_CONFIG_GLOBAL:-$HOME/.gitconfig}"
  if [[ -f "$git_config" ]]; then
    cp -p "$git_config" "$BACKUP_DIR/.gitconfig"
  fi

  # user.name / user.email 등 기존 항목은 건드리지 않고
  # delta 관련 키만 덮어쓴다 (여러 번 실행해도 같은 결과)
  git config --global core.pager "delta"
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.line-numbers true
}

install_configs() {
  local target_home="${1:-$HOME}"
  local relative target backup
  local configs=(.zshrc .config/starship.toml .config/ghostty/config .config/nvim)

  for relative in "${configs[@]}"; do
    [[ -e "$DOTFILES_DIR/$relative" ]] || fail "설정 파일이 없습니다: $relative"
  done

  mkdir -p "$target_home/.dotfiles-backup"
  BACKUP_DIR="$(mktemp -d "$target_home/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)-XXXXXX")"

  for relative in "${configs[@]}"; do
    target="$target_home/$relative"
    backup="$BACKUP_DIR/$relative"
    if [[ -e "$target" || -L "$target" ]]; then
      mkdir -p "$(dirname "$backup")"
      mv "$target" "$backup"
      log "기존 설정 백업: $backup"
    fi
    mkdir -p "$(dirname "$target")"
    cp -R "$DOTFILES_DIR/$relative" "$target"
  done
}

validate_configs() {
  log "설정을 검사합니다."

  zsh -n "$HOME/.zshrc"

  if command -v starship >/dev/null 2>&1; then
    starship explain >/dev/null
  fi
}

main() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    fail "이 스크립트는 macOS용입니다."
  fi

  install_homebrew
  install_packages
  install_oh_my_zsh
  install_zinit
  install_configs
  configure_git_delta
  validate_configs

  log "설치가 완료되었습니다."

  echo
  echo "다음 명령으로 현재 터미널에 설정을 적용하세요:"
  echo
  echo "  exec zsh"
  echo

  if [[ -d "$BACKUP_DIR" ]]; then
    echo "기존 설정 백업 위치:"
    echo
    echo "  $BACKUP_DIR"
    echo
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
