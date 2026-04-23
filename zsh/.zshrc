# Set the directory for zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/shar}/zinit/zinit.git"

# Download zinit if not exist
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add powerlvl10k
#zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add snippets
zinit snippet OMZP::ansible
zinit snippet OMZP::aws
zinit snippet OMZP::azure
zinit snippet OMZP::brew
zinit snippet OMZP::command-not-found
zinit snippet OMZP::docker
zinit snippet OMZP::fzf
zinit snippet OMZP::gcloud
zinit snippet OMZP::git
zinit snippet OMZP::golang
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::microk8s
zinit snippet OMZP::minikube
zinit snippet OMZP::npm
zinit snippet OMZP::postgres
zinit snippet OMZP::python
zinit snippet OMZP::rsync
zinit snippet OMZP::ssh
zinit snippet OMZP::starship
zinit snippet OMZP::sudo
zinit snippet OMZP::systemd
zinit snippet OMZP::terraform
#zinit snippet OMZP::

# Load zsh-completions
autoload -U compinit && compinit
zinit cdreplay -q

# source/eval configurations
source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# keybindings
bindkey -v

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
#zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Alias
alias ls='eza --icons=always'
alias lt='eza --icons=always -T -L 1'
alias lta='eza --icons=always -aT -L 1'
alias la='eza --icons=always -a'
alias ll='eza --icons=always -l'
alias lla='eza --icons=always -l -a'
alias v=nvim
alias k=kubectl
alias python=python3
alias myip6='curl -6 ip.sb'
alias myip='curl -4 ip.sb'

# git
alias g=git
alias gph='git push'
alias gpl='git pull'
alias gct='git commit'

# zsh configs
if [[ -f ~/.config/zsh/toggles.zsh ]]; then
	source ~/.config/zsh/toggles.zsh
fi

export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)' --height 90%"

export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {} | head -200' --height 90%"

export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard' --height 90%"

  export EDITOR=nvim

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
