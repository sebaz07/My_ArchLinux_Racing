#!/usr/bin/env bash
# Quick Dotfiles Installation Script
# For when you just want to apply the configurations to an existing system

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Repository configuration
REPO_URL="https://github.com/sebaz07/My_ArchLinux_Racing.git"
REPO_DIR="$HOME/My_ArchLinux_Racing"
DOTFILES_DIR="$REPO_DIR/dotfiles"

main() {
    log_info "Quick dotfiles installation..."
    
    # Clone or update repository
    if [[ -d "$REPO_DIR" ]]; then
        log_info "Updating existing repository..."
        cd "$REPO_DIR" && git pull
    else
        log_info "Cloning repository..."
        git clone "$REPO_URL" "$REPO_DIR"
    fi
    
    # Create backup
    create_backup
    
    # Install dotfiles
    install_dotfiles
    
    # Install wallpapers
    install_wallpapers
    
    log_success "Dotfiles installation completed!"
    log_info "You may need to restart applications or logout/login for changes to take effect."
}

create_backup() {
    log_info "Creating backup of existing configurations..."
    
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    local configs=("hypr" "waybar" "wofi" "kitty" "ghostty" "zellij" "btop")
    
    for config in "${configs[@]}"; do
        if [[ -d "$HOME/.config/$config" ]]; then
            log_info "Backing up $config..."
            cp -r "$HOME/.config/$config" "$backup_dir/"
        fi
    done
    
    # Backup shell configs
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$backup_dir/"
    [[ -f "$HOME/.gitconfig" ]] && cp "$HOME/.gitconfig" "$backup_dir/"
    
    log_success "Backup created at: $backup_dir"
}

install_dotfiles() {
    log_info "Installing dotfiles..."
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Install each configuration
    local configs=(
        "hypr:$HOME/.config/hypr"
        "waybar:$HOME/.config/waybar"
        "wofi:$HOME/.config/wofi"
        "kitty:$HOME/.config/kitty"
        "ghostty:$HOME/.config/ghostty"
        "zellij:$HOME/.config/zellij"
        "btop:$HOME/.config/btop"
    )
    
    for config in "${configs[@]}"; do
        IFS=':' read -r src dst <<< "$config"
        local src_path="$DOTFILES_DIR/$src"
        
        if [[ -d "$src_path" ]]; then
            log_info "Installing $src configuration..."
            mkdir -p "$dst"
            cp -r "$src_path"/* "$dst/"
            log_success "$src installed"
        else
            log_warning "Configuration not found: $src_path"
        fi
    done
    
    # Install individual files
    if [[ -f "$DOTFILES_DIR/zsh/.zshrc" ]]; then
        log_info "Installing .zshrc..."
        cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    fi
    
    if [[ -f "$DOTFILES_DIR/git/.gitconfig" ]]; then
        log_info "Installing .gitconfig..."
        cp "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    fi
}

install_wallpapers() {
    log_info "Installing wallpapers..."
    
    local wallpaper_dir="$HOME/Pictures/Wallpapers"
    mkdir -p "$wallpaper_dir"
    
    if [[ -d "$REPO_DIR/backgrounds" ]]; then
        cp -r "$REPO_DIR/backgrounds"/* "$wallpaper_dir/"
        log_success "Wallpapers installed to $wallpaper_dir"
    else
        log_warning "Backgrounds directory not found"
    fi
}

# Show usage information
usage() {
    echo "Quick Dotfiles Installation Script"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --no-backup    Skip creating backup of existing configs"
    echo ""
    echo "Examples:"
    echo "  $0                    # Install with backup"
    echo "  $0 --no-backup       # Install without backup"
    echo ""
    echo "Remote installation:"
    echo "  curl -sL https://raw.githubusercontent.com/sebaz07/My_ArchLinux_Racing/main/quick-install.sh | bash"
}

# Parse command line arguments
SKIP_BACKUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --no-backup)
            SKIP_BACKUP=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Override create_backup function if --no-backup is used
if [[ "$SKIP_BACKUP" == true ]]; then
    create_backup() {
        log_info "Skipping backup creation (--no-backup flag used)"
    }
fi

# Run main function
main "$@"
