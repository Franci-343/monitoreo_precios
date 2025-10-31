# 🗄️ Base de Datos - Monitoreo de Precios

Este directorio contiene toda la documentación y scripts SQL para la base de datos del sistema de monitoreo de precios.

## 📁 Archivos

| Archivo | Descripción |
|---------|-------------|
| `setup.sql` | **Script principal** - Crea toda la estructura de BD |
| `supabase_schema.md` | Documentación detallada del esquema |
| `diagrama_er.md` | Diagrama Entidad-Relación visual |
| `README.md` | Este archivo - Guía rápida |

## 🚀 Instalación Rápida

### Paso 1: Crear Proyecto en Supabase

1. Ve a [https://supabase.com](https://supabase.com)
2. Crea una cuenta o inicia sesión
3. Click en "New Project"
4. Completa:
   - **Name**: monitoreo-precios-lapaz
   - **Database Password**: *(guarda esta contraseña)*
   - **Region**: South America (São Paulo) - *más cercano a Bolivia*
   - **Pricing Plan**: Free

### Paso 2: Ejecutar Script SQL

1. En el dashboard de Supabase, ve a **SQL Editor** (icono de base de datos)
2. Click en "New Query"
3. Abre el archivo `setup.sql` de este directorio
4. **Copia TODO el contenido** del archivo
5. **Pega** en el editor SQL de Supabase
6. Click en **"Run"** o presiona `Ctrl + Enter`
7. Espera a que termine (verás "Success" en cada sección)

### Paso 3: Verificar Instalación

Ejecuta esta consulta para verificar que todo se creó correctamente:

```sql
-- Verificar tablas creadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verificar datos iniciales
SELECT * FROM categorias;
SELECT * FROM mercados;
SELECT COUNT(*) as total_productos FROM productos;
```

Deberías ver:
- ✅ 8 tablas creadas
- ✅ 8 categorías
- ✅ 10 mercados
- ✅ 31 productos

### Paso 4: Configurar Autenticación

1. Ve a **Authentication** → **Settings**
2. En **Auth Providers**, verifica que **Email** esté habilitado
3. En **Email Templates**, personaliza si deseas:
   - Confirm signup
   - Reset password
4. (Opcional) Desactiva "Enable email confirmations" para desarrollo

### Paso 5: Obtener Credenciales

1. Ve a **Settings** → **API**
2. Copia y guarda:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGc...` (es seguro compartir esta)

## 🔐 Configuración en Flutter

### 1. Instalar dependencias

Abre `pubspec.yaml` y agrega:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  flutter_dotenv: ^5.1.0
```

Luego ejecuta:
```bash
flutter pub get
```

### 2. Crear archivo de variables de entorno

Crea `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui
```

**⚠️ IMPORTANTE**: Agrega `.env` a tu `.gitignore`

### 3. Inicializar Supabase en tu app

Modifica `lib/main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const MonitoreoPreciosApp());
}

// Helper global para acceder a Supabase
final supabase = Supabase.instance.client;
```

## 🧪 Pruebas de Autenticación

### Registrar un usuario (desde Flutter)

```dart
Future<void> signUp(String email, String password, String nombre) async {
  final response = await supabase.auth.signUp(
    email: email,
    password: password,
    data: {'nombre': nombre}, // Se guarda en usuarios.nombre automáticamente
  );
  
  if (response.user != null) {
    print('Usuario registrado: ${response.user!.id}');
  }
}
```

### Iniciar sesión

```dart
Future<void> signIn(String email, String password) async {
  final response = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  
  if (response.user != null) {
    print('Sesión iniciada: ${response.user!.email}');
  }
}
```

### Cerrar sesión

```dart
Future<void> signOut() async {
  await supabase.auth.signOut();
}
```

### Obtener usuario actual

```dart
User? getCurrentUser() {
  return supabase.auth.currentUser;
}
```

## 📊 Estructura de la Base de Datos

```
┌──────────────┐
│   Usuarios   │ ← Autenticación con email/contraseña
└──────┬───────┘
       │
   ┌───┴───┬──────────┬──────────┐
   │       │          │          │
   ▼       ▼          ▼          ▼
Favoritos Reportes  Alertas  Precios
   │       │          │          │
   └───────┴──────────┴──────────┘
           │
           ▼
      ┌────────────┐
      │ Productos  │
      └─────┬──────┘
            │
    ┌───────┴────────┐
    ▼                ▼
Categorías       Mercados
```

## 🔍 Consultas Útiles

### Ver todos los productos con su categoría

```sql
SELECT 
  p.id, 
  p.nombre AS producto,
  c.nombre AS categoria,
  p.unidad_medida
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.activo = TRUE
ORDER BY c.orden, p.nombre;
```

### Precios actuales de un producto

```sql
SELECT 
  m.nombre AS mercado,
  m.zona,
  p.precio,
  p.fecha_actualizacion
FROM precios p
JOIN mercados m ON p.mercado_id = m.id
WHERE p.producto_id = 1 -- ID del producto
ORDER BY p.fecha_actualizacion DESC
LIMIT 10;
```

### Productos favoritos de un usuario

```sql
SELECT 
  p.nombre,
  c.nombre AS categoria,
  f.created_at
FROM favoritos f
JOIN productos p ON f.producto_id = p.id
JOIN categorias c ON p.categoria_id = c.id
WHERE f.usuario_id = 'uuid-del-usuario'
ORDER BY f.created_at DESC;
```

## 🛡️ Seguridad (RLS)

La base de datos usa **Row Level Security (RLS)** para proteger los datos:

- ✅ **Públicos** (todos pueden leer): productos, categorías, mercados, precios
- 🔒 **Privados** (solo el dueño): perfil, favoritos, reportes, alertas
- 🔐 **Autenticados** (solo usuarios logueados): crear reportes, favoritos

**Esto significa que:**
- No puedes ver los favoritos de otros usuarios
- No puedes modificar el perfil de otros
- Las contraseñas NUNCA se almacenan en texto plano

## 📝 Próximos Pasos

Después de instalar la base de datos:

1. ✅ Actualizar modelos Dart (`lib/models/`)
2. ✅ Implementar `auth_service.dart`
3. ✅ Implementar servicios CRUD (productos, favoritos, etc.)
4. ✅ Actualizar las vistas para usar datos reales
5. ✅ Implementar sistema de alertas
6. ✅ Agregar caché local (opcional)

## 🆘 Solución de Problemas

### Error: "relation does not exist"
- Verifica que ejecutaste el script `setup.sql` completo
- Revisa en SQL Editor que las tablas se crearon correctamente

### Error: "new row violates row-level security policy"
- Asegúrate de que el usuario esté autenticado
- Verifica que las políticas RLS estén habilitadas correctamente

### No se crea el perfil automáticamente
- Verifica que el trigger `on_auth_user_created` exista
- Comprueba en la tabla `usuarios` si se creó el registro

### Para ver logs de la base de datos
1. Ve a **Database** → **Database Logs**
2. Filtra por errores o warnings

## 📚 Recursos

- [Documentación Supabase](https://supabase.com/docs)
- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [PostgreSQL Tutorial](https://www.postgresql.org/docs/)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

## 📧 Contacto

Si tienes dudas sobre la implementación de la base de datos, revisa:
- `supabase_schema.md` - Documentación completa
- `diagrama_er.md` - Diagrama de relaciones

---

**Estado**: ✅ Listo para implementar  
**Última actualización**: Octubre 2025  
**Versión**: 1.0
