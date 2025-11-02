# 📱 Instrucciones para Generar APK

## ⚠️ PASO IMPORTANTE ANTES DE COMPILAR

El APK necesita las credenciales de Supabase hardcodeadas porque el archivo `.env` NO se incluye en el build de release.

### 1️⃣ Obtener Credenciales de Supabase

1. Ve a: https://supabase.com/dashboard
2. Selecciona tu proyecto
3. Click en **Settings** (⚙️) en el menú lateral
4. Click en **API**
5. Copia estos dos valores:
   - **Project URL** (ejemplo: `https://xxxxxxxxxxxxx.supabase.co`)
   - **anon/public key** (una clave larga que empieza con `eyJ...`)

### 2️⃣ Configurar Credenciales en main.dart

Abre el archivo `lib/main.dart` y busca las líneas 19-20:

```dart
supabaseUrl = 'TU_SUPABASE_URL_AQUI';  // ⚠️ CAMBIA ESTO
supabaseKey = 'TU_SUPABASE_ANON_KEY_AQUI';  // ⚠️ CAMBIA ESTO
```

Reemplaza con tus credenciales reales:

```dart
supabaseUrl = 'https://xxxxxxxxxxxxx.supabase.co';
supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### 3️⃣ Compilar APK

```powershell
# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Compilar APK release
flutter build apk --release
```

### 4️⃣ Ubicación del APK

El APK estará en:
```
build\app\outputs\flutter-apk\app-release.apk
```

### 5️⃣ Instalar en tu teléfono

Opción A - Por USB:
```powershell
flutter install
```

Opción B - Manual:
1. Copia `app-release.apk` a tu teléfono
2. Abre el archivo en tu teléfono
3. Permite instalación de fuentes desconocidas si lo pide

---

## 🔒 Seguridad

**IMPORTANTE**: La `anon key` es PÚBLICA y está diseñada para usarse en apps móviles. La seguridad real está en las políticas RLS de Supabase.

**NO SUBAS A GIT** si tienes credenciales sensibles. El `.gitignore` ya protege el `.env`, pero `main.dart` SÍ se sube.

### Solución Alternativa (Más Segura)

Si no quieres hardcodear en `main.dart`, usa variables de compilación:

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_KEY=eyJxxx
```

Y en `main.dart`:
```dart
supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
supabaseKey = const String.fromEnvironment('SUPABASE_KEY');
```

---

## 🐛 Solución de Problemas

### Error: "SocketException: Failed host lookup"
- **Causa**: Credenciales no configuradas o incorrectas en el APK
- **Solución**: Verificar que las credenciales en `main.dart` sean correctas

### Error: "Invalid API key"
- **Causa**: La anon key es incorrecta
- **Solución**: Copiar nuevamente desde el dashboard de Supabase

### El APK funciona pero no el admin panel
- **Causa**: Faltan ejecutar scripts SQL en Supabase
- **Solución**: Ejecutar `database/fix_solo_mercados.sql` en SQL Editor

---

## ✅ Checklist Final

- [ ] Credenciales configuradas en `main.dart`
- [ ] `flutter clean` ejecutado
- [ ] `flutter pub get` ejecutado
- [ ] `flutter build apk --release` completado
- [ ] APK instalado en el teléfono
- [ ] Scripts SQL ejecutados en Supabase:
  - [ ] `fix_admin_todo_en_uno.sql` (productos)
  - [ ] `fix_admin_usuarios_correcto.sql` (usuarios)
  - [ ] `fix_solo_mercados.sql` (mercados)
- [ ] Prueba de login funciona
- [ ] Prueba de panel admin funciona

