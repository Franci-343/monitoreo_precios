# 🚀 Guía de Deploy a Vercel - Flutter Web

## Problema Común: Página en Blanco

Si ves una página en blanco después de hacer deploy, sigue estos pasos:

---

## ✅ Solución Paso a Paso

### 1. Configurar Variables de Entorno en Vercel

**IMPORTANTE:** No subas el archivo `.env` a GitHub. En su lugar, configura las variables en Vercel:

1. Ve a tu proyecto en Vercel Dashboard
2. Click en **Settings** → **Environment Variables**
3. Agrega estas variables:

```
SUPABASE_URL = https://ngxpkwvyceineasuigxz.supabase.co
SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5neHBrd3Z5Y2VpbmVhc3VpZ3h6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MDkzNDcsImV4cCI6MjA3NzQ4NTM0N30.aZV7IWgIhwk3D0Mnhb4SR-BbOJ9ZRQPDDffTTBQVmhM
```

4. Click en **Save**

---

### 2. Rebuild Local

Ejecuta estos comandos en tu terminal:

```bash
# Limpiar build anterior
flutter clean

# Rebuild para web
flutter build web --release --web-renderer canvaskit

# Verificar que .env esté en build/web
copy .env build\web\.env
```

---

### 3. Verificar archivos en build/web

Asegúrate de que existan estos archivos:

```
build/web/
  ├── index.html
  ├── main.dart.js
  ├── flutter.js
  ├── .env  ← IMPORTANTE
  ├── assets/
  └── canvaskit/
```

---

### 4. Push a GitHub

```bash
git add .
git commit -m "Configure Vercel deployment"
git push origin main
```

---

### 5. Redeploy en Vercel

Opción A - **Automático:**
- Vercel detectará el push y hará deploy automáticamente

Opción B - **Manual:**
1. Ve a tu proyecto en Vercel
2. Click en **Deployments**
3. Click en los 3 puntos del último deploy
4. Click en **Redeploy**

---

## 🔍 Verificar que funcione

Después del deploy:

1. **Abre la consola del navegador** (F12)
2. Ve a la pestaña **Console**
3. Busca los mensajes:
   ```
   📂 Cargando variables de entorno...
   ✅ Variables de entorno cargadas correctamente
   🔗 URL de Supabase: https://ngxpkwvyceineasuigxz.supabase.co
   ✅ ¡Conectado a Supabase exitosamente!
   ```

4. Si ves estos mensajes → ✅ **Funcionando correctamente**

5. Si ves errores → 🔍 **Lee el error y ajusta**

---

## ⚠️ Problemas Comunes

### Problema 1: "Failed to load .env file"

**Solución:**
```bash
# Copia .env a build/web
copy .env build\web\.env

# O usa variables de entorno de Vercel (recomendado)
# Settings → Environment Variables
```

---

### Problema 2: CORS Errors

**Solución:** Ya incluido en `vercel.json`:
```json
"headers": [
  {
    "key": "Cross-Origin-Embedder-Policy",
    "value": "credentialless"
  }
]
```

---

### Problema 3: Página en blanco sin errores

**Solución:**
```bash
# Rebuild con renderer HTML (más compatible)
flutter build web --release --web-renderer html
```

Luego en `vercel.json` cambia:
```json
"buildCommand": "flutter build web --release --web-renderer html"
```

---

## 🎯 Checklist Pre-Deploy

- [ ] `vercel.json` creado
- [ ] Variables de entorno configuradas en Vercel
- [ ] `flutter build web --release` ejecutado
- [ ] `.env` copiado a `build/web/` (o variables en Vercel)
- [ ] `build/web/` commiteado a Git
- [ ] Push a GitHub
- [ ] Vercel detecta y hace deploy
- [ ] Verificar en consola del navegador

---

## 🚀 Comandos Rápidos

```bash
# Build completo
flutter clean && flutter build web --release --web-renderer canvaskit && copy .env build\web\.env

# Verificar que funcione localmente
cd build/web
python -m http.server 8000
# Abre http://localhost:8000

# Subir a GitHub
git add .
git commit -m "Update web build"
git push origin main
```

---

## 📱 Alternativa: Deploy Manual

Si el deploy automático no funciona, puedes hacer deploy manual:

1. Build local: `flutter build web --release`
2. En Vercel Dashboard:
   - Click en **Add New** → **Project**
   - Click en **Continue with GitHub**
   - Selecciona tu repositorio
   - En **Framework Preset** selecciona **Other**
   - En **Build Command** deja vacío
   - En **Output Directory** escribe: `build/web`
   - Click en **Deploy**

---

## 🎨 Optimizaciones Opcionales

### Reducir tamaño del build:

```bash
flutter build web --release --tree-shake-icons --web-renderer canvaskit
```

### Usar renderer HTML (más rápido, menos visual):

```bash
flutter build web --release --web-renderer html
```

### Usar auto (elige el mejor según el navegador):

```bash
flutter build web --release --web-renderer auto
```

---

## 📊 Resultado Esperado

Después del deploy exitoso deberías ver:

✅ Login/Register funcionando
✅ Conexión a Supabase
✅ Búsqueda de productos
✅ Vista de favoritos
✅ Vista de perfil
✅ Comparador de precios

---

¿Necesitas más ayuda? Comparte:
- URL de tu deploy en Vercel
- Errores de la consola del navegador (F12)
- Logs del deploy en Vercel
