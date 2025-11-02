import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monitoreo_precios/views/login_view.dart';
import 'package:monitoreo_precios/views/favoritos_view.dart';
import 'package:monitoreo_precios/views/historial_view.dart';
import 'package:monitoreo_precios/views/alertas_view.dart';
import 'package:monitoreo_precios/views/producto_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Helper global para acceder a Supabase fácilmente
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de credenciales según el modo de compilación
  String? supabaseUrl;
  String? supabaseKey;

  // En modo release (APK), usar credenciales hardcodeadas
  // En modo debug, intentar cargar desde .env
  const isRelease = bool.fromEnvironment('dart.vm.product');

  if (isRelease) {
    // Modo RELEASE: Credenciales de producción
    print('📱 Modo RELEASE: Usando credenciales hardcodeadas');
    supabaseUrl = 'https://ngxpkwvyceineasuigxz.supabase.co';
    supabaseKey =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5neHBrd3Z5Y2VpbmVhc3VpZ3h6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MDkzNDcsImV4cCI6MjA3NzQ4NTM0N30.aZV7IWgIhwk3D0Mnhb4SR-BbOJ9ZRQPDDffTTBQVmhM';
  } else {
    // Modo debug: cargar desde .env
    print('💻 Modo DEBUG: Cargando variables de entorno...');
    await dotenv.load(fileName: ".env");
    print('✅ Variables de entorno cargadas correctamente');

    supabaseUrl = dotenv.env['SUPABASE_URL'];
    supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
  }

  if (supabaseUrl == null ||
      supabaseKey == null ||
      supabaseUrl == 'TU_SUPABASE_URL_AQUI' ||
      supabaseKey == 'TU_SUPABASE_ANON_KEY_AQUI') {
    print('❌ ERROR: Faltan credenciales de Supabase');
    print(
      '   SUPABASE_URL: ${supabaseUrl != null && supabaseUrl != 'TU_SUPABASE_URL_AQUI' ? "✓" : "✗"}',
    );
    print(
      '   SUPABASE_ANON_KEY: ${supabaseKey != null && supabaseKey != 'TU_SUPABASE_ANON_KEY_AQUI' ? "✓" : "✗"}',
    );
    print('');
    print(
      '⚠️  Para APK release: Edita lib/main.dart líneas 19-20 con tus credenciales',
    );
    return;
  }

  print('🔗 URL de Supabase: $supabaseUrl');
  print('🔑 Anon Key: ${supabaseKey.substring(0, 20)}...');

  // Inicializar Supabase
  print('🚀 Inicializando conexión con Supabase...');
  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
    print('✅ ¡Conectado a Supabase exitosamente!');
    print('📊 Cliente Supabase disponible globalmente');

    // Verificar conexión haciendo una consulta simple
    try {
      final response = await supabase
          .from('categorias')
          .select('count')
          .count();
      print(
        '✅ Verificación de DB: Se encontraron ${response.count} categorías',
      );
    } catch (e) {
      print('⚠️  Advertencia al verificar DB: $e');
    }
  } catch (e) {
    print('❌ ERROR al conectar con Supabase: $e');
    return;
  }

  print('🎨 Iniciando aplicación...');
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
      routes: {
        '/favoritos': (context) => const FavoritosView(),
        '/historial': (context) => const HistorialView(),
        '/alertas': (context) => const AlertasView(),
        '/productos': (context) => const ProductoView(),
      },
    );
  }

  ThemeData _buildWeb3Theme() {
    // Colores Web3 modernos
    const Color primaryGradientStart = Color(0xFF6366F1); // Indigo vibrante
    const Color primaryGradientEnd = Color(0xFF8B5CF6); // Púrpura
    const Color secondaryGradientStart = Color(0xFF06B6D4); // Cyan
    const Color secondaryGradientEnd = Color(0xFF3B82F6); // Azul
    const Color backgroundDark = Color(0xFF0F0F23); // Fondo oscuro
    const Color surfaceDark = Color(0xFF1A1A2E); // Superficie oscura
    const Color cardGlass = Color(0xFF16213E); // Cristal oscuro
    const Color accentNeon = Color(0xFF00FFF0); // Neon cyan
    const Color textPrimary = Color(0xFFFFFFFF); // Blanco
    const Color textSecondary = Color(0xFFB4B4B8); // Gris claro

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Esquema de colores Web3
      colorScheme: const ColorScheme.dark(
        primary: primaryGradientStart,
        secondary: secondaryGradientStart,
        surface: surfaceDark,
        background: backgroundDark,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        tertiary: accentNeon,
      ),

      // Configuración de sistema
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // AppBar con gradiente y glassmorphism
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),

      // Botones con gradientes Web3
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return primaryGradientEnd.withOpacity(0.8);
                }
                return null;
              }),
            ),
      ),

      // Inputs con estilo Web3
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardGlass.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: primaryGradientStart.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: primaryGradientStart.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentNeon, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: textSecondary.withOpacity(0.7),
          fontSize: 16,
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 16),
      ),

      // Cards con glassmorphism
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardGlass.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: primaryGradientStart.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // FloatingActionButton con gradiente
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 8,
        backgroundColor: primaryGradientStart,
        foregroundColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Texto con tipografía Web3
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.25,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.15,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.25,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 1.25,
        ),
      ),

      // Bottom Navigation con glassmorphism
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardGlass.withOpacity(0.2),
        elevation: 0,
        selectedItemColor: accentNeon,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),

      // Dividers con gradiente sutil
      dividerTheme: DividerThemeData(
        color: primaryGradientStart.withOpacity(0.2),
        thickness: 1,
        space: 20,
      ),
    );
  }
}
