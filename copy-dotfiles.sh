#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/Documentos/code/My_ArchLinux_Racing/dotfiles"

copy_dir() { src="$1"; dst="$2"; [ -d "$src" ] && rsync -a --delete "$src"/ "$dst"/; }
copy_file() { src="$1"; dst="$2"; [ -f "$src" ] && install -m 600 -D "$src" "$dst"; }

mkdir -p "$REPO"{/hypr,/waybar,/wofi,/kitty,/ghostty,/zellij,/btop,/zsh,/git,/vscode,/cursor}

copy_dir "$HOME/.config/hypr"     "$REPO/hypr"
copy_dir "$HOME/.config/waybar"   "$REPO/waybar"
copy_dir "$HOME/.config/wofi"     "$REPO/wofi"
copy_dir "$HOME/.config/kitty"    "$REPO/kitty"
copy_dir "$HOME/.config/ghostty"  "$REPO/ghostty"
copy_dir "$HOME/.config/zellij"   "$REPO/zellij"
copy_dir "$HOME/.config/btop"     "$REPO/btop"

copy_file "$HOME/.zshrc"          "$REPO/zsh/.zshrc"
copy_file "$HOME/.gitconfig"      "$REPO/git/.gitconfig"


