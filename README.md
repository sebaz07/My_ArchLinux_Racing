# My Arch Linux Racing Setup 🏁

Un repositorio completo para instalar y configurar Arch Linux con un entorno Hyprland personalizado. Incluye scripts automatizados para una instalación rápida y fácil replicación del entorno.

## 🚀 Instalación Rápida

### Opción 1: Script de instalación completa (Recomendado)
```bash
curl -sL https://raw.githubusercontent.com/sebaz07/My_ArchLinux_Racing/main/install-arch.sh | bash
```

### Opción 2: Instalación manual paso a paso
```bash
# 1. Clonar el repositorio
git clone https://github.com/sebaz07/My_ArchLinux_Racing.git
cd My_ArchLinux_Racing

# 2. Hacer ejecutables los scripts
chmod +x *.sh

# 3. Ejecutar instalación base
./install-arch.sh

# 4. Configurar entorno Hyprland
./setup-hyprland.sh

# 5. Configurar entorno de desarrollo (opcional)
./setup-dev-env.sh
```

## 📁 Estructura del Repositorio

```
├── install-arch.sh          # Script principal de instalación
├── setup-hyprland.sh        # Configuración específica de Hyprland
├── setup-dev-env.sh         # Entorno de desarrollo
├── backup-config.sh         # Script para hacer backup de configuraciones
├── copy-dotfiles.sh         # Script original para copiar dotfiles
├── listpackages.txt         # Lista de paquetes instalados
├── backgrounds/             # Fondos de pantalla
└── dotfiles/               # Configuraciones de aplicaciones
    ├── hypr/               # Configuración de Hyprland
    ├── waybar/             # Barra de estado
    ├── wofi/               # Launcher de aplicaciones
    ├── kitty/              # Terminal
    ├── ghostty/            # Terminal alternativo
    ├── zellij/             # Multiplexor de terminal
    ├── btop/               # Monitor del sistema
    ├── zsh/                # Shell configuration
    ├── git/                # Configuración de Git
    └── grub/               # Tema de GRUB
```

## 🛠️ Características Incluidas

### Entorno de Escritorio
- **Hyprland**: Compositor Wayland con tiling dinámico
- **Waybar**: Barra de estado personalizable
- **Wofi**: Launcher de aplicaciones
- **Hyprpaper**: Gestor de fondos de pantalla
- **Hyprlock**: Bloqueador de pantalla
- **Mako**: Sistema de notificaciones

### Aplicaciones
- **Kitty/Ghostty**: Terminales modernos
- **Zellij**: Multiplexor de terminal
- **Btop**: Monitor del sistema
- **Thunar**: Gestor de archivos
- **Firefox**: Navegador web
- **VS Code**: Editor de código

### Herramientas de Desarrollo
- **Docker**: Contenedores
- **Node.js, Python, Rust, Go, .NET**: Entornos de desarrollo
- **Git**: Control de versiones
- **Múltiples editores y herramientas CLI**

## 📋 Scripts Disponibles

### `install-arch.sh`
Script principal que instala todos los paquetes base y configura el sistema:
- Actualiza el sistema
- Instala paquetes de `listpackages.txt`
- Configura yay (AUR helper)
- Copia dotfiles
- Configura servicios del sistema

### `setup-hyprland.sh`
Configuración específica del entorno Hyprland:
- Instala Hyprland y componentes relacionados
- Configura audio (PipeWire)
- Configura SDDM como display manager
- Instala temas e iconos
- Configura fuentes

### `setup-dev-env.sh`
Configura el entorno de desarrollo:
- Instala herramientas de desarrollo
- Configura Docker
- Instala SDKs (Node.js, Python, Rust, Go, .NET)
- Configura VS Code con extensiones

### `backup-config.sh`
Actualiza el repositorio con las configuraciones actuales:
- Regenera `listpackages.txt`
- Hace backup de todos los dotfiles
- Actualiza fondos de pantalla
- Commit automático a git

## 🔧 Uso de Scripts

### Hacer backup de configuración actual
```bash
./backup-config.sh
```

### Regenerar lista de paquetes manualmente
```bash
pacman -Qqe > listpackages.txt
```

### Instalar solo paquetes específicos
```bash
# Instalar solo paquetes oficiales
while read package; do sudo pacman -S --noconfirm "$package"; done < listpackages.txt

# Instalar paquetes AUR con yay
while read package; do yay -S --noconfirm "$package"; done < listpackages.txt
```

## 🎨 Personalización

### Cambiar fondos de pantalla
Los fondos están en `backgrounds/`. Para agregar nuevos:
1. Copia imágenes a `~/Pictures/Wallpapers/`
2. Ejecuta `./backup-config.sh` para actualizar el repo

### Modificar configuraciones
1. Edita archivos en `~/.config/`
2. Ejecuta `./backup-config.sh` para guardar cambios
3. Haz commit y push de los cambios

### Agregar nuevos paquetes
1. Instala paquetes normalmente con `pacman` o `yay`
2. Ejecuta `./backup-config.sh` para actualizar la lista
3. Los nuevos paquetes se incluirán automáticamente

## 🔍 Solución de Problemas

### Permisos de scripts
```bash
chmod +x *.sh
```

### Problemas con yay
```bash
# Reinstalar yay
sudo pacman -S --noconfirm git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si --noconfirm
```

### Hyprland no inicia
```bash
# Verificar dependencias
sudo pacman -S hyprland xdg-desktop-portal-hyprland
systemctl --user enable pipewire pipewire-pulse wireplumber
```

### Problemas de audio
```bash
# Reiniciar servicios de audio
systemctl --user restart pipewire pipewire-pulse wireplumber
```

## 📝 Notas Importantes

- **Backup antes de instalar**: Siempre haz backup de configuraciones importantes
- **Arch actualizado**: Los scripts asumen un sistema Arch Linux actualizado
- **Conexión a internet**: Requerida para descargar paquetes
- **Tiempo de instalación**: ~30-60 minutos dependiendo de la conexión

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Agregar nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 🎯 TODO

- [ ] Agregar soporte para múltiples monitores
- [ ] Script de actualización automática
- [ ] Configuración de gaming (Steam, Lutris)
- [ ] Temas adicionales
- [ ] Soporte para NVIDIA
- [ ] Configuración de VM con GPU passthrough

---

**¡Disfruta tu nuevo entorno Arch Linux! 🏁**

