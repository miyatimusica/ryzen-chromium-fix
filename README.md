# 🚀 Ryzen Chromium & Electron Fix for macOS (Ryzentosh)

Solución nativa para corregir cierres imprevistos, parpadeos e inestabilidad gráfica en aplicaciones basadas en **Chromium** y **Electron** ejecutadas en Ryzentosh con `NootEDred.kext`.

---

## 🛠️ ¿Cómo funciona?

Este parche utiliza mecanismos nativos de administración de macOS para aplicar optimizaciones de GPU y renderizado de forma transparente:

1. **Enterprise Plist Policies (`defaults write`):** Inyecta flags de inicio estables directamente en el subsistema de preferencias de los navegadores Chromium (`com.brave.Browser`, `com.google.Chrome`, etc.).
2. **LaunchAgent de Usuario:** Mantiene la variable `ELECTRON_EXTRA_LAUNCH_ARGS` activa en la sesión para aplicaciones como Visual Studio Code, Discord, Slack y Spotify.

### Flags Aplicados:

* `--use-gl=angle`
* `--use-angle=gl`
* `--disable-features=SkiaGraphite,SkiaGraphiteDawn`
* `--disable-gpu-sandbox`

---

## ⚡ Instalación Rápida

Abre la **Terminal** y ejecuta:

```bash
curl -fsSL https://raw.githubusercontent.com/miyatimusica/ryzen-chromium-fix/main/install.sh | zsh
```

---

## 🔍 Verificación

Para comprobar que la política para Electron está cargada en el sistema:

```bash
launchctl getenv ELECTRON_EXTRA_LAUNCH_ARGS
```

**Resultado esperado:**

```
--use-gl=angle --use-angle=gl --disable-features=SkiaGraphite,SkiaGraphiteDawn --disable-gpu-sandbox
```

---

## 💻 Aplicaciones Soportadas

* **Navegadores:** Brave, Google Chrome, Microsoft Edge, Arc, Vivaldi, Opera.
* **Electron Apps:** Visual Studio Code, Cursor, Discord, Slack, Spotify, Obsidian, Notion.

---

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

---

## 📄 Licencia

Distribuido bajo la Licencia **MIT**.launchctl unload -w "$HOME/Library/LaunchAgents/com.ryzentosh.electronfix.plist" 2>/dev/null
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
