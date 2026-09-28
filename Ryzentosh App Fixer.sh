#!/bin/zsh

# ==============================================================================
# CREACIÓN DE LA APP AUTOMÁTICA: Ryzentosh App Fixer.app (A prueba de tontos)
# ==============================================================================

APP_PATH="/Applications/Ryzentosh App Fixer.app"

echo "==> Generando Ryzentosh App Fixer.app en /Applications..."

mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# 1. Info.plist de la App
cat << 'EOF' > "$APP_PATH/Contents/Info.plist"
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
    <string>2.0</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

# 2. Script Ejecutable con Apertura de Terminal y Auto-Escaneo Profundo
cat << 'EOF' > "$APP_PATH/Contents/MacOS/main"
#!/bin/zsh

# Abrir una ventana limpia de Terminal para mostrar el progreso en vivo con emojis
/usr/bin/osascript -e 'tell application "Terminal"
    do script "
    clear
    BOLD=\\\"\\033[1m\\\"
    CYAN=\\\"\\033[0;36m\\\"
    GREEN=\\\"\\033[0;32m\\\"
    YELLOW=\\\"\\033[1;33m\\\"
    NC=\\\"\\033[0m\\\"

    show_progress() {
        local current=\$1
        local total=\$2
        local prefix=\$3
        local width=25
        local pct=\$(( current * 100 / total ))
        local filled=\$(( current * width / total ))
        local empty=\$(( width - filled ))
        local fill_str=\$(printf '%*s' \"\$filled\" '' | tr ' ' '█')
        local empty_str=\$(printf '%*s' \"\$empty\" '' | tr ' ' '░')
        printf \"\\r%s [\\033[32m%s\\033[0m%s] %3d%% (%d/%d)\" \"\$prefix\" \"\$fill_str\" \"\$empty_str\" \"\$pct\" \"\$current\" \"\$total\"
    }

    echo \"\\n\${CYAN}\${BOLD}===============================================================\${NC}\"
    echo \"   🚀 RYZENTOSH APP FIXER v2.0 (AUTO-PATCHER PROFUNDO)   \"
    echo \"\${CYAN}\${BOLD}===============================================================\${NC}\\n\"

    echo \"\${BOLD}🔒 Solicitando permisos de administrador...\${NC}\"
    sudo -v || exit 1

    # Mantener privilegios activos durante el proceso
    while true; do sudo -n true; sleep 60; kill -0 \"\$$\" 2>/dev/null || exit; done 2>/dev/null &

    echo \"\\n\${BOLD}🔍 [Etapa 1/4] Escaneando carpetas y subcarpetas de aplicaciones...\${NC}\"
    
    # Búsqueda profunda en /Applications y ~/Applications incluyendo subcarpetas
    APPS_LIST=(\${(f)\"\$(find /Applications ~/Applications -type d -name '*.app' 2>/dev/null)\"})
    TOTAL_FOUND=\${#APPS_LIST[@]}

    for i in {1..\$TOTAL_FOUND}; do
        show_progress \$i \$TOTAL_FOUND \"🔍 Buscando paquetes .app:\"
        sleep 0.005
    done
    echo \"\\n\${GREEN}✅ Se encontraron \$TOTAL_FOUND aplicaciones en el sistema.\${NC}\\n\"

    echo \"\${BOLD}🧠 [Etapa 2/4] Analizando arquitectura y estado de parches...\${NC}\"
    
    TO_PATCH=()
    ALREADY_PATCHED=()
    
    IDX=0
    for app in \"\${APPS_LIST[@]}\"; do
        IDX=\$((IDX + 1))
        show_progress \$IDX \$TOTAL_FOUND \"🧠 Inspeccionando motores:\"

        # Verificar si usa Electron o Chromium
        IS_ELECTRON=false
        if [ -d \"\$app/Contents/Frameworks/Electron Framework.framework\" ] || \
           [ -d \"\$app/Contents/Frameworks/Chromium Embedded Framework.framework\" ]; then
            IS_ELECTRON=true
        fi

        if [ \"\$IS_ELECTRON\" = true ]; then
            EXEC_NAME=\$(plutil -extract CFBundleExecutable raw \"\$app/Contents/Info.plist\" 2>/dev/null)
            if [ -n \"\$EXEC_NAME\" ]; then
                # Si ya existe el archivo .orig, ya cuenta con el parche aplicado
                if [ -f \"\$app/Contents/MacOS/\$EXEC_NAME.orig\" ]; then
                    ALREADY_PATCHED+=(\"\$app\")
                else
                    TO_PATCH+=(\"\$app\")
                fi
            fi
        fi
    done

    echo \"\\n\${GREEN}✅ Análisis completado:\${NC}\"
    echo \"   • Apps parcheadas anteriormente: \${#ALREADY_PATCHED[@]}\"
    echo \"   • Apps que requieren parche: \${#TO_PATCH[@]}\\n\"

    TOTAL_TO_PATCH=\${#TO_PATCH[@]}

    if [ \$TOTAL_TO_PATCH -eq 0 ]; then
        echo \"\${GREEN}\${BOLD}✨ ¡Todo está al día! No se encontraron aplicaciones nuevas que requieran el parche.\${NC}\\n\"
    else
        echo \"\${BOLD}⚡ [Etapa 3/4] Aplicando parche de seguridad Wrapper...\${NC}\"
        PATCHED_SUCCESS=()

        P_IDX=0
        for app in \"\${TO_PATCH[@]}\"; do
            P_IDX=\$((P_IDX + 1))
            APP_NAME=\$(basename \"\$app\")
            show_progress \$P_IDX \$TOTAL_TO_PATCH \"⚡ Parcheando \$APP_NAME:\"

            EXEC_NAME=\$(plutil -extract CFBundleExecutable raw \"\$app/Contents/Info.plist\" 2>/dev/null)
            APP_DIR=\"\$app/Contents/MacOS\"

            if [ -n \"\$EXEC_NAME\" ] && [ -f \"\$APP_DIR/\$EXEC_NAME\" ]; then
                # Crear respaldo .orig si no existe
                if [ ! -f \"\$APP_DIR/\$EXEC_NAME.orig\" ]; then
                    sudo mv \"\$APP_DIR/\$EXEC_NAME\" \"\$APP_DIR/\$EXEC_NAME.orig\"
                fi

                # Generar script lanzador Wrapper seguro
                sudo tee \"\$APP_DIR/\$EXEC_NAME\" > /dev/null << 'WRAPPER_EOF'
#!/bin/zsh
DIR=\"\$(cd \"\$(dirname \"\$0\")\" && pwd)\"
exec \"\$DIR/\"$(basename \"\$APP_DIR/\$EXEC_NAME.orig\")\" --disable-gpu --disable-gpu-compositing --disable-gpu-rasterization --disable-features=SkiaGraphite,SkiaGraphiteDawn --disable-gpu-sandbox \"\$@\"
WRAPPER_EOF

                sudo chmod +x \"\$APP_DIR/\$EXEC_NAME\"
                sudo xattr -dr com.apple.quarantine \"\$app\" 2>/dev/null
                sudo codesign --force --deep --sign - \"\$app\" 2>/dev/null
                touch \"\$app\"

                PATCHED_SUCCESS+=(\"\$APP_NAME\")
            fi
            sleep 0.1
        done
        echo \"\\n\${GREEN}✅ Proceso de inyección finalizado con éxito.\${NC}\\n\"
    fi

    echo \"\${CYAN}\${BOLD}===============================================================\${NC}\"
    echo \"📋 [Etapa 4/4] RESUMEN DE APLICACIONES PARCHEADAS EN ESTA SESIÓN\"
    echo \"\${CYAN}\${BOLD}===============================================================\${NC}\"

    if [ \${#PATCHED_SUCCESS[@]} -gt 0 ]; then
        for patched_app in \"\${PATCHED_SUCCESS[@]}\"; do
            echo \"  \${GREEN}✔\${NC} \${BOLD}\$patched_app\${NC}\"
        done
    else
        echo \"  \${YELLOW}ℹ No se requirió parchear ninguna app nueva en este escaneo.\${NC}\"
    fi

    echo \"\\n\${CYAN}🎉 ¡Proceso completado! Puedes cerrar esta ventana.\${NC}\\n\"
    "
    activate
end tell'
EOF

# 3. Asignar permisos e indexar la aplicación
chmod +x "$APP_PATH/Contents/MacOS/main"
touch "$APP_PATH"

echo "✅ ¡Ryzentosh App Fixer.app instalada con éxito en tu Launchpad!"