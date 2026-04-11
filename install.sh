#!/bin/bash
set -euo pipefail

# === Variables ===
DOTFILES_REPO="https://github.com/niehops/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
TPM_PATH="$HOME/.tmux/plugins/tpm"
PACKAGES=(neovim zsh zoxide fzf tmux stow git)
SUDO_CMD=""

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# === Logging Functions ===
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# === Helpers ===
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_installed() {
    local pkg="$1"
    local cmd="$pkg"
    [ "$pkg" = "neovim" ] && cmd="nvim"
    command_exists "$cmd"
}

# === Setup Sudo for Linux ===
setup_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        info "Running as root. Sudo not required."
    else
        SUDO_CMD="sudo"
        info "Requesting sudo privileges for installation..."
        if ! sudo -v; then
            error "Sudo privileges are required to install packages on Linux."
        fi
        
        # Keep-alive: update existing sudo time stamp until script has finished
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
}

# === Mac Installation ===
install_mac() {
    info "Detected macOS."
    
    if ! command_exists brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        success "Homebrew is already installed."
    fi
    
    for pkg in "${PACKAGES[@]}"; do
        if is_installed "$pkg"; then
            success "$pkg is already installed."
        else
            info "Installing $pkg via brew..."
            brew install "$pkg"
        fi
    done

    # Starship for macOS
    if is_installed "starship"; then
        success "starship is already installed."
    else
        info "Installing starship via brew..."
        brew install "starship"
    fi
}

# === Linux Installation ===
install_linux() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        local DISTRO=$ID
        info "Detected Linux distribution: $DISTRO"
        
        setup_sudo

        for pkg in "${PACKAGES[@]}"; do
            if is_installed "$pkg"; then
                success "$pkg is already installed."
            else
                info "Installing $pkg..."
                case $DISTRO in
                    ubuntu|debian|pop)
                        $SUDO_CMD apt-get update -qq
                        $SUDO_CMD apt-get install -y "$pkg"
                        ;;
                    fedora)
                        $SUDO_CMD dnf install -y "$pkg"
                        ;;
                    arch|manjaro)
                        $SUDO_CMD pacman -Sy --noconfirm "$pkg"
                        ;;
                    *)
                        error "Unsupported Linux distribution: $DISTRO. Cannot install $pkg."
                        ;;
                esac
            fi
        done
        
        # Starship independently via curl script
        if is_installed "starship"; then
            success "starship is already installed."
        else
            info "Installing starship independently..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
    else
        error "Cannot detect Linux distribution (/etc/os-release not found)."
    fi
}

# === Setup Dotfiles ===
setup_dotfiles() {
    echo ""
    info "Setting up Dotfiles (Git + Stow)..."
    
    if [ ! -d "$DOTFILES_DIR" ]; then
        info "Cloning dotfiles repository..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    else
        info "Dotfiles repository already exists. Pulling latest changes..."
        git -C "$DOTFILES_DIR" pull
    fi

    if [ -d "$DOTFILES_DIR" ]; then
        info "Applying dotfiles using Stow..."
        cd "$DOTFILES_DIR"
        
        # Temporarily disable 'exit on error' so we can gracefully handle stow conflicts
        set +e
        for app in */ ; do
            local app_name="${app%/}"
            if [ -d "$app_name" ]; then
                info "Stowing $app_name..."
                stow -R "$app_name" -t "$HOME"
                if [ $? -ne 0 ]; then
                    warn "Stow completely failed for $app_name. A file with the same name might already exist in your home directory."
                    warn "Please backup or remove the existing conflicting file(s) and re-run this script."
                fi
            fi
        done
        set -e # Re-enable exit on error
        
        cd - > /dev/null
        
        setup_tpm

        echo ""
        success "Dotfiles setup processes finished."
    else
        error "Dotfiles directory not found. Skipping stow."
    fi
}

# === Setup TPM ===
setup_tpm() {
    echo ""
    info "Setting up Tmux Plugin Manager..."
    if [ ! -d "$TPM_PATH" ]; then
        info "Cloning TPM..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    else
        success "TPM already installed, skipping clone."
    fi
}

# === Main Routine ===
main() {
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}       Automated Install Script         ${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    local OS
    OS="$(uname -s)"
    case "${OS}" in
        Linux*)  install_linux ;;
        Darwin*) install_mac ;;
        *)       error "Unsupported OS: ${OS}" ;;
    esac
    
    setup_dotfiles
    
    echo ""
    success "🎉 All Initializations and Installations are Complete!"
}

# Execute main function
main