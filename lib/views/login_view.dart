import 'package:flutter/material.dart';
import 'package:monitoreo_precios/views/register_view.dart';
import 'package:monitoreo_precios/views/producto_view.dart';
import 'package:monitoreo_precios/views/favoritos_view.dart';
import 'package:monitoreo_precios/views/reporte_view.dart';
import 'package:monitoreo_precios/views/perfil_view.dart';

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
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header dentro de la tarjeta para dar identidad y guía al usuario
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Color.fromRGBO(
                          Theme.of(context).colorScheme.primary.red,
                          Theme.of(context).colorScheme.primary.green,
                          Theme.of(context).colorScheme.primary.blue,
                          0.12,
                        ),
                        child: Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text('Monitoreo de Precios', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('Accede para guardar favoritos, reportar precios y comparar', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),

                      // Form fields
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese su correo electrónico';
                          }
                          if (!value.contains('@')) return 'Ingrese un correo válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese su contraseña';
                          if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Ingresar'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                // Abrir pantalla de registro y obtener el email creado
                                final result = await Navigator.of(context).push<String?>(
                                  MaterialPageRoute(builder: (_) => const RegisterView()),
                                );
                                if (result != null && result.isNotEmpty) {
                                  // Prellenar el campo email con el correo devuelto
                                  _emailController.text = result;
                                  // Opcional: mostrar feedback
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Registro exitoso. Por favor ingresa tu contraseña.')),
                                    );
                                  }
                                }
                              },
                        child: const Text('¿No tienes cuenta? Registrarse'),
                      ),
                    ],
                  ),
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
      appBar: AppBar(
        title: const Text('Monitoreo de Precios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¡Bienvenido!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Consulta y compara precios en mercados de La Paz', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _HomeCard(
                    icon: Icons.search,
                    label: 'Consultar productos',
                    color: Colors.deepPurple,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductoView())),
                  ),
                  _HomeCard(
                    icon: Icons.favorite,
                    label: 'Mis favoritos',
                    color: Colors.redAccent,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritosView())),
                  ),
                  _HomeCard(
                    icon: Icons.assignment,
                    label: 'Reportes',
                    color: Colors.teal,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReporteView())),
                  ),
                  _HomeCard(
                    icon: Icons.person,
                    label: 'Perfil',
                    color: Colors.indigo,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PerfilView())),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginView())),
                child: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({Key? key, required this.icon, required this.label, required this.color, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Color.fromRGBO(color.red, color.green, color.blue, 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
