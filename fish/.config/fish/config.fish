set fish_greeting ""

set -gx TERM xterm-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias v nvim
alias py python3
#alias myip "dig +short myip.opendns.com @resolver1.opendns.com"
alias myip6 "curl -6 ip.sb"
alias myip "curl -4 ip.sb"
alias colimavz "colima start -t vz -m 4"
alias k kubectl

set -gx EDITOR nvim

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# NodeJS
set -gx PATH node_modules/.bin $PATH

# Go
set -g GOPATH $HOME/go
set -gx PATH $GOPATH/bin $PATH

# NVM
function __check_rvm --on-variable PWD --description 'Do nvm stuff'
    status --is-command-substitution; and return

    if test -f .nvmrc; and test -r .nvmrc
        nvm use
    else
    end
end

switch (uname)
    case Darwin
        source (dirname (status --current-filename))/config-osx.fish
    case Linux
        source (dirname (status --current-filename))/config-linux.fish
    case '*'
        source (dirname (status --current-filename))/config-windows.fish
end

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
    source $LOCAL_CONFIG
end

# dotFiles config 
alias config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'

# PHP PATH

set PHP_VERSION (ls /Applications/MAMP/bin/php/ | sort -n | tail -1)
set -x PATH /Applications/MAMP/bin/php/$PHP_VERSION/bin $PATH

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/nieh/.lmstudio/bin

# Added by Antigravity
fish_add_path /Users/nieh/.antigravity/antigravity/bin

# opencode
fish_add_path /Users/nieh/.opencode/bin

# Starship ကို စတင်ခြင်း
if command -v starship >/dev/null
    starship init fish | source
end

# Starship config path ကို သတ်မှတ်ခြင်း (Cross-platform အတွက်)
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml

# aws toggle

function toggle-aws
    if set -q AWS_PROFILE
        set -gx _OLD_AWS_PROFILE $AWS_PROFILE
        set -e AWS_PROFILE
        echo "AWS Module: [HIDDEN]"
    else if set -q _OLD_AWS_PROFILE
        set -gx AWS_PROFILE $_OLD_AWS_PROFILE
        set -e _OLD_AWS_PROFILE
        echo "AWS Module: [SHOWN]"
    else
        echo "No active AWS profile to toggle."
    end
end

# gcloud toggle
#
function toggle-gcloud
    if not set -q CLOUDSDK_CONFIG
        set -gx CLOUDSDK_CONFIG /tmp/empty-gcloud-config
        echo "GCloud Module: [HIDDEN]"
    else
        set -e CLOUDSDK_CONFIG
        echo "GCloud Module: [SHOWN]"
    end
end

# AWS profile set
function asp
    if test (count $argv) -eq 0
        set -e AWS_PROFILE
        echo "AWS Profile cleared."
    else
        set -gx AWS_PROFILE $argv[1]
        echo "AWS Profile set to: $AWS_PROFILE"
    end
end
