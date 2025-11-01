# 🔧 Solución: Habilitar Developer Mode para Flutter Web

## Problema

```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

---

## ✅ Solución Paso a Paso

### Opción 1: Habilitar desde Configuración (Recomendado)

1. **Abrir Configuración de Windows**
   - Presiona `Win + I`
   - O busca "Configuración" en el menú Inicio

2. **Ir a Privacy & Security (Privacidad y seguridad)**
   - Click en "Privacy & Security" en el menú lateral

3. **Activar Developer Mode**
   - Scroll hacia abajo
   - Click en "For developers" (Para desarrolladores)
   - Activa el toggle de "Developer Mode"
   - Confirma en el diálogo que aparece

4. **Reiniciar (opcional)**
   - Algunos cambios requieren reiniciar
   - Si no funciona sin reiniciar, reinicia Windows

---

### Opción 2: Desde PowerShell (Método Rápido)

Ejecuta este comando en PowerShell **como Administrador**:

```powershell
start ms-settings:developers
```

Luego activa "Developer Mode" en la ventana que se abre.

---

### Opción 3: Sin Developer Mode (Alternativa)

Si no puedes o no quieres activar Developer Mode, puedes:

**A) Usar el flag --no-native-plugins:**

```bash
flutter build web --release --no-native-plugins
```

**B) O crear un script que funcione sin symlinks:**

Crea `build_web.bat`:

```bat
@echo off
flutter pub get
flutter build web --release
if exist build\web (
    copy .env build\web\.env
    echo ✅ Build completado y .env copiado
) else (
    echo ❌ Error: build/web no existe
)
```

Luego ejecuta:

```bash
.\build_web.bat
```

---

## 🚀 Después de Habilitar Developer Mode

Ejecuta estos comandos:

```bash
# 1. Limpiar
flutter clean

# 2. Build para web
flutter build web --release

# 3. Copiar .env
copy .env build\web\.env

# 4. Verificar
dir build\web
```

Deberías ver:

```
build\web\
  ├── index.html
  ├── main.dart.js
  ├── flutter.js
  ├── .env  ← Debe estar aquí
  ├── assets\
  └── canvaskit\
```

---

## 📋 Checklist Completo para Deploy

- [ ] Developer Mode activado
- [ ] `flutter clean` ejecutado
- [ ] `flutter build web --release` exitoso
- [ ] `.env` copiado a `build/web/`
- [ ] Archivos verificados en `build/web/`
- [ ] `vercel.json` creado
- [ ] Git commit & push
- [ ] Variables de entorno en Vercel configuradas
- [ ] Deploy en Vercel

---

## 🎯 Comandos Todo-en-Uno

### Para Windows (PowerShell):

```powershell
# Build completo
flutter clean
flutter build web --release
if (Test-Path build\web) {
    Copy-Item .env build\web\.env
    Write-Host "✅ Build exitoso y .env copiado" -ForegroundColor Green
} else {
    Write-Host "❌ Error en build" -ForegroundColor Red
}
```

### Para verificar localmente:

```powershell
cd build\web
python -m http.server 8000
```

Luego abre: http://localhost:8000

---

## ⚠️ Notas Importantes

1. **Developer Mode es seguro** - Solo habilita features para desarrolladores

2. **No subas `.env` a GitHub** - Ya está en `.gitignore`

3. **Usa variables de entorno en Vercel** - Más seguro que incluir `.env` en el build

4. **Alternative para `.env` en Vercel:**
   - En lugar de copiar `.env`, configura las variables en Vercel Dashboard
   - Settings → Environment Variables
   - Agrega `SUPABASE_URL` y `SUPABASE_ANON_KEY`

---

¿Necesitas ayuda? Comparte:
- El error exacto que ves
- Tu versión de Windows
- Capturas de pantalla si es necesario
