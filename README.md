# Arch Linux Package Backup & Configuration Packages

This repository contains the list of packages currently installed on my Arch Linux system, so I can easily replicate my environment in the future.

## Files

- `listpackages.txt` → All explicitly installed packages via `pacman` (including AUR packages if you use `yay`).

## Regenerate the package list

```bash
pacman -Qqe > listpackages.txt

