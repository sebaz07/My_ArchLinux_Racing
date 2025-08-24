#!/usr/bin/env bash
# GRUB Theme Installation Script
# Configures GRUB with custom Vimix theme

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

REPO_DIR="$HOME/My_ArchLinux_Racing"
DOTFILES_DIR="$REPO_DIR/dotfiles"

main() {
    log_info "Starting GRUB theme configuration..."
    
    # Check requirements
    check_requirements
    
    # Install theme
    install_grub_theme
    
    # Configure GRUB
    configure_grub
    
    # Regenerate GRUB config
    regenerate_grub_config
    
    log_success "GRUB theme configuration completed!"
    log_info "Reboot to see the new GRUB theme"
}

check_requirements() {
    log_info "Checking requirements..."
    
    # Check if running as regular user
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
    
    # Check if GRUB is installed
    if ! command -v grub-mkconfig &> /dev/null; then
        log_error "GRUB is not installed on this system"
        exit 1
    fi
    
    # Check if /boot/grub exists
    if [[ ! -d "/boot/grub" ]]; then
        log_error "/boot/grub directory not found"
        log_info "Make sure GRUB is properly installed and you have a /boot partition"
        exit 1
    fi
    
    # Check if repository exists
    if [[ ! -d "$REPO_DIR" ]]; then
        log_error "Repository not found: $REPO_DIR"
        log_info "Please clone the repository first:"
        log_info "git clone https://github.com/sebaz07/My_ArchLinux_Racing.git"
        exit 1
    fi
    
    # Check if theme exists
    if [[ ! -d "$DOTFILES_DIR/grub/themes/Vimix" ]]; then
        log_error "GRUB theme not found: $DOTFILES_DIR/grub/themes/Vimix"
        exit 1
    fi
    
    log_success "All requirements met"
}

install_grub_theme() {
    log_info "Installing GRUB theme files..."
    
    local theme_src="$DOTFILES_DIR/grub/themes/Vimix"
    local theme_dst="/boot/grub/themes/Vimix"
    
    # Create themes directory
    sudo mkdir -p "/boot/grub/themes"
    
    # Remove existing theme if present
    if [[ -d "$theme_dst" ]]; then
        log_info "Removing existing theme..."
        sudo rm -rf "$theme_dst"
    fi
    
    # Copy theme files
    log_info "Copying theme files..."
    sudo cp -r "$theme_src" "$theme_dst"
    
    # Set correct permissions
    sudo find "$theme_dst" -type f -exec chmod 644 {} \;
    sudo find "$theme_dst" -type d -exec chmod 755 {} \;
    
    log_success "Theme files installed to $theme_dst"
}

configure_grub() {
    log_info "Configuring GRUB settings..."
    
    local grub_config="/etc/default/grub"
    
    # Backup original config
    if [[ -f "$grub_config" ]]; then
        local backup_file="${grub_config}.backup.$(date +%Y%m%d-%H%M%S)"
        sudo cp "$grub_config" "$backup_file"
        log_info "GRUB config backed up to: $backup_file"
    fi
    
    # Configure theme path
    log_info "Setting GRUB theme path..."
    if grep -q "GRUB_THEME=" "$grub_config"; then
        sudo sed -i 's|GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"|' "$grub_config"
    else
        echo 'GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"' | sudo tee -a "$grub_config"
    fi
    
    # Configure graphics mode
    log_info "Setting graphics mode..."
    if grep -q "GRUB_GFXMODE=" "$grub_config"; then
        sudo sed -i 's|GRUB_GFXMODE=.*|GRUB_GFXMODE=auto|' "$grub_config"
    else
        echo 'GRUB_GFXMODE=auto' | sudo tee -a "$grub_config"
    fi
    
    # Enable graphics payload
    if grep -q "GRUB_GFXPAYLOAD_LINUX=" "$grub_config"; then
        sudo sed -i 's|GRUB_GFXPAYLOAD_LINUX=.*|GRUB_GFXPAYLOAD_LINUX=keep|' "$grub_config"
    else
        echo 'GRUB_GFXPAYLOAD_LINUX=keep' | sudo tee -a "$grub_config"
    fi
    
    # Disable console terminal to enable graphical theme
    if grep -q "^GRUB_TERMINAL=console" "$grub_config"; then
        sudo sed -i 's|^GRUB_TERMINAL=console|#GRUB_TERMINAL=console|' "$grub_config"
        log_info "Disabled console terminal to enable graphical theme"
    fi
    
    # Set timeout for better theme visibility
    if grep -q "GRUB_TIMEOUT=" "$grub_config"; then
        sudo sed -i 's|GRUB_TIMEOUT=.*|GRUB_TIMEOUT=5|' "$grub_config"
    else
        echo 'GRUB_TIMEOUT=5' | sudo tee -a "$grub_config"
    fi
    
    log_success "GRUB configuration updated"
}

regenerate_grub_config() {
    log_info "Regenerating GRUB configuration..."
    
    # Verify theme file exists
    if [[ ! -f "/boot/grub/themes/Vimix/theme.txt" ]]; then
        log_error "Theme file not found: /boot/grub/themes/Vimix/theme.txt"
        exit 1
    fi
    
    # Regenerate GRUB config
    if sudo grub-mkconfig -o /boot/grub/grub.cfg; then
        log_success "GRUB configuration regenerated successfully"
    else
        log_error "Failed to regenerate GRUB configuration"
        log_warning "Please check GRUB installation and try manually:"
        log_warning "sudo grub-mkconfig -o /boot/grub/grub.cfg"
        exit 1
    fi
    
    # Verify the theme is properly configured
    if grep -q "set theme=" /boot/grub/grub.cfg; then
        log_success "Theme configuration found in grub.cfg"
    else
        log_warning "Theme configuration not found in grub.cfg"
        log_warning "Please verify the theme installation"
    fi
}

# Show current GRUB configuration
show_config() {
    log_info "Current GRUB theme configuration:"
    echo "----------------------------------------"
    
    if [[ -f "/etc/default/grub" ]]; then
        grep -E "GRUB_THEME|GRUB_GFXMODE|GRUB_GFXPAYLOAD_LINUX|GRUB_TERMINAL|GRUB_TIMEOUT" /etc/default/grub || echo "No theme-related configuration found"
    else
        echo "GRUB configuration file not found"
    fi
    
    echo "----------------------------------------"
    
    if [[ -f "/boot/grub/themes/Vimix/theme.txt" ]]; then
        echo "✓ Theme files are installed"
    else
        echo "✗ Theme files are not installed"
    fi
    
    if grep -q "set theme=" /boot/grub/grub.cfg 2>/dev/null; then
        echo "✓ Theme is configured in grub.cfg"
    else
        echo "✗ Theme is not configured in grub.cfg"
    fi
}

# Show usage information
usage() {
    echo "GRUB Theme Installation Script"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  --show-config    Show current GRUB theme configuration"
    echo "  --force          Force reinstallation even if theme exists"
    echo ""
    echo "Examples:"
    echo "  $0                    # Install GRUB theme"
    echo "  $0 --show-config     # Show current configuration"
    echo "  $0 --force           # Force reinstallation"
}

# Parse command line arguments
FORCE_INSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --show-config)
            show_config
            exit 0
            ;;
        --force)
            FORCE_INSTALL=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Check if theme is already installed (unless forced)
if [[ "$FORCE_INSTALL" == false ]] && [[ -d "/boot/grub/themes/Vimix" ]]; then
    log_warning "GRUB theme is already installed"
    log_info "Use --force to reinstall or --show-config to see current configuration"
    exit 0
fi

# Run main function
main "$@"
