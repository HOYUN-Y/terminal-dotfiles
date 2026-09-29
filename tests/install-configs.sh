#!/usr/bin/env bash
set -Eeuo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/install.sh"

test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT
mkdir -p "$test_root/home/.config/nvim" "$test_root/home/.config/ghostty"
printf 'old zsh\n' > "$test_root/home/.zshrc"
printf 'local settings\n' > "$test_root/home/.zshrc.local"
printf 'old plugin\n' > "$test_root/home/.config/nvim/old.lua"
printf 'font-size = 99\n' > "$test_root/home/.config/ghostty/config"
printf 'external starship\n' > "$test_root/starship.toml"
ln -s "$test_root/starship.toml" "$test_root/home/.config/starship.toml"

install_configs "$test_root/home"
first_backup="$BACKUP_DIR"
cmp "$DOTFILES_DIR/.zshrc" "$test_root/home/.zshrc"
cmp "$DOTFILES_DIR/.config/ghostty/config" "$test_root/home/.config/ghostty/config"
diff -r "$DOTFILES_DIR/.config/nvim" "$test_root/home/.config/nvim"
[[ "$(cat "$first_backup/.zshrc")" == 'old zsh' ]]
[[ -f "$first_backup/.config/nvim/old.lua" ]]
[[ -L "$first_backup/.config/starship.toml" ]]
[[ "$(cat "$test_root/starship.toml")" == 'external starship' ]]
[[ "$(cat "$test_root/home/.zshrc.local")" == 'local settings' ]]

install_configs "$test_root/home"
[[ "$BACKUP_DIR" != "$first_backup" ]]
[[ "$(cat "$first_backup/.zshrc")" == 'old zsh' ]]
cmp "$DOTFILES_DIR/.zshrc" "$BACKUP_DIR/.zshrc"
[[ "$(cat "$test_root/home/.zshrc.local")" == 'local settings' ]]
echo 'PASS: backups, symlinks, clean Neovim install, local settings, repeat install'

# Exercise delta configuration against a temporary Git config, never the user's.
(
  export GIT_CONFIG_GLOBAL="$test_root/home/.gitconfig"
  delta() { :; }
  git config --global user.name "Test User"
  configure_git_delta
  [[ "$(git config --global user.name)" == 'Test User' ]]
  [[ "$(git config --global core.pager)" == 'delta' ]]
  [[ "$(git config --global interactive.diffFilter)" == 'delta --color-only' ]]
  [[ "$(git config --file "$BACKUP_DIR/.gitconfig" user.name)" == 'Test User' ]]
)
echo 'PASS: delta configuration preserves and backs up Git identity'
