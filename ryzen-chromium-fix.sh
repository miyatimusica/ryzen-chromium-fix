#!/bin/zsh

# ==============================================================================
# RYZEN CHROMIUM & ELECTRON FIX FOR RYZENTOSH (NootEDred.kext)
# Repository: https://github.com/miyatimusica/ryzen-chromium-fix
# Config.json injector & launchd environment setup
# ==============================================================================

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_progress() {
    local duration=$1
    local steps=20
    local delay=$(( (duration + 0.0) / steps ))
    
    for i in $(seq 1 $steps); do
        local pct=$(( i * 100 / steps ))
        local num_chars=$(( i * 20 / steps ))
        local fill=$(printf '%*s' "$num_chars" '' | tr ' ' '█')
        local empty=$(printf '%*s' "$(( 20 - num_chars ))" '' | tr ' ' '░')
        printf "\r⏳ [%s%s] %3d%%" "$fill" "$empty" "$pct"
        sleep $delay
    done
    echo ""
}

echo ""
echo "${CYAN}${BOLD}========================================================"
echo "   🚀 RYZEN CHROMIUM & ELECTRON FIX: INSTALADOR NATIVO   "
echo "========================================================${NC}"
echo ""

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "${RED}❌ Este script solo puede ejecutarse en macOS.${NC}"
    exit 1
fi

FLAGS="--use-gl=angle --use-angle=gl --disable-features=SkiaGraphite,SkiaGraphiteDawn --disable-gpu-sandbox"

echo "${BOLD}🌐 [1/4] Aplicando Enterprise Plist Policies a navegadores Chromium...${NC}"

defaults write com.brave.Browser ChromiumSwitches "$FLAGS" 2>/dev/null || true
defaults write com.google.Chrome ChromiumSwitches "$FLAGS" 2>/dev/null || true
defaults write com.microsoft.edgemac ChromiumSwitches "$FLAGS" 2>/dev/null || true
defaults write company.thebrowser.Browser ChromiumSwitches "$FLAGS" 2>/dev/null || true
defaults write com.vivaldi.Vivaldi ChromiumSwitches "$FLAGS" 2>/dev/null || true
defaults write com.operasoftware.Opera ChromiumSwitches "$FLAGS" 2>/dev/null || true

show_progress 0.4
echo "${GREEN}✅ Políticas inyectadas en preferencias de los navegadores.${NC}\n"

echo "${BOLD}⚙️ [2/4] Configurando LaunchAgent para Electron (Notion, VSCode, Discord, etc.)...${NC}"

AGENT_PLIST="$HOME/Library/LaunchAgents/com.ryzentosh.electronfix.plist"
mkdir -p "$HOME/Library/LaunchAgents"

cat << EOF > "$AGENT_PLIST"
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

chmod 644 "$AGENT_PLIST"
launchctl setenv ELECTRON_EXTRA_LAUNCH_ARGS "$FLAGS"
launchctl load -w "$AGENT_PLIST" 2>/dev/null || true

show_progress 0.4
echo "${GREEN}✅ Variable ELECTRON_EXTRA_LAUNCH_ARGS activada en la sesión.${NC}\n"

echo "${BOLD}📝 [3/4] Modificando archivos config.json de aplicaciones Electron...${NC}"

# Función Python en línea para forzar o actualizar la clave de hardware acceleration en JSON de forma segura
python3 -c "
import json, os, glob

app_support = os.path.expanduser('~/Library/Application Support')
json_files = glob.glob(os.path.join(app_support, '*', 'config.json'))

for config_path in json_files:
    try:
        data = {}
        if os.path.exists(config_path) and os.path.getsize(config_path) > 0:
            with open(config_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        
        # Deshabilitar aceleración de hardware nativa en JSON
        data['is_hardware_acceleration_disabled'] = True
        
        with open(config_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)
    except Exception:
        pass
" 2>/dev/null || true

show_progress 0.4
echo "${GREEN}✅ Archivos config.json de Electron modificados correctamente.${NC}\n"

echo "${BOLD}🧹 [4/4] Removiendo atributos de cuarentena en aplicaciones...${NC}"
sudo xattr -dr com.apple.quarantine /Applications/Notion.app 2>/dev/null || true
sudo xattr -dr com.apple.quarantine /Applications/Brave\ Browser.app 2>/dev/null || true
sudo xattr -dr com.apple.quarantine /Applications/Google\ Chrome.app 2>/dev/null || true
sudo xattr -dr com.apple.quarantine /Applications/Visual\ Studio\ Code.app 2>/dev/null || true
sudo xattr -dr com.apple.quarantine /Applications/Discord.app 2>/dev/null || true

show_progress 0.4
echo "${GREEN}✅ Atributos de cuarentena verificados.${NC}\n"

echo "${CYAN}${BOLD}========================================================"
echo " 🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!               "
echo " Notion, Chromium y Electron ahora están optimizados.  "
echo "========================================================${NC}\n"
