# =========================================================
# BASE DEL SHELL
# =========================================================

# ---------- Entorno ----------
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Historial ----------
mkdir -p "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME/zsh"

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY          # comparte e incorpora al instante entre sesiones
setopt EXTENDED_HISTORY       # guarda marca de tiempo
setopt HIST_IGNORE_ALL_DUPS   # elimina el duplicado antiguo al repetir un comando
setopt HIST_IGNORE_SPACE      # los comandos con espacio inicial no se guardan
setopt HIST_REDUCE_BLANKS     # quita espacios sobrantes
setopt HIST_VERIFY

# ---------- Comportamiento ----------
setopt EXTENDED_GLOB          # activar antes del bloque de completado
setopt AUTOCD
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt INTERACTIVE_COMMENTS
setopt NO_FLOW_CONTROL        # libera Ctrl+S / Ctrl+Q
setopt NO_BEEP
setopt NUMERIC_GLOB_SORT

# ---------- Autocompletado ----------
autoload -Uz compinit
_zcd="$XDG_CACHE_HOME/zsh/zcompdump"
if [[ -n $_zcd(#qN.mh+24) ]]; then
  compinit -d "$_zcd"
else
  compinit -C -d "$_zcd"
fi
unset _zcd

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# =========================================================
# PLUGINS Y ATAJOS
# =========================================================

# ---------- Opciones de plugins ----------

ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# zsh-autosuggestions: sugiere desde el historial y, si no hay, desde el completado
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# zsh-history-substring-search: no repite entradas iguales
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# ---------- Widgets ----------

# Alt+E: editar la línea actual en $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line

# Ctrl+Z: con la línea vacía recupera el trabajo suspendido (fg); con texto, lo aparta y te lo devuelve tras el siguiente comando
_fancy_ctrl_z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER='fg'
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N _fancy_ctrl_z

# ---------- Atajos de teclado ----------
# zsh-vi-mode reinicia los atajos al iniciarse, así que los propios se registran en este hook para que sobrevivan.
zvm_after_init() {
  # Ctrl+A / Ctrl+E -> inicio / fin de línea
  # Ctrl+E al final de la línea acepta la autosugerencia completa
  bindkey '^A' beginning-of-line
  bindkey '^E' end-of-line

  # Ctrl+Y -> aceptar la autosugerencia completa
  bindkey '^Y' autosuggest-accept

  # Alt+E -> editar la línea actual en $EDITOR
  bindkey -M viins '^[e' edit-command-line

  # Ctrl+Z -> recuperar el trabajo suspendido / apartar la línea
  bindkey -M viins '^Z' _fancy_ctrl_z
  bindkey -M vicmd '^Z' _fancy_ctrl_z

  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word
}

# ---------- Carga de plugins ----------
# Lista de "usuario/repo" en orden de carga. Se clonan solos la primera vez.
PLUGIN_DIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

_load_plugins() {
  local -a plugins=(
    zdharma-continuum/fast-syntax-highlighting
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-history-substring-search
    jeffreytse/zsh-vi-mode
  )
  local repo name dir

  for repo in $plugins; do
    name=${repo:t}
    dir=$PLUGIN_DIR/$name

    if [[ ! -d $dir ]]; then
      (( $+commands[git] )) || { echo "ERROR: git no está instalado" >&2; return 1; }
      echo "Instalando $name..."
      git clone --depth=1 "https://github.com/$repo" "$dir" \
        || { echo "ERROR: no se pudo instalar $name" >&2; continue; }
    fi

    [[ -r $dir/$name.plugin.zsh ]] && source "$dir/$name.plugin.zsh"
  done
}
_load_plugins
unfunction _load_plugins

# Actualizar todos los plugins: update-plugins
update-plugins() {
  local dir
  for dir in $PLUGIN_DIR/*(/N); do
    echo "Actualizando ${dir:t}..."
    git -C $dir pull --ff-only
  done
  touch "$XDG_STATE_HOME/zsh/plugins-updated"
}

# =========================================================
# APPS
# =========================================================

# ---------- diff y df ----------

# Añade colores a diff
alias diff='diff --color=auto'

# Muestra los tamaños en K, M o G en vez de en bloques
alias df='df -h'

# ---------- eza ----------

alias ls='eza --icons auto'

# Lista detallada
alias ll='eza -lh --icons --git'

# Lista detallada con archivos ocultos
alias la='eza -lah --icons auto --git'

# Árbol
alias tree='eza --tree --icons auto'
alias tree2='eza --tree --level=2 --icons auto'

# Usar el autocompletado de ls en eza
compdef eza=ls

# ---------- bat ----------

alias cat='bat'

# ---------- fzf ----------
# Necesita: fd, bat, eza y wl-clipboard (para Ctrl+Y y la función f)
#   Ctrl+/  muestra u oculta el preview
#   Ctrl+Y  copia al portapapeles lo marcado (o el elemento actual) y cierra fzf
export FZF_DEFAULT_OPTS='
  --height=50%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
  --color=fg:#CBE0F0,bg:#011628,hl:#B388FF
  --color=fg+:#CBE0F0,bg+:#143652,hl+:#B388FF
  --color=info:#06BCE4,border:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED
  --color=marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED
  --bind="ctrl-/:toggle-preview"
  --bind="ctrl-y:execute-silent(wl-copy < {+f})+abort"
'

# fd como motor de búsqueda
export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git'

_fzf_compgen_path() { fd --hidden --exclude .git . "$1" }
_fzf_compgen_dir()  { fd --type d --hidden --exclude .git . "$1" }
export FZF_COMPLETION_DIR_COMMANDS="cd z pushd rmdir"  # que ** también cuente z (zoxide)

_FZF_PREVIEW_CMD='bat --theme=Nord --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"

# Ctrl+R: preview con el comando completo (oculto; Ctrl+/ lo muestra).
export FZF_CTRL_R_OPTS='
  --preview="echo {2..}"
  --preview-window=down:3:hidden:wrap
  --bind="ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort"
'

# Preview según el comando al completar con **
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd|z|pushd|rmdir) fzf --preview 'eza --tree --level=2 --color=always {}' "$@" ;;
    export|unset)     fzf --preview "eval 'echo \${}'" "$@" ;;
    *)                fzf --preview "if [ -d {} ]; then eza --tree --level=2 --color=always {}; else $_FZF_PREVIEW_CMD; fi" "$@" ;;
  esac
}


# fv: elegir uno o varios archivos (Tab marca) y abrirlos en el editor
fv() {
  local out
  out=$(fzf --multi --preview "$_FZF_PREVIEW_CMD") || return
  ${EDITOR:-nvim} -- "${(@f)out}"
}

# fcd: elegir un directorio y entrar en él
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git | fzf --preview 'eza --tree --level=2 --color=always {}') || return
  cd "$dir" && ls
}

# f: elegir uno o varios archivos (Tab marca) y copiar sus rutas al portapapeles (Wayland)
f() {
  local out
  out=$(fzf --multi --preview "$_FZF_PREVIEW_CMD") || return
  printf '%s' "$out" | wl-copy
}

# fgb: elegir una rama de git y cambiar a ella
fgb() {
  local branch
  branch=$(git branch --all --color=never | grep -v -- '->' | sed 's/^[* ]*//; s#remotes/origin/##' | sort -u \
    | fzf --preview 'git log --oneline --color=always -20 {}') || return
  git switch "$branch"
}

# fkill: elegir un proceso y matarlo (señal 15 por defecto; fkill -9 para forzar)
fkill() {
  local pid
  pid=$(ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | sed 1d | fzf --header='Matar proceso' | awk '{print $1}')
  [[ -n $pid ]] || return
  kill "${1:--15}" "$pid"
}

zvm_after_init_commands+=('source <(fzf --zsh)')

# ---------- yazi ----------

function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

# ---------- starship (prompt) ----------

export VIRTUAL_ENV_DISABLE_PROMPT=1
eval "$(starship init zsh)"

# ---------- zoxide ----------

eval "$(zoxide init zsh)"

# ---------- fastfetch ----------

alias ff='fastfetch'

fastfetch

# =========================================================
# ALIAS PERSONALES
# =========================================================

# ---------- Camara (mpv) ----------

alias stream='mpv av://v4l2:/dev/video0 --demuxer-lavf-o=input_format=mjpeg,video_size=1920x1080,framerate=30 --profile=low-latency --untimed --msg-level=cplayer=error'
