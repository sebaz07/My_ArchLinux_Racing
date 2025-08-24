# Haciendo Debug de Gráficos

## Cambiar de TTY

- **Ctrl + Alt + F2 (o F3, F4...)** → Cambia a otra TTY (si está disponible).
- **Ctrl + Alt + Backspace** → Mata el servidor gráfico actual (si tienes activada esa opción en Xorg, en Arch por defecto normalmente **no está activada**).

## Iniciar entorno gráfico manualmente

```bash
startx
```

O:

```bash
gnome-session
```

## Remover e instalar drivers de NVIDIA

### Remover drivers de NVIDIA

```bash
sudo pacman -Rns nvidia nvidia-utils nvidia-settings nvidia-lts
```

### Instalarlos nuevamente

```bash
sudo pacman -S nvidia nvidia-utils lib32-nvidia-utils nvidia-prime
```

## Cargar los módulos al arranque

Edita el archivo `/etc/mkinitcpio.conf` y en la línea `MODULES=()` asegúrate de incluir los módulos necesarios.

## Activar el parámetro para KMS

Edita la configuración de GRUB según sea necesario.

## Reiniciar

Después del reinicio, el driver NVIDIA debería estar cargado. Verifícalo con los comandos adecuados.

## Probar PRIME Render Offload

Si todo salió bien, ejecuta los comandos necesarios para probar PRIME Render Offload.

## Caso: "glx not found"

### Instalar `mesa-demos`

```bash
sudo pacman -S mesa-demos
```