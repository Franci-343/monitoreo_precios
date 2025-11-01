import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/usuario_model.dart';
import 'package:monitoreo_precios/services/auth_service.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';
import 'package:monitoreo_precios/widgets/avatar_selector.dart';
import 'package:monitoreo_precios/views/login_view.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({Key? key}) : super(key: key);

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final AuthService _authService = AuthService();
  Usuario? _usuario;
  bool _isLoading = true;
  bool _isEditing = false;

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _zonaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _zonaController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        final perfil = await _authService.getUsuarioPerfil(currentUser.id);
        setState(() {
          _usuario = perfil;
          _nombreController.text = perfil?.nombre ?? '';
          _telefonoController.text = perfil?.telefono ?? '';
          _zonaController.text = perfil?.zonaPreferida ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar perfil: $e')));
      }
    }
  }

  Future<void> _guardarCambios() async {
    if (_usuario == null) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      await _authService.updatePerfil(
        userId: currentUser.id,
        nombre: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
        zonaPreferida: _zonaController.text.trim(),
        avatarUrl: _usuario?.avatarUrl, // Mantener el avatar actual
      );

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _cargarPerfil();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
      }
    }
  }

  Future<void> _cambiarAvatar() async {
    await showDialog(
      context: context,
      builder: (context) => AvatarSelector(
        currentAvatarUrl: _usuario?.avatarUrl,
        onAvatarSelected: (avatarUrl) async {
          try {
            final currentUser = _authService.getCurrentUser();
            if (currentUser == null) return;

            await _authService.updatePerfil(
              userId: currentUser.id,
              avatarUrl: avatarUrl,
            );

            await _cargarPerfil();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Avatar actualizado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al actualizar avatar: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF6366F1), width: 1),
        ),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _authService.signOut();
      if (mounted) {
        // Navegar al login y eliminar todas las rutas anteriores
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _eliminarCuenta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('¡Advertencia!'),
          ],
        ),
        content: const Text(
          '¿Estás seguro que deseas eliminar tu cuenta?\n\n'
          'Esta acción es irreversible y se eliminarán:\n'
          '• Tu perfil\n'
          '• Tus favoritos\n'
          '• Tus alertas',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar Cuenta'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Segunda confirmación
      final confirmarFinal = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.red, width: 2),
            ),
            title: const Text('Confirmación Final'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Escribe "ELIMINAR" para confirmar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Escribe ELIMINAR',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(controller.text),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );

      if (confirmarFinal == 'ELIMINAR') {
        setState(() => _isLoading = true);
        try {
          await _authService.eliminarCuenta();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cuenta eliminada exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Navegar al login y eliminar todas las rutas anteriores
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginView()),
              (route) => false,
            );
          }
        } catch (e) {
          setState(() => _isLoading = false);
          if (mounted) {
            // Mostrar diálogo con el error detallado
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1A1A2E),
                title: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Error al Eliminar Cuenta'),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Text(
                    e.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(height: 1.5),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            );
          }
        }
      } else if (confirmarFinal != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes escribir "ELIMINAR" para confirmar'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Editar perfil',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nombreController.text = _usuario?.nombre ?? '';
                  _telefonoController.text = _usuario?.telefono ?? '';
                  _zonaController.text = _usuario?.zonaPreferida ?? '';
                });
              },
              tooltip: 'Cancelar',
            ),
        ],
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Avatar con selector
                UserAvatar(
                  avatarUrl: _usuario?.avatarUrl,
                  size: 120,
                  onTap: _cambiarAvatar,
                ),

                const SizedBox(height: 24),

                // Información del usuario
                Web3GlassCard(
                  child: Column(
                    children: [
                      if (_isEditing) ...[
                        // Modo edición
                        TextField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _telefonoController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono (opcional)',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _zonaController,
                          decoration: const InputDecoration(
                            labelText: 'Zona preferida (opcional)',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: Web3GradientButton(
                            text: 'Guardar Cambios',
                            onPressed: _guardarCambios,
                            icon: Icons.save,
                          ),
                        ),
                      ] else ...[
                        // Modo visualización
                        _buildInfoRow(
                          Icons.person,
                          'Nombre',
                          _usuario?.nombre ?? 'Sin nombre',
                        ),
                        const Divider(height: 32),
                        _buildInfoRow(
                          Icons.email,
                          'Email',
                          _usuario?.email ?? 'Sin email',
                        ),
                        if (_usuario?.telefono != null &&
                            _usuario!.telefono!.isNotEmpty) ...[
                          const Divider(height: 32),
                          _buildInfoRow(
                            Icons.phone,
                            'Teléfono',
                            _usuario!.telefono!,
                          ),
                        ],
                        if (_usuario?.zonaPreferida != null &&
                            _usuario!.zonaPreferida!.isNotEmpty) ...[
                          const Divider(height: 32),
                          _buildInfoRow(
                            Icons.location_on,
                            'Zona preferida',
                            _usuario!.zonaPreferida!,
                          ),
                        ],
                        const Divider(height: 32),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Miembro desde',
                          _formatDate(_usuario?.createdAt),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Opciones
                Web3GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Opciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFFEC4899),
                          ),
                        ),
                        title: const Text('Mis Favoritos'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.of(context).pushNamed('/favoritos');
                        },
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.history,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                        title: const Text('Historial de Consultas'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.of(context).pushNamed('/historial');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botones de acción
                SizedBox(
                  width: double.infinity,
                  child: Web3GradientButton(
                    text: 'Cerrar Sesión',
                    onPressed: _cerrarSesion,
                    icon: Icons.logout,
                  ),
                ),

                const SizedBox(height: 16),

                // Botón eliminar cuenta
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _eliminarCuenta,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      'Eliminar Cuenta',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00FFF0)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Desconocido';
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
