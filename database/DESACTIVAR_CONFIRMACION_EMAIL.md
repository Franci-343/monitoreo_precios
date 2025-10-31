# 📧 Configurar Autenticación por Email en Supabase

## Problemas Comunes y Soluciones

### ❌ Error: "Email signups are disabled"

**Causa:** Los registros por email están desactivados en Supabase.

**Solución:**

1. **Dashboard de Supabase**
   ```
   https://supabase.com/dashboard
   ```

2. **Authentication → Settings → Auth Providers**

3. **Configurar Email Provider:**
   
   Busca la sección **"Email"** y configura:
   
   ```
   ✅ Enable email provider: ON
   ✅ Enable email signups: ON  ← IMPORTANTE!
   ❌ Enable email confirmations: OFF (para desarrollo)
   ✅ Confirm email: OFF
   ```

4. **Scroll down y click en "Save"**

---

### ❌ Error: "Email not confirmed"

**Causa:** La confirmación de email está activada pero no funciona en localhost.

**Solución:**

1. **Dashboard → Authentication → Settings → Auth Providers**

2. **En la sección Email:**
   ```
   ❌ Enable email confirmations: OFF
   ❌ Confirm email: OFF
   ```

3. **Eliminar usuarios sin confirmar:**
   - Ve a `Authentication` → `Users`
   - Busca tu usuario
   - Click en los 3 puntos → "Delete user"

4. **Regístrate de nuevo**
   - Ahora debería funcionar sin confirmación

---

## 🎯 Configuración Completa Paso a Paso

### PASO 1: Habilitar Email Provider

```
Dashboard Supabase
  └─ Authentication
      └─ Settings
          └─ Auth Providers
              └─ Email
                  ├─ ✅ Enable email provider (ON)
                  ├─ ✅ Enable email signups (ON)
                  ├─ ❌ Enable email confirmations (OFF)
                  └─ ❌ Confirm email (OFF)
```

### PASO 2: Configurar Opciones de Seguridad (Opcional)

Si quieres mayor seguridad en desarrollo:

```
Authentication → Settings → Auth
  ├─ Minimum password length: 6 (o el que prefieras)
  ├─ Enable signup: ✅ (permitir registros)
  └─ Enable phone signups: ❌ (solo email por ahora)
```

### PASO 3: Limpiar Usuarios Anteriores

Si ya intentaste registrarte y tienes usuarios sin confirmar:

```
Authentication → Users
  └─ Selecciona usuarios problemáticos
      └─ Click en "..." → Delete user
```

### PASO 4: Probar en la App

1. Ejecuta la app: `flutter run`
2. Intenta registrarte con:
   - Email: tu_email@gmail.com
   - Contraseña: mínimo 6 caracteres
   - Nombre: Tu Nombre

**Resultado esperado:**
```
📂 Cargando variables de entorno...
✅ Variables de entorno cargadas correctamente
🔗 URL de Supabase: https://ngxpkwvyceineasuigxz.supabase.co
🔑 Anon Key: eyJhbGciOiJIUzI1NiIsI...
🚀 Inicializando conexión con Supabase...
✅ ¡Conectado a Supabase exitosamente!
📊 Cliente Supabase disponible globalmente
✅ Verificación de DB: Se encontraron 8 categorías
🎨 Iniciando aplicación...
🔐 Intentando registrar usuario: tu_email@gmail.com
✅ Usuario registrado exitosamente: [UUID]
✅ Perfil de usuario obtenido
```

---

## 🚀 Checklist Rápido

Antes de registrarte, verifica:

- [ ] Email Provider está ENABLED
- [ ] Email signups está ENABLED ✅ **MUY IMPORTANTE**
- [ ] Email confirmations está DISABLED (para desarrollo)
- [ ] Confirm email está DISABLED
- [ ] Guardaste los cambios (botón "Save")
- [ ] Eliminaste usuarios anteriores sin confirmar

---

## 📸 Ubicación Visual

```
Supabase Dashboard
│
├── Authentication (menú lateral izquierdo)
│   │
│   ├── Users (lista de usuarios registrados)
│   │
│   ├── Settings
│   │   │
│   │   ├── Auth Providers ← AQUÍ ESTÁ LA CONFIGURACIÓN
│   │   │   │
│   │   │   ├── Email ← CONFIGURAR ESTE
│   │   │   │   ├── Enable email provider: ON
│   │   │   │   ├── Enable email signups: ON ← CLAVE!
│   │   │   │   ├── Enable email confirmations: OFF
│   │   │   │   └── Confirm email: OFF
│   │   │   │
│   │   │   ├── Phone (opcional)
│   │   │   └── External OAuth (Google, etc.)
│   │   │
│   │   └── Auth (configuración general)
│   │
│   └── Email Templates (plantillas de email)
│
└── Table Editor (ver tabla 'usuarios')
```

---

## ⚙️ Configuración para Producción (Futuro)

Cuando quieras activar confirmación de email:

### 1. Configurar SMTP
```
Authentication → Settings → SMTP Settings
  ├── SMTP Host: smtp.gmail.com (o tu proveedor)
  ├── Port: 587
  ├── Username: tu-email@gmail.com
  └── Password: [App Password]
```

### 2. Configurar URLs de Redirect
```
Authentication → URL Configuration
  ├── Site URL: https://tu-dominio.com
  └── Redirect URLs:
      ├── https://tu-dominio.com/auth/callback
      └── http://localhost:3000/auth/callback (para desarrollo)
```

### 3. Activar Confirmaciones
```
Auth Providers → Email
  ├── ✅ Enable email confirmations: ON
  └── ✅ Confirm email: ON
```

---

## 🎯 Resumen Ultra-Rápido (30 segundos)

```bash
1. Dashboard → Authentication → Settings → Auth Providers
2. Email → Enable email signups: ON
3. Email → Enable email confirmations: OFF
4. Save
5. Users → Eliminar usuarios sin confirmar
6. App → Registrarse → ✅ Funciona
```

