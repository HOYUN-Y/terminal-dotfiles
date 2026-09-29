# Homebrew PATH
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 네이티브 설치 CLI 경로 (Claude Code 등 — README "AI 코딩 CLI" 참고)
# 이미 PATH에 있으면 중복 추가하지 않는다
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Fastfetch
if [[ -o interactive ]] && (( $+commands[fastfetch] )); then
  fastfetch
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Zinit
ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"

if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"

  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

  zinit light zdharma-continuum/fast-syntax-highlighting
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-completions
fi

# 머신별 설정은 저장소 밖에 보관
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# 명령 이력·파일 검색 (Ctrl+R / Ctrl+T)
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# 자주 쓰는 디렉터리 이동 (z / zi)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Starship은 마지막에 로드
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
