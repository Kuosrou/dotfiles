# Dotfiles

Mi configuración de **Arch Linux**.

---

## Shell de escritorio

Uso [Caelestia](https://github.com/caelestia-dots/caelestia) como shell sobre Hyprland.

Para instalarla, sigue las instrucciones del [repositorio oficial](https://github.com/caelestia-dots/caelestia).

---

## Wallpapers

Uso [Waywallen](https://github.com/waywallen/waywallen) como gestor de wallpapers animados de Wallpaper Engine.

Para instalarlo, sigue las instrucciones del [repositorio oficial](https://github.com/waywallen/waywallen).

---

## Zsh

### Qué incluye

- **Historial**: se guarda en `~/.local/state/zsh/history`.
- **Autocompletado**
- **Modo vi** con [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode).
- **Sugerencias y resaltado**: [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) y [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search).
- **Herramientas**: [fzf](https://github.com/junegunn/fzf), [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [zoxide](https://github.com/ajeetdsouza/zoxide), [yazi](https://github.com/sxyazi/yazi), [starship](https://starship.rs) y [fastfetch](https://github.com/fastfetch-cli/fastfetch).

### Requisitos

```bash
sudo pacman -S --needed zsh git neovim fzf fd bat eza zoxide starship yazi fastfetch wl-clipboard mpv
```

Además, una **Nerd Font**, por ejemplo:

```bash
sudo pacman -S --needed ttf-jetbrains-mono-nerd
```

### Instalación

1. **Instala los requisitos**

2. **Copia los archivos de zsh**. Si ya tienes alguna, haz antes un backup

   ```bash
   git clone https://github.com/Kuosrou/dotfiles.git
   cd dotfiles
   cp .zshenv .zshrc ~/
   ```

3. **Copia la configuración de las herramientas**. Si ya tienes alguna, haz antes un backup

   ```bash
   cp -r .config/starship.toml .config/fastfetch .config/yazi ~/.config/
   ```

4. **Cambia tu shell a zsh**:

   ```bash
   chsh -s $(which zsh)
   ```

### Atajos de teclado

|  | Atajo | Acción |
| --- | --- | --- |
| Zsh | `Ctrl+A` / `Ctrl+E` | Inicio / fin de línea (`Ctrl+E` al final acepta la sugerencia) |
| Zsh | `Ctrl+Y` | Aceptar la sugerencia completa |
| Zsh | `Alt+E` | Editar la línea actual en `$EDITOR` |
| Zsh | `Ctrl+Z` | Con la línea vacía, recupera el trabajo suspendido (`fg`); con texto, lo aparta y te lo devuelve tras el siguiente comando |
| Zsh | `↑` / `↓` | Buscar en el historial |
| Zsh | `Ctrl+←` / `Ctrl+→` | Saltar de palabra en palabra |
| fzf | `Ctrl+T` | Elegir archivos (preview con `bat`) |
| fzf | `Alt+C` | Entrar en un directorio (preview con `eza`) |
| fzf | `Ctrl+R` | Buscar en el historial (`Ctrl+/` muestra el comando completo) |
| fzf | `**` + `Tab` | Completar rutas con fzf, por ejemplo `nvim **<Tab>` |
| fzf | `Ctrl+/` | Mostrar u ocultar el preview |
| fzf | `Ctrl+Y` | Copiar al portapapeles lo marcado y cerrar fzf |
| fzf | `Tab` | Marcar varios elementos (en `fv` y `f`) |

### Funciones y alias

**Funciones**

- `fv` — Elige uno o varios archivos con fzf y los abre en el editor
- `fcd` — Elige un directorio con fzf y entra en él
- `f` — Elige archivos con fzf y copia sus rutas al portapapeles
- `fgb` — Elige una rama de git y cambia a ella
- `fkill` — Elige un proceso y lo mata (`fkill -9` para forzar)
- `y` — Abre yazi y, al salir, deja la terminal en el directorio donde lo cerraste
- `update-plugins` — Actualiza todos los plugins con `git pull`

**Alias**

- `ls`, `ll`, `la` — `eza` con iconos (`ll` y `la` en formato largo y con git)
- `tree`, `tree2` — `eza --tree` (`tree2` limita a 2 niveles)
- `cat` — `bat`
- `diff` — `diff --color=auto`
- `df` — `df -h`
- `ff` — `fastfetch`
- `stream` — Abre la cámara (`/dev/video0`) en `mpv`

### Plugins

Para actualizarlos:

```bash
update-plugins
```

---

## Otras configuraciones

```bash
cp -r .config/kitty ~/.config/
```

---

## Licencia

Distribuido bajo la licencia [MIT](LICENSE).
