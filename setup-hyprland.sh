#!/usr/bin/env bash
# Hyprland Post-Installation Script
# Run this after the main installation to configure Hyprland environment

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

main() {
    log_info "Starting Hyprland post-installation setup..."
    
    # Install Hyprland and related packages
    install_hyprland_packages
    
    # Setup audio
    setup_audio
    
    # Configure display manager
    setup_display_manager
    
    # Setup themes and icons
    setup_themes
    
    # Configure fonts
    setup_fonts
    
    # Setup wallpaper service
    setup_wallpaper
    
    # Create desktop entries
    create_desktop_entries
    
    log_success "Hyprland setup completed!"
}

install_hyprland_packages() {
    log_info "Installing Hyprland and essential packages..."
    
    local hyprland_packages=(
        "hyprland"
        "waybar"
        "wofi"
        "hyprpaper"
        "hypridle"
        "hyprlock"
        "xdg-desktop-portal-hyprland"
        "xdg-desktop-portal-gtk"
        "qt5-wayland"
        "qt6-wayland"
        "wl-clipboard"
        "grim"
        "slurp"
        "swayidle"
        "swaylock-effects"
        "mako"
        "polkit-gnome"
        "thunar"
        "file-roller"
        "pavucontrol"
        "brightnessctl"
        "blueman"
        "network-manager-applet"
    )
    
    for package in "${hyprland_packages[@]}"; do
        if pacman -Si "$package" &>/dev/null; then
            log_info "Installing: $package"
            sudo pacman -S --noconfirm "$package" || log_warning "Failed to install: $package"
        else
            log_warning "Package not found in official repos: $package"
        fi
    done
}

setup_audio() {
    log_info "Setting up audio system..."
    
    # Install audio packages
    local audio_packages=(
        "pipewire"
        "pipewire-pulse"
        "pipewire-alsa"
        "pipewire-jack"
        "wireplumber"
        "alsa-utils"
    )
    
    for package in "${audio_packages[@]}"; do
        sudo pacman -S --noconfirm "$package" || log_warning "Failed to install: $package"
    done
    
    # Enable audio services
    systemctl --user enable pipewire
    systemctl --user enable pipewire-pulse
    systemctl --user enable wireplumber
    
    log_success "Audio system configured"
}

setup_display_manager() {
    log_info "Setting up display manager..."
    
    # Install and configure SDDM
    sudo pacman -S --noconfirm sddm
    
    # Enable SDDM
    sudo systemctl enable sddm
    
    # Create Hyprland desktop entry for SDDM
    sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF
    
    log_success "Display manager configured"
}

setup_themes() {
    log_info "Setting up themes and icons..."
    
    # Install theme packages
    local theme_packages=(
        "papirus-icon-theme"
        "arc-gtk-theme"
        "noto-fonts"
        "noto-fonts-emoji"
        "ttf-dejavu"
        "ttf-liberation"
    )
    
    for package in "${theme_packages[@]}"; do
        sudo pacman -S --noconfirm "$package" || log_warning "Failed to install: $package"
    done
    
    # Set GTK theme
    mkdir -p "$HOME/.config/gtk-3.0"
    cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Noto Sans 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOF
    
    log_success "Themes configured"
}

setup_fonts() {
    log_info "Installing additional fonts..."
    
    # Install font packages
    local font_packages=(
        "ttf-fira-code"
        "ttf-font-awesome"
        "ttf-jetbrains-mono"
        "adobe-source-code-pro-fonts"
    )
    
    for package in "${font_packages[@]}"; do
        sudo pacman -S --noconfirm "$package" || log_warning "Failed to install: $package"
    done
    
    # Refresh font cache
    fc-cache -fv
    
    log_success "Fonts installed"
}

setup_wallpaper() {
    log_info "Setting up wallpaper service..."
    
    # Create wallpaper script
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/set-wallpaper.sh" <<'EOF'
#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
if [[ -d "$WALLPAPER_DIR" ]]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
    if [[ -n "$WALLPAPER" ]]; then
        hyprctl hyprpaper wallpaper ",$WALLPAPER"
    fi
fi
EOF
    
    chmod +x "$HOME/.local/bin/set-wallpaper.sh"
    
    log_success "Wallpaper service configured"
}

create_desktop_entries() {
    log_info "Creating desktop entries..."
    
    mkdir -p "$HOME/.local/share/applications"
    
    # Create terminal desktop entry
    cat > "$HOME/.local/share/applications/kitty.desktop" <<EOF
[Desktop Entry]
Name=Kitty Terminal
Comment=Fast, feature-rich, GPU based terminal
Exec=kitty
Icon=kitty
Type=Application
Categories=System;TerminalEmulator;
StartupNotify=true
EOF
    
    log_success "Desktop entries created"
}

# Run main function
main "$@"
