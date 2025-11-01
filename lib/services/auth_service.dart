import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';
import '../main.dart';

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
      print('🔐 Intentando registrar usuario: $email');

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'nombre': nombre},
        emailRedirectTo: null, // Desactivar redirect de confirmación
      );

      if (response.user != null) {
        print('✅ Usuario registrado exitosamente: ${response.user!.id}');

        // Esperar un momento para que el trigger cree el perfil
        await Future.delayed(const Duration(milliseconds: 500));

        // Obtener el perfil del usuario
        final perfil = await getUsuarioPerfil(response.user!.id);
        print('✅ Perfil de usuario obtenido');
        return perfil;
      }

      print('⚠️ No se pudo obtener el usuario después del registro');
      return null;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');

      // Mejorar mensajes de error comunes
      if (e.message.contains('already registered') ||
          e.message.contains('already exists')) {
        throw Exception(
          'Este email ya está registrado. Intenta iniciar sesión.',
        );
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception(
          'Debes confirmar tu email. Revisa tu bandeja de entrada.',
        );
      }

      throw Exception('Error al registrar: ${e.message}');
    } catch (e) {
      print('❌ Error inesperado: $e');
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
      print('🔐 Intentando iniciar sesión: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Sesión iniciada exitosamente: ${response.user!.id}');
        final perfil = await getUsuarioPerfil(response.user!.id);
        print('✅ Perfil de usuario obtenido');
        return perfil;
      }

      print('⚠️ No se pudo obtener el usuario después del login');
      return null;
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');

      // Mejorar mensajes de error comunes
      if (e.message.contains('Email not confirmed')) {
        throw Exception(
          'Tu email no está confirmado.\n\n'
          'SOLUCIÓN:\n'
          '1. Ve al Dashboard de Supabase\n'
          '2. Authentication → Settings\n'
          '3. Desactiva "Enable email confirmations"\n'
          '4. Elimina tu usuario y regístrate de nuevo\n\n'
          'O revisa tu email para confirmar tu cuenta.',
        );
      } else if (e.message.contains('Invalid login credentials')) {
        throw Exception('Email o contraseña incorrectos');
      }

      throw Exception('Error al iniciar sesión: ${e.message}');
    } catch (e) {
      print('❌ Error inesperado: $e');
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
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception('Error al cambiar contraseña: ${e.message}');
    }
  }

  // ============================================
  // ELIMINAR CUENTA
  // ============================================
  Future<void> eliminarCuenta() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      print('🗑️ Eliminando cuenta del usuario: ${user.id}');

      // Llamar a la función de base de datos que tiene privilegios elevados
      // Esta función eliminará:
      // 1. El perfil de la tabla usuarios
      // 2. Todos los favoritos (CASCADE)
      // 3. Todos los reportes (CASCADE)
      // 4. Todas las alertas (CASCADE)
      // 5. El usuario de auth.users
      await supabase.rpc('eliminar_cuenta_usuario');

      print('✅ Cuenta eliminada completamente');

      // Cerrar sesión localmente
      await signOut();

      print('✅ Sesión cerrada');
    } catch (e) {
      print('❌ Error al eliminar cuenta: $e');

      // Proporcionar un mensaje más descriptivo
      if (e.toString().contains(
            'function eliminar_cuenta_usuario() does not exist',
          ) ||
          e.toString().contains('could not find the function')) {
        throw Exception(
          'La función de eliminación no está disponible.\n\n'
          'SOLUCIÓN:\n'
          '1. Ve al SQL Editor de Supabase\n'
          '2. Ejecuta el archivo database/eliminar_cuenta_function.sql\n'
          '3. Intenta eliminar la cuenta nuevamente\n\n'
          'Error técnico: $e',
        );
      }

      throw Exception('Error al eliminar cuenta: $e');
    }
  }

  // ============================================
  // STREAM DE CAMBIOS DE AUTENTICACIÓN
  // ============================================
  Stream<AuthState> get authStateChanges {
    return supabase.auth.onAuthStateChange;
  }
}
