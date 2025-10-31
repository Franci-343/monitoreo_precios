# 🔌 Guía de Implementación con Supabase

Esta guía muestra **cómo implementar** Supabase en tu proyecto Flutter cuando decidas hacerlo.

## 📦 Paso 1: Instalación de Dependencias

Abre `pubspec.yaml` y agrega estas dependencias:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Supabase para Flutter
  supabase_flutter: ^2.0.0
  
  # Variables de entorno (para guardar credenciales de forma segura)
  flutter_dotenv: ^5.1.0

# También agrega el archivo .env a los assets
flutter:
  assets:
    - .env
```

Luego ejecuta:
```bash
flutter pub get
```

---

## 🔐 Paso 2: Configurar Variables de Entorno

### Crear archivo `.env` en la raíz del proyecto:

```env
# Credenciales de Supabase
# Obtén estos valores del dashboard de Supabase (Settings > API)
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Agregar `.env` al `.gitignore`:

```gitignore
# Archivo de variables de entorno (contiene secrets)
.env
```

---

## 🚀 Paso 3: Inicializar Supabase en `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:monitoreo_precios/views/login_view.dart';

// Helper global para acceder a Supabase fácilmente
final supabase = Supabase.instance.client;

Future<void> main() async {
  // Asegurar que Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: ".env");
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Más seguro
    ),
  );
  
  runApp(const MonitoreoPreciosApp());
}

class MonitoreoPreciosApp extends StatelessWidget {
  const MonitoreoPreciosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoreo de Precios - La Paz',
      debugShowCheckedModeBanner: false,
      theme: _buildWeb3Theme(),
      home: const LoginView(),
    );
  }
  
  // ... resto del código del theme
}
```

---

## 🔑 Paso 4: Implementar `auth_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';
import '../main.dart'; // Para acceder a 'supabase'

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ============================================
  // REGISTRO DE USUARIO
  // ============================================
  Future<Usuario?> signUp({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre': nombre, // Se guarda en el perfil automáticamente
        },
      );

      if (response.user != null) {
        // Esperar un momento para que el trigger cree el perfil
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Obtener el perfil del usuario
        return await getUsuarioPerfil(response.user!.id);
      }
      
      return null;
    } on AuthException catch (e) {
      throw Exception('Error al registrar: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ============================================
  // INICIO DE SESIÓN
  // ============================================
  Future<Usuario?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return await getUsuarioPerfil(response.user!.id);
      }
      
      return null;
    } on AuthException catch (e) {
      throw Exception('Error al iniciar sesión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ============================================
  // CERRAR SESIÓN
  // ============================================
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // ============================================
  // OBTENER USUARIO ACTUAL
  // ============================================
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // ============================================
  // VERIFICAR SI ESTÁ AUTENTICADO
  // ============================================
  bool isAuthenticated() {
    return supabase.auth.currentUser != null;
  }

  // ============================================
  // OBTENER PERFIL DEL USUARIO
  // ============================================
  Future<Usuario?> getUsuarioPerfil(String userId) async {
    try {
      final response = await supabase
          .from('usuarios')
          .select()
          .eq('id', userId)
          .single();

      return Usuario.fromMap(response);
    } catch (e) {
      print('Error al obtener perfil: $e');
      return null;
    }
  }

  // ============================================
  // ACTUALIZAR PERFIL
  // ============================================
  Future<Usuario?> updatePerfil({
    required String userId,
    String? nombre,
    String? telefono,
    String? zonaPreferida,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nombre != null) updates['nombre'] = nombre;
      if (telefono != null) updates['telefono'] = telefono;
      if (zonaPreferida != null) updates['zona_preferida'] = zonaPreferida;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await supabase
          .from('usuarios')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return Usuario.fromMap(response);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // ============================================
  // RECUPERAR CONTRASEÑA
  // ============================================
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Error al recuperar contraseña: ${e.message}');
    }
  }

  // ============================================
  // CAMBIAR CONTRASEÑA
  // ============================================
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Error al cambiar contraseña: ${e.message}');
    }
  }

  // ============================================
  // STREAM DE CAMBIOS DE AUTENTICACIÓN
  // ============================================
  Stream<AuthState> get authStateChanges {
    return supabase.auth.onAuthStateChange;
  }
}
```

---

## 🎨 Paso 5: Actualizar `login_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:monitoreo_precios/services/auth_service.dart';
import 'package:monitoreo_precios/views/register_view.dart';
import 'package:monitoreo_precios/views/home_view.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final usuario = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      
      if (usuario != null) {
        // Ir a pantalla principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeView()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... resto del código de la UI (mantener igual)
    // Solo cambiar la llamada a _submit para usar el servicio real
  }
}
```

---

## 📝 Paso 6: Actualizar `register_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:monitoreo_precios/services/auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);

    try {
      final usuario = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nombre: _nameController.text.trim(),
      );

      if (!mounted) return;
      
      if (usuario != null) {
        // Volver al login con el email pre-rellenado
        Navigator.of(context).pop(_emailController.text.trim());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... resto del código de la UI (mantener igual)
  }
}
```

---

## 🧪 Paso 7: Ejemplo de Uso en Otros Servicios

### `producto_service.dart`

```dart
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/main.dart';

class ProductoService {
  // Obtener todos los productos
  Future<List<Producto>> getProductos() async {
    final response = await supabase
        .from('productos')
        .select('*')
        .eq('activo', true)
        .order('nombre');

    return (response as List)
        .map((json) => Producto.fromMap(json))
        .toList();
  }

  // Buscar productos por nombre
  Future<List<Producto>> buscarProductos(String query) async {
    final response = await supabase
        .from('productos')
        .select('*')
        .ilike('nombre', '%$query%')
        .eq('activo', true)
        .order('nombre');

    return (response as List)
        .map((json) => Producto.fromMap(json))
        .toList();
  }

  // Obtener productos por categoría
  Future<List<Producto>> getProductosPorCategoria(int categoriaId) async {
    final response = await supabase
        .from('productos')
        .select('*')
        .eq('categoria_id', categoriaId)
        .eq('activo', true)
        .order('nombre');

    return (response as List)
        .map((json) => Producto.fromMap(json))
        .toList();
  }
}
```

### `favorito_service.dart`

```dart
import 'package:monitoreo_precios/models/favorito_model.dart';
import 'package:monitoreo_precios/services/auth_service.dart';
import 'package:monitoreo_precios/main.dart';

class FavoritoService {
  final _authService = AuthService();

  // Obtener favoritos del usuario actual
  Future<List<Favorito>> getFavoritos() async {
    final user = _authService.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    final response = await supabase
        .from('favoritos')
        .select('*')
        .eq('usuario_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Favorito.fromMap(json))
        .toList();
  }

  // Agregar a favoritos
  Future<void> agregarFavorito(int productoId) async {
    final user = _authService.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    await supabase.from('favoritos').insert({
      'usuario_id': user.id,
      'producto_id': productoId,
    });
  }

  // Eliminar de favoritos
  Future<void> eliminarFavorito(int favoritoId) async {
    await supabase
        .from('favoritos')
        .delete()
        .eq('id', favoritoId);
  }

  // Verificar si un producto es favorito
  Future<bool> esFavorito(int productoId) async {
    final user = _authService.getCurrentUser();
    if (user == null) return false;

    final response = await supabase
        .from('favoritos')
        .select()
        .eq('usuario_id', user.id)
        .eq('producto_id', productoId)
        .maybeSingle();

    return response != null;
  }
}
```

---

## 🔄 Paso 8: Manejo de Estados de Autenticación

### Crear un `AuthStateWidget` para detectar cambios

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:monitoreo_precios/views/login_view.dart';
import 'package:monitoreo_precios/views/home_view.dart';
import 'package:monitoreo_precios/main.dart';

class AuthStateWidget extends StatelessWidget {
  const AuthStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const HomeView();
        } else {
          return const LoginView();
        }
      },
    );
  }
}
```

Luego en `main.dart`, cambia:
```dart
home: const AuthStateWidget(), // En lugar de LoginView()
```

---

## ✅ Checklist de Implementación

Cuando decidas implementar Supabase, sigue este orden:

- [ ] 1. Crear proyecto en Supabase
- [ ] 2. Ejecutar `setup.sql` en SQL Editor
- [ ] 3. Verificar que las tablas se crearon correctamente
- [ ] 4. Agregar dependencias en `pubspec.yaml`
- [ ] 5. Crear archivo `.env` con credenciales
- [ ] 6. Agregar `.env` a `.gitignore`
- [ ] 7. Inicializar Supabase en `main.dart`
- [ ] 8. Implementar `auth_service.dart`
- [ ] 9. Actualizar `login_view.dart`
- [ ] 10. Actualizar `register_view.dart`
- [ ] 11. Crear `AuthStateWidget`
- [ ] 12. Implementar servicios CRUD (productos, favoritos, etc.)
- [ ] 13. Probar registro de usuario
- [ ] 14. Probar inicio de sesión
- [ ] 15. Probar funcionalidades (favoritos, reportes, etc.)

---

## 🎯 Próximos Servicios a Implementar

1. **ProductoService** - CRUD de productos
2. **FavoritoService** - Gestión de favoritos
3. **ReporteService** - Reportar precios
4. **PrecioService** - Consultar precios
5. **AlertaService** - Configurar alertas de precio

---

## 📚 Recursos Útiles

- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart/introduction)
- [Auth con Supabase](https://supabase.com/docs/guides/auth/auth-helpers/flutter)
- [RLS Policies](https://supabase.com/docs/guides/auth/row-level-security)
- [Realtime](https://supabase.com/docs/guides/realtime)

---

**Nota**: Este archivo es solo una guía de implementación. Los archivos reales (`auth_service.dart`, etc.) aún no están implementados según tu solicitud.
