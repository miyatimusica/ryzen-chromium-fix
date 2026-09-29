<div align="center">

  # 🚀 Ryzen Chromium & Electron Fix for macOS (Ryzentosh)

[![macOS](https://img.shields.io/badge/macOS-12%20%7C%2013%20%7C%2014%20%7C%2015-blue.svg?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos)
[![Architecture](https://img.shields.io/badge/Architecture-x86__64-orange.svg?style=for-the-badge&logo=cpu)](https://github.com/miyatimusica/ryzen-dylib-fix)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![GitHub release](https://img.shields.io/badge/Release-v2.0--PRO-brightgreen.svg?style=for-the-badge&logo=github)](https://github.com/miyatimusica/ryzen-dylib-fix/releases)

*Solución nativa sin modificación invasiva de binarios para corregir cierres imprevistos (*Kernel Panics*), parpadeos (*flickering*) e inestabilidad gráfica en aplicaciones basadas en Chromium y Electron ejecutadas en Ryzentosh (AMD Ryzen iGPU) con `NootEDred.kext`.*

---

</div> 

## 🛠️ ¿Cómo funciona?

El proyecto se compone de dos herramientas independientes diseñadas para abordar diferentes capas del sistema operativo:

1. **Parche Global de Sesión (`ryzen-chromium-fix.sh`):**
   - Aplica políticas Enterprise nativas (`defaults write`) para navegadores Chromium (`com.brave.Browser`, `com.google.Chrome`, etc.).
   - Registra un `LaunchAgent` permanente que mantiene activa la variable de entorno `ELECTRON_EXTRA_LAUNCH_ARGS` en la sesión del usuario de macOS.

2. **Creador de Ryzentosh App Fixer (`Ryzentosh App Fixer.sh`):**
   - Compila e instala la aplicación gráfica `Ryzentosh App Fixer.app` en tu carpeta `/Applications` y Launchpad.
   - Realiza un escaneo profundo en carpetas y subcarpetas para identificar aplicaciones Electron/Chromium rebeldes e insensibles a variables globales.
   - Reemplaza de forma segura el ejecutable por un *wrapper* de protección GPU dinámico (`basename "$0".orig`) y re-firma el paquete localmente con `codesign`.

---

## 🚩 Flags Aplicados

| Flag / Parámetro | Propósito & Impacto Gráfico | Aplicado en |
| :--- | :--- | :--- |
| `--use-gl=angle` | Forzar el backend OpenGL ANGLE | Global & Wrapper |
| `--use-angle=gl` | Renderizado OpenGL directo | Global & Wrapper |
| `--disable-features=SkiaGraphite,SkiaGraphiteDawn` | Deshabilitar Skia Graphite (incompatible en Ryzentosh) | Global & Wrapper |
| `--disable-gpu-sandbox` | Evitar bloqueos de aislamiento GPU | Global & Wrapper |
| `--disable-gpu` | Renderizado de contingencia seguro por software | Wrapper (Ryzentosh App Fixer) |

---

## ⚡ Instalación y Ejecución

Los dos archivos `.sh` del repositorio son independientes y se ejecutan por separado desde la Terminal:

### 1️⃣ Parche Global del Sistema (`ryzen-chromium-fix.sh`)

Ejecuta este comando para aplicar las políticas de sesión globales para navegadores y aplicaciones Electron estándar:

```bash
curl -fsSL https://raw.githubusercontent.com/miyatimusica/ryzen-chromium-fix/main/ryzen-chromium-fix.sh | zsh
```

### 2️⃣ Instalador de la App Reparadora (`Ryzentosh App Fixer.sh`)

Ejecuta este comando para instalar la herramienta interactiva `Ryzentosh App Fixer.app` en tu carpeta `/Applications` y Launchpad:

```bash
curl -fsSL https://raw.githubusercontent.com/miyatimusica/ryzen-chromium-fix/main/Ryzentosh%20App%20Fixer.sh | zsh
```

---

## 🖥️ Uso de Ryzentosh App Fixer (`.app`)

Una vez ejecutado el script de instalación, la aplicación `Ryzentosh App Fixer.app` quedará disponible en tu Launchpad.

1. **Apertura:** Abre `Ryzentosh App Fixer` desde tu Launchpad o desde la carpeta `/Applications`.
2. **Permisos:** Ingresa tu contraseña de administrador cuando la Terminal lo solicite para permitir la modificación y re-firma local.
3. **Escaneo Automático:** La herramienta examinará automáticamente tus carpetas de aplicaciones (`/Applications` y `~/Applications`).
4. **Filtrado Inteligente:** Detectará qué aplicaciones utilizan arquitectura Electron/Chromium, omitirá las previamente parcheadas y aplicará el *wrapper* dinámico únicamente a las apps vulnerables.
5. **Completado:** Verás un resumen detallado con todas las aplicaciones reparadas con éxito durante la sesión.

---

## 🔍 Verificación

Para comprobar que la política global para Electron está cargada en la sesión activa del sistema:

```bash
launchctl getenv ELECTRON_EXTRA_LAUNCH_ARGS
```

**Resultado esperado:**
```text
--use-gl=angle --use-angle=gl --disable-features=SkiaGraphite,SkiaGraphiteDawn --disable-gpu-sandbox
```

---

## 💻 Aplicaciones Soportadas

- **Navegadores:** Brave, Google Chrome, Microsoft Edge, Arc, Vivaldi, Opera.
- **Aplicaciones Electron:** Visual Studio Code, Cursor, Discord, Slack, Spotify, Obsidian, Notion, Teams.

---

## 🗑️ Desinstalación

Para revertir las configuraciones globales y eliminar la aplicación del sistema:

```bash
# 1. Remover LaunchAgent y políticas globales
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

# 3. Eliminar la aplicación
sudo rm -rf "/Applications/Ryzentosh App Fixer.app"
```

---

## 🤝 Contribuciones y Soporte

¡Las contribuciones, reportes de errores y sugerencias son altamente bienvenidos!

Si este proyecto te ha sido útil para ejecutar software de producción musical en tu Ryzentosh, considera darle una ⭐️ **Estrella (Star)** al repositorio en GitHub.

---

## 📄 Licencia

Distribuido bajo la Licencia **MIT**. Consulta el archivo [`LICENSE`](LICENSE) para más detalles.

---

<div align="center">

*Desarrollado con ❤️ para la comunidad de **Ryzentosh** y **Hackintosh**.*

</div>
