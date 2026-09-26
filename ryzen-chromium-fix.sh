#!/bin/zsh

echo "=========================================================="
echo "    RYZENTOSH CHROMIUM & ELECTRON FIX (NATIVE POLICY)     "
echo "=========================================================="

# 1. Parámetros de renderizado estable para NootEDred
FLAGS="--use-gl=angle --use-angle=gl --disable-features=SkiaGraphite,SkiaGraphiteDawn --disable-gpu-sandbox"

# 2. Aplicar Políticas Administradas (defaults write) a Navegadores Chromium
echo "==> Aplicando políticas nativas a navegadores Chromium..."
defaults write com.brave.Browser ChromiumSwitches "$FLAGS" 2>/dev/null
defaults write com.google.Chrome ChromiumSwitches "$FLAGS" 2>/dev/null
defaults write com.microsoft.edgemac ChromiumSwitches "$FLAGS" 2>/dev/null
defaults write company.thebrowser.Browser ChromiumSwitches "$FLAGS" 2>/dev/null
defaults write com.vivaldi.Vivaldi ChromiumSwitches "$FLAGS" 2>/dev/null
defaults write com.operasoftware.Opera ChromiumSwitches "$FLAGS" 2>/dev/null

# 3. Crear LaunchAgent para aplicaciones Electron (VS Code, Discord, Spotify, etc.)
echo "==> Configurando entorno global para aplicaciones Electron..."
AGENT_PATH="$HOME/Library/LaunchAgents/com.ryzentosh.electronfix.plist"
mkdir -p "$HOME/Library/LaunchAgents"

cat << EOF > "$AGENT_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dylib">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ryzentosh.electronfix</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>-c</string>
        <string>launchctl setenv ELECTRON_EXTRA_LAUNCH_ARGS "$FLAGS"</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# 4. Cargar la variable de entorno en la sesión activa
chmod 644 "$AGENT_PATH"
launchctl setenv ELECTRON_EXTRA_LAUNCH_ARGS "$FLAGS"
launchctl load -w "$AGENT_PATH" 2>/dev/null

echo "=========================================================="
echo " ¡PARCHE NATIVO INSTALADO CORRECTAMENTE!                 "
echo "=========================================================="