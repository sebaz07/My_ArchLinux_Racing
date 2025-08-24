#!/usr/bin/env bash
# Backup Configuration Script
# Updates the repository with current system configuration

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
    log_info "Starting configuration backup..."
    
    # Check if repository exists
    if [[ ! -d "$REPO_DIR" ]]; then
        log_error "Repository directory not found: $REPO_DIR"
        log_info "Please clone the repository first"
        exit 1
    fi
    
    cd "$REPO_DIR"
    
    # Update package list
    update_package_list
    
    # Backup dotfiles
    backup_dotfiles
    
    # Backup backgrounds
    backup_backgrounds
    
    # Commit changes
    commit_changes
    
    log_success "Backup completed successfully!"
}

update_package_list() {
    log_info "Updating package list..."
    
    # Generate new package list
    pacman -Qqe > "$REPO_DIR/listpackages.txt"
    
    # Add AUR packages if yay is installed
    if command -v yay &> /dev/null; then
        log_info "Adding AUR packages to list..."
        yay -Qm | awk '{print $1}' >> "$REPO_DIR/listpackages.txt"
        sort -u "$REPO_DIR/listpackages.txt" -o "$REPO_DIR/listpackages.txt"
    fi
    
    log_success "Package list updated"
}

backup_dotfiles() {
    log_info "Backing up dotfiles..."
    
    # Create dotfiles directory structure
    mkdir -p "$DOTFILES_DIR"/{hypr,waybar,wofi,kitty,ghostty,zellij,btop,zsh,git,grub}
    
    # Helper functions
    copy_dir() {
        local src="$1"
        local dst="$2"
        if [[ -d "$src" ]]; then
            log_info "Backing up: $(basename "$src")"
            rsync -a --delete "$src"/ "$dst"/
        else
            log_warning "Directory not found: $src"
        fi
    }
    
    copy_file() {
        local src="$1"
        local dst="$2"
        if [[ -f "$src" ]]; then
            log_info "Backing up: $(basename "$src")"
            install -m 644 -D "$src" "$dst"
        else
            log_warning "File not found: $src"
        fi
    }
    
    # Backup configuration directories
    copy_dir "$HOME/.config/hypr" "$DOTFILES_DIR/hypr"
    copy_dir "$HOME/.config/waybar" "$DOTFILES_DIR/waybar"
    copy_dir "$HOME/.config/wofi" "$DOTFILES_DIR/wofi"
    copy_dir "$HOME/.config/kitty" "$DOTFILES_DIR/kitty"
    copy_dir "$HOME/.config/ghostty" "$DOTFILES_DIR/ghostty"
    copy_dir "$HOME/.config/zellij" "$DOTFILES_DIR/zellij"
    copy_dir "$HOME/.config/btop" "$DOTFILES_DIR/btop"
    
    # Backup individual files
    copy_file "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc"
    copy_file "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig"
    
    # Backup GRUB theme if it exists
    if [[ -d "/boot/grub/themes/Vimix" ]]; then
        log_info "Backing up GRUB theme..."
        sudo cp -r "/boot/grub/themes/Vimix" "$DOTFILES_DIR/grub/themes/"
        sudo chown -R "$USER:$USER" "$DOTFILES_DIR/grub/themes/Vimix"
    fi
    
    log_success "Dotfiles backed up"
}

backup_backgrounds() {
    log_info "Backing up backgrounds..."
    
    local bg_source="$HOME/Pictures/Wallpapers"
    local bg_dest="$REPO_DIR/backgrounds"
    
    if [[ -d "$bg_source" ]]; then
        mkdir -p "$bg_dest"
        
        # Copy image files
        find "$bg_source" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) -exec cp {} "$bg_dest/" \;
        
        log_success "Backgrounds backed up"
    else
        log_warning "Wallpapers directory not found: $bg_source"
    fi
}

commit_changes() {
    log_info "Committing changes to git..."
    
    # Check if there are changes
    if git diff --quiet && git diff --staged --quiet; then
        log_info "No changes to commit"
        return 0
    fi
    
    # Add all changes
    git add .
    
    # Create commit message
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local commit_msg="Auto-backup: Configuration updated on $timestamp"
    
    # Commit changes
    git commit -m "$commit_msg"
    
    # Ask if user wants to push
    echo -n "Do you want to push changes to remote? (y/N): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git push
        log_success "Changes pushed to remote repository"
    else
        log_info "Changes committed locally only"
    fi
}

# Run main function
main "$@"
