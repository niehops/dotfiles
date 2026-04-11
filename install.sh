#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Homebrew on macOS
install_homebrew() {
    if ! command_exists brew; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
}

# List of packages to install
PACKAGES=(neovim zsh starship fzf tmux stow git zoxide)

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
            echo "Detected Linux distribution: $DISTRO"
            
            # Request sudo access upfront
            echo "Requesting sudo privileges for package installation..."
            if ! sudo -v; then
                echo "[ERROR] Sudo privileges are required to install packages on Linux."
                exit 1
            fi
            
            for pkg in "${PACKAGES[@]}"; do
                if command_exists "$pkg"; then
                    echo "[OK] $pkg is already installed."
                else
                    echo "[INSTALLING] $pkg..."
                    case $DISTRO in
                        ubuntu|debian|pop)
                            sudo apt-get update -qq
                            sudo apt-get install -y "$pkg"
                            ;;
                        fedora)
                            sudo dnf install -y "$pkg"
                            ;;
                        arch|manjaro)
                            sudo pacman -Sy --noconfirm "$pkg"
                            ;;
                        *)
                            echo "[ERROR] Unsupported Linux distribution: $DISTRO. Cannot install $pkg."
                            ;;
                    esac
                fi
            done
        else
            echo "Cannot detect Linux distribution (/etc/os-release not found)."
            exit 1
        fi
        ;;
    Darwin*)
        echo "Detected macOS."
        install_homebrew
        
        for pkg in "${PACKAGES[@]}"; do
            if command_exists "$pkg"; then
                echo "[OK] $pkg is already installed."
            else
                echo "[INSTALLING] $pkg..."
                brew install "$pkg"
            fi
        done
        ;;
    *)
        echo "Unsupported OS: ${OS}"
        exit 1
        ;;
esac

echo "Installation checking process is complete!"

echo ""
echo "========================================"
echo "    Dotfiles Setup (Git + Stow)         "
echo "========================================"

# Replace USERNAME with your actual GitHub username or the full repo URL
DOTFILES_REPO="https://github.com/USERNAME/dotfiles.git" 
DOTFILES_DIR="$HOME/.dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "[GIT] Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "[GIT] Dotfiles repository already exists at $DOTFILES_DIR"
    echo "[GIT] Pulling latest changes..."
    git -C "$DOTFILES_DIR" pull
fi

if [ -d "$DOTFILES_DIR" ]; then
    echo "[STOW] Applying dotfiles..."
    cd "$DOTFILES_DIR" || exit
    
    # Loop through directories in the dotfiles repo and stow them
    for app in */ ; do
        # Removing the trailing slash
        app_name="${app%/}" 
        echo "Stowing $app_name..."
        stow -R "$app_name" -t "$HOME"
    done
    
    cd - > /dev/null

    echo ""
    echo "🔌 Setting up Tmux Plugin Manager..."
    TPM_PATH="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$TPM_PATH" ]; then
        echo "Cloning TPM..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    else
        echo "TPM already installed, skipping clone."
    fi

    echo ""
    echo "[STOW] Dotfiles setup complete! All processes finished."
else
    echo "[ERROR] Dotfiles directory not found. Skipping stow."
fi
