#!/bin/zsh

APP_PATH="/Applications/Ryzentosh App Fixer.app"

echo "==> Generando e instalando Ryzentosh App Fixer.app..."

sudo rm -rf "$APP_PATH" 2>/dev/null

mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

cat << 'PLIST_EOF' > "$APP_PATH/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>main</string>
    <key>CFBundleIdentifier</key>
    <string>com.ryzentosh.appfixer.auto</string>
    <key>CFBundleName</key>
    <string>Ryzentosh App Fixer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>3.0</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
PLIST_EOF

cat << 'MAIN_EOF' > "$APP_PATH/Contents/MacOS/main"
#!/bin/zsh
DIR="$(cd "$(dirname "$0")" && pwd)"
CORE_SCRIPT="$DIR/../Resources/fixer_core.sh"
chmod +x "$CORE_SCRIPT" 2>/dev/null

/usr/bin/osascript -e "tell application \"Terminal\" to do script \"zsh \\\"$CORE_SCRIPT\\\"\"" -e 'tell application "Terminal" to activate'
MAIN_EOF

cat << 'CORE_EOF' > "$APP_PATH/Contents/Resources/fixer_core.sh"
#!/bin/zsh

BOLD="\033[1m"; CYAN="\033[0;36m"; GREEN="\033[0;32m"; YELLOW="\033[1;33m"; NC="\033[0m"

clear
echo ""
echo "${CYAN}${BOLD}===============================================================${NC}"
echo "   🚀 RYZENTOSH APP FIXER (PARCHADOR AUTOMÁTICO ELECTRON/CEF)  "
echo "${CYAN}${BOLD}===============================================================${NC}"
echo ""

echo "${BOLD}🔒 Solicitando permisos de administrador...${NC}"
sudo -v || exit 1

while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

echo ""
echo "${BOLD}🔍 [Etapa 1/3] Escaneando aplicaciones en /Applications y ~/Applications...${NC}"

APPS_LIST=(${(f)"$(find /Applications ~/Applications -maxdepth 2 -type d -name '*.app' 2>/dev/null)"})
TOTAL_FOUND=${#APPS_LIST[@]}

if [ $TOTAL_FOUND -eq 0 ]; then
    echo "${YELLOW}⚠️ No se encontraron aplicaciones para analizar.${NC}"
    exit 0
fi

echo "${GREEN}✅ Se encontraron $TOTAL_FOUND aplicaciones en el sistema.${NC}"
echo ""

echo "${BOLD}🧠 [Etapa 2/3] Identificando aplicaciones Electron / CEF...${NC}"

TO_PATCH_ELECTRON=()
ALREADY_PATCHED=()

for app in "${APPS_LIST[@]}"; do
    if [[ "$app" == *"Ryzentosh App Fixer.app"* ]] || [[ "$app" == *"(Ryzentosh).app"* ]]; then
        continue
    fi

    IS_ELECTRON=false

    # Detección de Electron / CEF Frameworks
    if [ -d "$app/Contents/Frameworks/Electron Framework.framework" ] || \
       [ -d "$app/Contents/Frameworks/Chromium Embedded Framework.framework" ]; then
        IS_ELECTRON=true
    fi

    if [ "$IS_ELECTRON" = true ]; then
        EXEC_NAME=$(plutil -extract CFBundleExecutable raw "$app/Contents/Info.plist" 2>/dev/null)
        if [ -n "$EXEC_NAME" ]; then
            if [ -f "$app/Contents/MacOS/$EXEC_NAME.orig" ]; then
                ALREADY_PATCHED+=("$app")
            else
                TO_PATCH_ELECTRON+=("$app")
            fi
        fi
    fi
done

TOTAL_TO_PATCH=${#TO_PATCH_ELECTRON[@]}

echo "${GREEN}✅ Análisis completado:${NC}"
echo "   • Apps Electron parcheadas previamente: ${#ALREADY_PATCHED[@]}"
echo "   • Apps Electron pendientes de parchear: ${#TO_PATCH_ELECTRON[@]}"
echo ""

PATCHED_SUCCESS=()

if [ $TOTAL_TO_PATCH -eq 0 ]; then
    echo "${GREEN}${BOLD}✨ ¡Todo está al día! No hay aplicaciones Electron pendientes.${NC}"
    echo ""
else
    echo "${BOLD}⚡ [Etapa 3/3] Aplicando inyección de banderas Chromium...${NC}"

    for app in "${TO_PATCH_ELECTRON[@]}"; do
        APP_NAME=$(basename "$app")
        echo "⚡ Parcheando Electron: ${BOLD}$APP_NAME${NC}..."

        EXEC_NAME=$(plutil -extract CFBundleExecutable raw "$app/Contents/Info.plist" 2>/dev/null)
        APP_DIR="$app/Contents/MacOS"

        if [ -n "$EXEC_NAME" ] && [ -f "$APP_DIR/$EXEC_NAME" ]; then
            if [ ! -f "$APP_DIR/$EXEC_NAME.orig" ]; then
                sudo mv "$APP_DIR/$EXEC_NAME" "$APP_DIR/$EXEC_NAME.orig"
            fi

            sudo tee "$APP_DIR/$EXEC_NAME" > /dev/null << 'WRAPPER_ELECTRON'
#!/bin/zsh
DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_NAME="$(basename "$0")"
exec "$DIR/${BIN_NAME}.orig" --disable-gpu --disable-gpu-compositing --disable-gpu-rasterization --disable-features=SkiaGraphite,SkiaGraphiteDawn --disable-gpu-sandbox "$@"
WRAPPER_ELECTRON

            sudo chmod +x "$APP_DIR/$EXEC_NAME"
            sudo xattr -dr com.apple.quarantine "$app" 2>/dev/null
            sudo codesign --force --deep --sign - "$app" 2>/dev/null
            sudo touch "$app"

            PATCHED_SUCCESS+=("$APP_NAME")
        fi
    done

    echo ""
    echo "${GREEN}✅ Parcheo completado con éxito.${NC}"
    echo ""
fi

echo "${CYAN}${BOLD}===============================================================${NC}"
echo "📋 RESUMEN DE APLICACIONES PARCHEADAS"
echo "${CYAN}${BOLD}===============================================================${NC}"

if [ ${#PATCHED_SUCCESS[@]} -gt 0 ]; then
    for patched_app in "${PATCHED_SUCCESS[@]}"; do
        echo "  ${GREEN}✔${NC} ${BOLD}$patched_app${NC}"
    done
else
    echo "  ${YELLOW}ℹ No se requirió modificar ninguna aplicación.${NC}"
fi

echo ""
echo "${CYAN}🎉 ¡Proceso completado! Puedes cerrar esta ventana.${NC}"
echo ""
CORE_EOF

chmod +x "$APP_PATH/Contents/MacOS/main"
chmod +x "$APP_PATH/Contents/Resources/fixer_core.sh"
sudo xattr -cr "$APP_PATH" 2>/dev/null
sudo codesign --force --deep --sign - "$APP_PATH" 2>/dev/null
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -r "$APP_PATH" 2>/dev/null
sudo touch "$APP_PATH"

echo "✅ Ryzentosh App Fixer.app instalada y actualizada correctamente."
