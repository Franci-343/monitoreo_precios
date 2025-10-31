# ✅ Checklist de Implementación - Supabase

## 📋 Fase 1: Configuración de Supabase

### 1.1 Crear Proyecto
- [ ] Ir a https://supabase.com
- [ ] Crear cuenta o iniciar sesión
- [ ] Click en "New Project"
- [ ] Configurar:
  - [ ] Name: `monitoreo-precios-lapaz`
  - [ ] Database Password: *(guardar en lugar seguro)*
  - [ ] Region: `South America (São Paulo)`
  - [ ] Pricing Plan: `Free`
- [ ] Esperar a que el proyecto se inicialice (~2 minutos)

### 1.2 Ejecutar Script de Base de Datos
- [ ] En Supabase Dashboard, ir a **SQL Editor**
- [ ] Click en "New Query"
- [ ] Abrir archivo `database/setup.sql`
- [ ] Copiar TODO el contenido
- [ ] Pegar en el SQL Editor
- [ ] Click en **"Run"** (o `Ctrl + Enter`)
- [ ] Verificar que dice "Success" ✅

### 1.3 Verificar Instalación
- [ ] Ejecutar estas consultas de verificación:

```sql
-- Debe retornar 8 tablas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Debe retornar 8 categorías
SELECT COUNT(*) FROM categorias;

-- Debe retornar 10 mercados
SELECT COUNT(*) FROM mercados;

-- Debe retornar 31 productos
SELECT COUNT(*) FROM productos;
```

### 1.4 Configurar Autenticación
- [ ] Ir a **Authentication** → **Settings**
- [ ] Verificar que **Email** está habilitado
- [ ] (Opcional para desarrollo) Desactivar "Enable email confirmations"
- [ ] (Opcional) Personalizar templates de email

### 1.5 Obtener Credenciales
- [ ] Ir a **Settings** → **API**
- [ ] Copiar y guardar:
  - [ ] **Project URL**: `https://xxxxx.supabase.co`
  - [ ] **anon public key**: `eyJhbGc...`

---

## 📱 Fase 2: Configuración de Flutter

### 2.1 Actualizar pubspec.yaml
- [ ] Abrir `pubspec.yaml`
- [ ] Agregar dependencias:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  flutter_dotenv: ^5.1.0

flutter:
  assets:
    - .env
```

- [ ] Ejecutar: `flutter pub get`
- [ ] Verificar que no hay errores

### 2.2 Configurar Variables de Entorno
- [ ] Copiar `.env.example` y renombrar a `.env`
- [ ] Abrir `.env`
- [ ] Reemplazar con tus credenciales reales:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-real
```

- [ ] Guardar archivo
- [ ] Verificar que `.env` está en `.gitignore` ✅ (ya está)

### 2.3 Inicializar Supabase en main.dart
- [ ] Abrir `lib/main.dart`
- [ ] Agregar imports:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
```

- [ ] Modificar función `main()`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const MonitoreoPreciosApp());
}
```

- [ ] Agregar helper global (después de imports):

```dart
final supabase = Supabase.instance.client;
```

- [ ] Guardar y verificar que compila sin errores

---

## 🔐 Fase 3: Implementar Autenticación

### 3.1 Implementar AuthService
- [ ] Crear/actualizar `lib/services/auth_service.dart`
- [ ] Copiar código de `database/IMPLEMENTACION.md` sección "Paso 4"
- [ ] Verificar imports
- [ ] Guardar archivo

### 3.2 Actualizar LoginView
- [ ] Abrir `lib/views/login_view.dart`
- [ ] Importar: `import '../services/auth_service.dart';`
- [ ] Agregar: `final _authService = AuthService();`
- [ ] Modificar método `_submit()` para usar el servicio real
- [ ] Manejar errores con try-catch
- [ ] Probar que compila

### 3.3 Actualizar RegisterView
- [ ] Abrir `lib/views/register_view.dart`
- [ ] Importar: `import '../services/auth_service.dart';`
- [ ] Agregar: `final _authService = AuthService();`
- [ ] Modificar método `_submit()` para usar el servicio real
- [ ] Manejar errores con try-catch
- [ ] Probar que compila

### 3.4 Crear AuthStateWidget (Opcional pero recomendado)
- [ ] Crear `lib/widgets/auth_state_widget.dart`
- [ ] Copiar código de `database/IMPLEMENTACION.md` sección "Paso 8"
- [ ] En `main.dart`, cambiar:
  ```dart
  home: const AuthStateWidget(),
  ```
- [ ] Verificar que compila

---

## 🧪 Fase 4: Pruebas de Autenticación

### 4.1 Probar Registro
- [ ] Ejecutar app: `flutter run`
- [ ] Ir a pantalla de registro
- [ ] Llenar formulario con datos de prueba:
  - Nombre: `Test User`
  - Email: `test@example.com`
  - Password: `123456`
- [ ] Click en "Registrarse"
- [ ] Verificar que:
  - [ ] No hay errores
  - [ ] Vuelve a login con email prellenado
  - [ ] En Supabase Dashboard > Authentication > Users, aparece el usuario

### 4.2 Probar Login
- [ ] En pantalla de login
- [ ] Ingresar:
  - Email: `test@example.com`
  - Password: `123456`
- [ ] Click en "Ingresar"
- [ ] Verificar que:
  - [ ] No hay errores
  - [ ] Navega a HomeView
  - [ ] Usuario está autenticado

### 4.3 Verificar Perfil en Base de Datos
- [ ] En Supabase Dashboard > SQL Editor
- [ ] Ejecutar:

```sql
SELECT * FROM usuarios;
```

- [ ] Verificar que:
  - [ ] Aparece el usuario registrado
  - [ ] Tiene nombre y email correctos
  - [ ] `created_at` y `updated_at` tienen valores

### 4.4 Probar Cierre de Sesión
- [ ] En la app, buscar botón de cerrar sesión
- [ ] Click en cerrar sesión
- [ ] Verificar que vuelve a LoginView

---

## 📊 Fase 5: Implementar Servicios CRUD

### 5.1 ProductoService
- [ ] Crear `lib/services/producto_service.dart`
- [ ] Implementar métodos:
  - [ ] `getProductos()`
  - [ ] `buscarProductos(String query)`
  - [ ] `getProductosPorCategoria(int id)`
- [ ] Probar cada método

### 5.2 FavoritoService
- [ ] Crear `lib/services/favorito_service.dart`
- [ ] Implementar métodos:
  - [ ] `getFavoritos()`
  - [ ] `agregarFavorito(int productoId)`
  - [ ] `eliminarFavorito(int id)`
  - [ ] `esFavorito(int productoId)`
- [ ] Probar cada método

### 5.3 PrecioService
- [ ] Crear `lib/services/precio_service.dart`
- [ ] Implementar métodos:
  - [ ] `getPreciosProducto(int productoId)`
  - [ ] `getPrecioActual(int productoId, int mercadoId)`
  - [ ] `compararPrecios(int productoId)`
- [ ] Probar cada método

### 5.4 ReporteService
- [ ] Crear `lib/services/reporte_service.dart`
- [ ] Implementar métodos:
  - [ ] `crearReporte(...)`
  - [ ] `getMisReportes()`
  - [ ] `getReportesPendientes()`
- [ ] Probar cada método

### 5.5 AlertaService
- [ ] Crear `lib/services/alerta_service.dart`
- [ ] Implementar métodos:
  - [ ] `crearAlerta(...)`
  - [ ] `getMisAlertas()`
  - [ ] `actualizarAlerta(...)`
  - [ ] `eliminarAlerta(int id)`
- [ ] Probar cada método

---

## 🎨 Fase 6: Actualizar Vistas

### 6.1 ProductoView
- [ ] Integrar `ProductoService`
- [ ] Mostrar productos desde Supabase
- [ ] Implementar búsqueda
- [ ] Implementar filtros por categoría
- [ ] Probar funcionalidad completa

### 6.2 FavoritosView
- [ ] Integrar `FavoritoService`
- [ ] Mostrar favoritos del usuario
- [ ] Agregar botón para eliminar
- [ ] Probar funcionalidad completa

### 6.3 ReporteView
- [ ] Integrar `ReporteService`
- [ ] Formulario para crear reporte
- [ ] Mostrar mis reportes
- [ ] Probar funcionalidad completa

### 6.4 PerfilView
- [ ] Integrar `AuthService`
- [ ] Mostrar datos del usuario
- [ ] Permitir editar perfil
- [ ] Botón de cerrar sesión
- [ ] Probar funcionalidad completa

### 6.5 ComparadorView
- [ ] Integrar `PrecioService`
- [ ] Comparar precios entre mercados
- [ ] Mostrar gráficas
- [ ] Probar funcionalidad completa

---

## ✅ Fase 7: Verificación Final

### 7.1 Pruebas Funcionales
- [ ] Registro de usuario funciona
- [ ] Login funciona
- [ ] Cierre de sesión funciona
- [ ] Ver productos funciona
- [ ] Buscar productos funciona
- [ ] Agregar favoritos funciona
- [ ] Ver favoritos funciona
- [ ] Eliminar favoritos funciona
- [ ] Crear reporte funciona
- [ ] Ver reportes funciona
- [ ] Comparar precios funciona
- [ ] Ver/editar perfil funciona

### 7.2 Pruebas de Seguridad
- [ ] Usuario solo ve sus favoritos
- [ ] Usuario solo ve sus reportes
- [ ] Usuario solo puede editar su perfil
- [ ] Usuarios no autenticados no pueden agregar favoritos
- [ ] RLS funcionando correctamente

### 7.3 Optimización
- [ ] No hay memory leaks
- [ ] Imágenes cargan correctamente
- [ ] La app no se cuelga
- [ ] Navegación es fluida
- [ ] Errores se manejan correctamente

---

## 📚 Recursos de Ayuda

- [ ] Revisar `database/RESUMEN.md` para overview
- [ ] Revisar `database/supabase_schema.md` para detalles de BD
- [ ] Revisar `database/IMPLEMENTACION.md` para ejemplos de código
- [ ] Consultar [Supabase Docs](https://supabase.com/docs)
- [ ] Consultar [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)

---

## 🎯 Indicadores de Éxito

Al finalizar, deberías tener:

✅ Base de datos configurada en Supabase  
✅ Autenticación funcionando (registro, login, logout)  
✅ Usuarios pueden ver productos  
✅ Usuarios pueden agregar/ver favoritos  
✅ Usuarios pueden reportar precios  
✅ Usuarios pueden comparar precios  
✅ Sistema seguro con RLS  
✅ App funcional y estable  

---

**Nota**: Este checklist es secuencial. Completa cada fase antes de avanzar a la siguiente.

**Tiempo estimado**: 4-6 horas (dependiendo de experiencia)

**Dificultad**: Intermedia

---

¡Buena suerte con la implementación! 🚀
