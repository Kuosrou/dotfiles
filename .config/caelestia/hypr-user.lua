--------------
-- Monitors --
--------------

hl.monitor({
  output = "DP-1",
  mode = "2560x1440@165",
  position = "1920x0",
  scale = 1,
})

--hl.monitor({
--  output = "DP-2",
--  mode = "1920x1080@75",
--  position = "0x0",
--  scale = 1,
--})

--hl.monitor({
--  output = "HDMI-A-1",
--  mode = "1920x1080@60",
--  position = "0x1080",
--  scale = 1,
--})

---------------------
-- Workspace Rules --
---------------------

hl.workspace_rule({ workspace = "1", monitor = "DP-1", persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-1", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "DP-1", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "DP-1", persistent = true })

hl.workspace_rule({ workspace = "6", monitor = "DP-2", persistent = true, default = true })
hl.workspace_rule({ workspace = "7", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "8", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "9", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "DP-2", persistent = true })

hl.workspace_rule({ workspace = "11", monitor = "HDMI-A-1", persistent = true, default = true })

--------
--Exec--
--------

-- Waywallen: daemon (Flatpak) + cliente layer-shell, una sola vez por sesión.
-- Si no existe el binario (p. ej. en la laptop), no hace nada.
hl.exec_cmd([[sh -c '
[ -x "$HOME/.local/bin/waywallen-layer-shell" ] || exit 0

echo "run $(date +%T) pid=$$ sig=$HYPRLAND_INSTANCE_SIGNATURE" >> /tmp/waywallen-runs.log
mkdir "/tmp/waywallen-session-$HYPRLAND_INSTANCE_SIGNATURE" 2>/dev/null || { echo "  -> omitido (misma sesión)" >> /tmp/waywallen-runs.log; exit 0; }

pkill -x waywallen-layer-shell
flatpak kill org.waywallen.waywallen
for i in 1 2 3 4 5 6 7 8 9 10; do pgrep -x waywallen >/dev/null || break; sleep 0.5; done
rm -f "$XDG_RUNTIME_DIR/waywallen/display.sock"

flatpak run org.waywallen.waywallen >/tmp/waywallen-app.log 2>&1 &

# Esperar al socket, máximo 30 s
for i in $(seq 1 30); do [ -S "$XDG_RUNTIME_DIR/waywallen/display.sock" ] && break; sleep 1; done
[ -S "$XDG_RUNTIME_DIR/waywallen/display.sock" ] || { echo "  -> socket no apareció" >> /tmp/waywallen-runs.log; exit 1; }

if [ -z "$WAYLAND_DISPLAY" ] || [ ! -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
  WL=$(ls -t "$XDG_RUNTIME_DIR"/wayland-* 2>/dev/null | grep -v "\.lock$" | head -n1)
  export WAYLAND_DISPLAY="$(basename "$WL")"
fi

sleep 1
# Relanzar el cliente si se cae (máx. 5 reintentos seguidos)
fails=0
while [ $fails -lt 5 ]; do
  start=$(date +%s)
  "$HOME/.local/bin/waywallen-layer-shell" --socket "$XDG_RUNTIME_DIR/waywallen/display.sock" >>/tmp/waywallen-ls.log 2>&1
  [ $(( $(date +%s) - start )) -gt 30 ] && fails=0 || fails=$((fails+1))
  sleep 2
done
']])

--------------
-- Keyboard --
--------------

hl.config({
  input = {
    kb_layout = "us,es",
    kb_options = "grp:alt_shift_toggle",
  },
})

-----------
-- Rules --
-----------
hl.window_rule({
  match = {
    class = "kitty",
  },
  suppress_event = "maximize",
})

-----------------
-- Environment --
-----------------

hl.env("XDG_MENU_PREFIX", "arch-")
