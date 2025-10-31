import 'package:flutter/material.dart';
import 'package:monitoreo_precios/views/register_view.dart';
import 'package:monitoreo_precios/views/producto_view.dart';
import 'package:monitoreo_precios/views/favoritos_view.dart';
import 'package:monitoreo_precios/views/reporte_view.dart';
import 'package:monitoreo_precios/views/perfil_view.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
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

    // Simular un proceso de autenticación local (sin conexión a BD)
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _loading = false);

    // Validación simple: si el email contiene '@' y la contraseña tiene al menos 6 chars
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.contains('@') && password.length >= 6) {
      // Ir a pantalla principal simulada
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeAfterLogin()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales inválidas. Revise e intente nuevamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo y título con efecto neón
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.storefront,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Título principal
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00FFF0), Color(0xFF6366F1)],
                      ).createShader(bounds),
                      child: const Text(
                        'Monitoreo de Precios',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'La Paz, Bolivia',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Accede para guardar favoritos, reportar precios y comparar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Formulario con glassmorphism
                    Web3GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Web3NeonTextField(
                              hintText: 'Correo electrónico',
                              labelText: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingrese su correo electrónico';
                                }
                                if (!value.contains('@')) return 'Ingrese un correo válido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            Web3NeonTextField(
                              hintText: 'Contraseña',
                              labelText: 'Password',
                              controller: _passwordController,
                              obscureText: true,
                              prefixIcon: Icons.lock,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Ingrese su contraseña';
                                if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            Web3GradientButton(
                              text: 'Ingresar',
                              onPressed: _submit,
                              isLoading: _loading,
                              icon: Icons.login,
                              width: double.infinity,
                            ),
                            const SizedBox(height: 16),

                            TextButton(
                              onPressed: _loading
                                  ? null
                                  : () async {
                                      final result = await Navigator.of(context).push<String?>(
                                        MaterialPageRoute(builder: (_) => const RegisterView()),
                                      );
                                      if (result != null && result.isNotEmpty) {
                                        _emailController.text = result;
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Registro exitoso. Por favor ingresa tu contraseña.'),
                                              backgroundColor: const Color(0xFF00FFF0).withOpacity(0.8),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              child: Text(
                                '¿No tienes cuenta? Registrarse',
                                style: TextStyle(
                                  color: const Color(0xFF00FFF0),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Indicador de versión con estilo Web3
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'v1.0.0 • Sistema de calidad ISO/IEC 9126',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeAfterLogin extends StatelessWidget {
  const HomeAfterLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Monitoreo de Precios'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PerfilView()),
            ),
          ),
        ],
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Saludo con estilo Web3
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFF0), Color(0xFF6366F1)],
                  ).createShader(bounds),
                  child: const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Consulta y compara precios en mercados de La Paz',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _Web3HomeCard(
                        icon: Icons.search,
                        label: 'Consultar Productos',
                        gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProductoView()),
                        ),
                      ),
                      _Web3HomeCard(
                        icon: Icons.favorite,
                        label: 'Mis Favoritos',
                        gradientColors: const [Color(0xFFEC4899), Color(0xFFF97316)],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FavoritosView()),
                        ),
                      ),
                      _Web3HomeCard(
                        icon: Icons.analytics,
                        label: 'Reportes y Tendencias',
                        gradientColors: const [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ReporteView()),
                        ),
                      ),
                      _Web3HomeCard(
                        icon: Icons.person,
                        label: 'Mi Perfil',
                        gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PerfilView()),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer con información adicional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FFF0), Color(0xFF06B6D4)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sistema certificado ISO/IEC 9126',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Calidad garantizada en funcionalidad, fiabilidad y usabilidad',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Web3HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _Web3HomeCard({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16213E).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
