#!/bin/bash

# OS Detection
OS="$(uname)"
if [ "$OS" == "Linux" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    fi
elif [ "$OS" == "Darwin" ]; then
    DISTRO="macos"
fi

echo "🔍 Detected System: $DISTRO"

# Package Manager Install Function
install_stow() {
    case $DISTRO in
        macos)
            if ! command -v brew &> /dev/null; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install stow ;;
        ubuntu|debian|pop|mint)
            sudo apt update && sudo apt install -y stow ;;
        fedora|rhel|centos)
            sudo dnf install -y stow ;;
        arch|manjaro)
            sudo pacman -S --noconfirm stow ;;
        opensuse*|suse)
            sudo zypper install -y stow ;;
        *)
            echo "❌ Unsupported Distro: $DISTRO"; exit 1 ;;
    esac
}

# Stow Install
if ! command -v stow &> /dev/null; then
    echo "📦 Installing GNU Stow..."
    install_stow
fi

# TPM Install

echo "🔌 Setting up Tmux Plugin Manager..."
TPM_PATH="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_PATH" ]; then
    echo "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
else
    echo "TPM already installed, skipping clone."
fi

# Dotfiles Symlin
apps=("nvim" "nushell" "ghostty" "fish" "tmux" "starship" "zsh")
cd "$(dirname "$0")"

for app in "${apps[@]}"; do
    if [ -d "$app" ]; then
        echo "🔗 Linking $app..."
        stow -R "$app"
    fi
done

echo "✨ Dotfiles setup complete on $DISTRO!"
