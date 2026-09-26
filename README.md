# 🚀 Ryzen Chromium & Electron Fix for macOS (Ryzentosh)

Solución nativa para corregir cierres imprevistos, parpadeos e inestabilidad gráfica en aplicaciones basadas en **Chromium** y **Electron** ejecutadas en Ryzentosh con `NootEDred.kext`.

## 🛠️ ¿Cómo funciona?

Este parche aprovecha las herramientas nativas del sistema operativo macOS para garantizar el rendimiento y estabilidad gráfica en las aplicaciones:

1. **Enterprise Plist Policies (`defaults write`):** Configura flags de inicio estables directamente en el subsistema de preferencias de los navegadores Chromium (`com.brave.Browser`, `com.google.Chrome`, etc.).

2. **LaunchAgent de Usuario:** Mantiene activa la variable de entorno `ELECTRON_EXTRA_LAUNCH_ARGS` en la sesión de usuario para aplicar automáticamente los parámetros de inicio a aplicaciones basadas en Electron como Visual Studio Code, Discord, Slack y Spotify.

### Flags Aplicados:

* `--use-gl=angle`

* `--use-angle=gl`

* `--disable-features=SkiaGraphite,SkiaGraphiteDawn`

* `--disable-gpu-sandbox`

## ⚡ Instalación Rápida

Abre la **Terminal** y ejecuta:

```bash
curl -fsSL https://raw.githubusercontent.com/tu-usuario/ryzen-chromium-fix/main/install.sh | zsh
```

## 🔍 Verificación

Para comprobar que la política para Electron está cargada en el sistema:

```bash
launchctl getenv ELECTRON_EXTRA_LAUNCH_ARGS
```

**Resultado esperado:**

```text
--use-gl=angle --use-angle=gl --disable-features=SkiaGraphite,SkiaGraphiteDawn --disable-gpu-sandbox
```

## 💻 Aplicaciones Soportadas

* **Navegadores:** Brave, Google Chrome, Microsoft Edge, Arc, Vivaldi, Opera.

* **Electron Apps:** Visual Studio Code, Cursor, Discord, Slack, Spotify, Obsidian, Notion.

## 🗑️ Desinstalación

Para eliminar las configuraciones del sistema:

```bash
# 1. Remover LaunchAgent
launchctl unload -w "$HOME/Library/LaunchAgents/com.ryzentosh.electronfix.plist" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/com.ryzentosh.electronfix.plist"
launchctl unsetenv ELECTRON_EXTRA_LAUNCH_ARGS

# 2. Limpiar políticas de navegadores
defaults delete com.brave.Browser ChromiumSwitches 2>/dev/null
defaults delete com.google.Chrome ChromiumSwitches 2>/dev/null
defaults delete com.microsoft.edgemac ChromiumSwitches 2>/dev/null
defaults delete company.thebrowser.Browser ChromiumSwitches 2>/dev/null
defaults delete com.vivaldi.Vivaldi ChromiumSwitches 2>/dev/null
defaults delete com.operasoftware.Opera ChromiumSwitches 2>/dev/null
```

## 📄 Licencia

Distribuido bajo la Licencia MIT.
