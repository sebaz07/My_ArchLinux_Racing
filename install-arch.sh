#!/usr/bin/env bash
# Arch Linux Installation and Configuration Script
# Usage: curl -sL https://raw.githubusercontent.com/sebaz07/My_ArchLinux_Racing/main/install-arch.sh | bash

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root"
   exit 1
fi

# Repository configuration
REPO_URL="https://github.com/sebaz07/My_ArchLinux_Racing.git"
REPO_DIR="$HOME/My_ArchLinux_Racing"
DOTFILES_DIR="$REPO_DIR/dotfiles"

# Main installation function
main() {
    log_info "Starting Arch Linux configuration..."
    
    # Update system
    update_system
    
    # Clone repository
    clone_repository
    
    # Install packages
    install_packages
    
    # Install AUR helper (yay)
    install_yay
    
    # Install AUR packages
    install_aur_packages
    
    # Copy dotfiles
    copy_dotfiles
    
    # Copy backgrounds
    copy_backgrounds
    
    # Setup GRUB theme
    setup_grub_theme
    
    # Enable services
    enable_services
    
    # Final setup
    final_setup
    
    log_success "Installation completed! Please reboot your system."
}

update_system() {
    log_info "Updating system packages..."
    sudo pacman -Syu --noconfirm
}

clone_repository() {
    log_info "Cloning configuration repository..."
    if [[ -d "$REPO_DIR" ]]; then
        log_warning "Repository already exists, updating..."
        cd "$REPO_DIR" && git pull
    else
        git clone "$REPO_URL" "$REPO_DIR"
    fi
}

install_packages() {
    log_info "Installing packages from listpackages.txt..."
    
    # Read packages and filter out AUR packages (we'll install those separately)
    local packages_file="$REPO_DIR/listpackages.txt"
    
    if [[ ! -f "$packages_file" ]]; then
        log_error "Package list not found: $packages_file"
        return 1
    fi
    
    # Install official packages
    log_info "Installing official repository packages..."
    while IFS= read -r package; do
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        
        if pacman -Si "$package" &>/dev/null; then
            log_info "Installing: $package"
            sudo pacman -S --noconfirm "$package" || log_warning "Failed to install: $package"
        else
            log_warning "Package not found in official repos (might be AUR): $package"
        fi
    done < "$packages_file"
}

install_yay() {
    log_info "Installing yay AUR helper..."
    
    if command -v yay &> /dev/null; then
        log_info "yay is already installed"
        return 0
    fi
    
    # Install dependencies
    sudo pacman -S --noconfirm git base-devel
    
    # Clone and build yay
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$HOME"
    rm -rf "$temp_dir"
    
    log_success "yay installed successfully"
}

install_aur_packages() {
    log_info "Installing AUR packages..."
    
    local packages_file="$REPO_DIR/listpackages.txt"
    
    # Try to install packages that weren't found in official repos with yay
    while IFS= read -r package; do
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        
        if ! pacman -Q "$package" &>/dev/null; then
            if yay -Si "$package" &>/dev/null; then
                log_info "Installing AUR package: $package"
                yay -S --noconfirm "$package" || log_warning "Failed to install AUR package: $package"
            fi
        fi
    done < "$packages_file"
}

copy_dotfiles() {
    log_info "Copying dotfiles configuration..."
    
    # Create necessary directories
    mkdir -p "$HOME/.config"
    
    # Copy each configuration directory
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
            log_info "Copying $src configuration..."
            mkdir -p "$dst"
            cp -r "$src_path"/* "$dst/"
        else
            log_warning "Configuration directory not found: $src_path"
        fi
    done
    
    # Copy individual files
    [[ -f "$DOTFILES_DIR/zsh/.zshrc" ]] && cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    [[ -f "$DOTFILES_DIR/git/.gitconfig" ]] && cp "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    
    log_success "Dotfiles copied successfully"
}

copy_backgrounds() {
    log_info "Copying wallpapers and backgrounds..."
    
    local bg_dir="$HOME/Pictures/Wallpapers"
    mkdir -p "$bg_dir"
    
    if [[ -d "$REPO_DIR/backgrounds" ]]; then
        cp -r "$REPO_DIR/backgrounds"/* "$bg_dir/"
        log_success "Backgrounds copied to $bg_dir"
    else
        log_warning "Backgrounds directory not found"
    fi
}

setup_grub_theme() {
    log_info "Setting up GRUB theme..."
    
    # Check if GRUB is installed
    if ! command -v grub-mkconfig &> /dev/null; then
        log_warning "GRUB not found, skipping theme installation"
        return 0
    fi
    
    # Check if /boot/grub exists
    if [[ ! -d "/boot/grub" ]]; then
        log_warning "/boot/grub directory not found, skipping theme installation"
        return 0
    fi
    
    local grub_theme_src="$DOTFILES_DIR/grub/themes/Vimix"
    local grub_theme_dst="/boot/grub/themes/Vimix"
    
    if [[ -d "$grub_theme_src" ]]; then
        log_info "Installing Vimix GRUB theme..."
        sudo mkdir -p "/boot/grub/themes"
        sudo cp -r "$grub_theme_src" "$grub_theme_dst"
        
        # Backup original GRUB config
        if [[ -f "/etc/default/grub" ]]; then
            sudo cp /etc/default/grub /etc/default/grub.backup.$(date +%Y%m%d-%H%M%S)
            log_info "GRUB config backed up"
        fi
        
        # Update GRUB configuration
        log_info "Updating GRUB configuration..."
        if ! grep -q "GRUB_THEME=" /etc/default/grub; then
            echo 'GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"' | sudo tee -a /etc/default/grub
        else
            sudo sed -i 's|GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"|' /etc/default/grub
        fi
        
        # Also ensure GRUB_GFXMODE is set for better theme display
        if ! grep -q "GRUB_GFXMODE=" /etc/default/grub; then
            echo 'GRUB_GFXMODE=auto' | sudo tee -a /etc/default/grub
        else
            sudo sed -i 's|GRUB_GFXMODE=.*|GRUB_GFXMODE=auto|' /etc/default/grub
        fi
        
        # Set GRUB_TERMINAL to enable graphical theme
        if grep -q "GRUB_TERMINAL=console" /etc/default/grub; then
            sudo sed -i 's|GRUB_TERMINAL=console|#GRUB_TERMINAL=console|' /etc/default/grub
            log_info "Commented out console terminal setting to enable graphical theme"
        fi
        
        # Regenerate GRUB configuration
        log_info "Regenerating GRUB configuration..."
        if sudo grub-mkconfig -o /boot/grub/grub.cfg; then
            log_success "GRUB theme installed and configuration regenerated successfully"
        else
            log_error "Failed to regenerate GRUB configuration"
            log_warning "You may need to run 'sudo grub-mkconfig -o /boot/grub/grub.cfg' manually"
        fi
    else
        log_warning "GRUB theme directory not found: $grub_theme_src"
    fi
}

enable_services() {
    log_info "Enabling system services..."
    
    # List of services to enable
    local services=(
        "NetworkManager"
        "bluetooth"
        "docker"
    )
    
    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "$service"; then
            log_info "Enabling $service..."
            sudo systemctl enable "$service"
        else
            log_warning "Service not found: $service"
        fi
    done
}

final_setup() {
    log_info "Performing final setup..."
    
    # Add user to groups
    sudo usermod -aG docker,wheel,audio,video "$USER"
    
    # Set zsh as default shell if installed
    if command -v zsh &> /dev/null; then
        log_info "Setting zsh as default shell..."
        chsh -s $(which zsh)
    fi
    
    # Install Oh My Zsh if not present
    if [[ ! -d "$HOME/.oh-my-zsh" ]] && command -v zsh &> /dev/null; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    log_success "Final setup completed"
}

# Run main function
main "$@"
