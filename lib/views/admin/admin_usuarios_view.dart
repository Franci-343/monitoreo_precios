import 'package:flutter/material.dart';
import 'package:monitoreo_precios/main.dart';
import 'package:monitoreo_precios/models/usuario_model.dart';

class AdminUsuariosView extends StatefulWidget {
  const AdminUsuariosView({super.key});

  @override
  State<AdminUsuariosView> createState() => _AdminUsuariosViewState();
}

class _AdminUsuariosViewState extends State<AdminUsuariosView> {
  List<Usuario> _usuarios = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('usuarios')
          .select('*')
          .order('created_at', ascending: false);
      setState(() {
        _usuarios = (response as List)
            .map((json) => Usuario.fromMap(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Usuario> get _usuariosFiltrados {
    if (_searchQuery.isEmpty) return _usuarios;
    return _usuarios.where((u) {
      return u.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _mostrarFormulario({Usuario? usuario}) async {
    await showDialog(
      context: context,
      builder: (context) => _FormularioUsuario(usuario: usuario),
    );
    _cargarUsuarios();
  }

  Future<void> _eliminarUsuario(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
        title: const Text(
          '¿Eliminar Usuario?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de eliminar a "${usuario.nombre}"?\nEsto también eliminará sus favoritos, reportes y alertas.',
          style: const TextStyle(color: Color(0xFFB4B4B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFB4B4B8)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Eliminar'),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        // Usar la función RPC que elimina de usuarios Y auth.users
        await supabase.rpc(
          'eliminar_cuenta_usuario_admin',
          params: {'user_id': usuario.id},
        );

        _cargarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar usuario: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleAdmin(Usuario usuario) async {
    // Por ahora usamos una tabla simple para marcar admins
    // En producción, esto debería estar en metadata de auth o una tabla de roles
    final esAdmin = await _verificarSiEsAdmin(usuario.email);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
        title: Text(
          esAdmin
              ? '¿Quitar permisos de administrador?'
              : '¿Hacer administrador?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          esAdmin
              ? '${usuario.nombre} dejará de tener acceso al panel de administración.'
              : '${usuario.nombre} tendrá acceso completo al panel de administración.',
          style: const TextStyle(color: Color(0xFFB4B4B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFB4B4B8)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: esAdmin
                    ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                    : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Text(esAdmin ? 'Quitar Admin' : 'Hacer Admin'),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Mostrar instrucciones de cómo hacer admin
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF16213E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
            ),
            title: Row(
              children: [
                Icon(
                  esAdmin ? Icons.remove_circle : Icons.add_circle,
                  color: esAdmin
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF00FFF0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    esAdmin ? 'Quitar Admin' : 'Hacer Admin',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (esAdmin) ...[
                    const Text(
                      'Para quitar permisos de administrador a este usuario:',
                      style: TextStyle(color: Color(0xFFB4B4B8)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Abre el archivo:',
                      style: TextStyle(
                        color: Color(0xFFB4B4B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'lib/services/admin_service.dart',
                        style: TextStyle(
                          color: Color(0xFF00FFF0),
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '2. Cambia la línea:',
                      style: TextStyle(
                        color: Color(0xFFB4B4B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "static const String adminEmail = '${usuario.email}';",
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontFamily: 'monospace',
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Por:',
                      style: TextStyle(color: Color(0xFFB4B4B8)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "static const String adminEmail = 'otro@email.com';",
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Para dar permisos de administrador a este usuario:',
                      style: TextStyle(color: Color(0xFFB4B4B8)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Abre el archivo:',
                      style: TextStyle(
                        color: Color(0xFFB4B4B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'lib/services/admin_service.dart',
                        style: TextStyle(
                          color: Color(0xFF00FFF0),
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '2. Cambia la línea:',
                      style: TextStyle(
                        color: Color(0xFFB4B4B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "static const String adminEmail = 'fa8050386@gmail.com';",
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontFamily: 'monospace',
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Por:',
                      style: TextStyle(color: Color(0xFFB4B4B8)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "static const String adminEmail = '${usuario.email}';",
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '3. Ejecuta en la base de datos:',
                      style: TextStyle(
                        color: Color(0xFFB4B4B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Actualiza fix_admin_usuarios.sql\nreemplazando 'fa8050386@gmail.com'\npor '${usuario.email}'",
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Nota: Requiere modificación de código y base de datos.',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<bool> _verificarSiEsAdmin(String email) async {
    // Verificar si el email está en AdminService
    return email == 'fa8050386@gmail.com';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E).withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
              ),
              child: isMobile
                  ? Column(
                      children: [
                        TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Buscar usuarios...',
                            hintStyle: const TextStyle(
                              color: Color(0xFFB4B4B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF00FFF0),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0F0F23),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00FFF0),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _mostrarFormulario(),
                              icon: const Icon(
                                Icons.person_add_rounded,
                                size: 20,
                              ),
                              label: const Text('Nuevo Usuario'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Buscar usuarios...',
                              hintStyle: const TextStyle(
                                color: Color(0xFFB4B4B8),
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF00FFF0),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0F0F23),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00FFF0),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _mostrarFormulario(),
                            icon: const Icon(Icons.person_add_rounded),
                            label: const Text('Nuevo Usuario'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            // Lista
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00FFF0),
                      ),
                    )
                  : _usuariosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay usuarios',
                        style: TextStyle(
                          color: Color(0xFFB4B4B8),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      itemCount: _usuariosFiltrados.length,
                      itemBuilder: (context, index) {
                        final usuario = _usuariosFiltrados[index];
                        final esAdmin = usuario.email == 'fa8050386@gmail.com';

                        return Card(
                          elevation: 0,
                          color: const Color(0xFF16213E).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                            leading: CircleAvatar(
                              radius: isMobile ? 24 : 28,
                              backgroundImage: usuario.avatarUrl != null
                                  ? NetworkImage(usuario.avatarUrl!)
                                  : null,
                              backgroundColor: const Color(0xFF6366F1),
                              child: usuario.avatarUrl == null
                                  ? Text(
                                      usuario.nombre[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isMobile ? 18 : 20,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    usuario.nombre,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                ),
                                if (esAdmin) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF00FFF0),
                                          Color(0xFF06B6D4),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'ADMIN',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  usuario.email,
                                  style: TextStyle(
                                    color: const Color(0xFFB4B4B8),
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                                if (usuario.telefono != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tel: ${usuario.telefono}',
                                    style: TextStyle(
                                      color: const Color(0xFFB4B4B8),
                                      fontSize: isMobile ? 11 : 12,
                                    ),
                                  ),
                                ],
                                if (usuario.zonaPreferida != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Zona: ${usuario.zonaPreferida}',
                                    style: TextStyle(
                                      color: const Color(0xFFB4B4B8),
                                      fontSize: isMobile ? 11 : 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: isMobile
                                ? PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert_rounded,
                                      color: Color(0xFFB4B4B8),
                                    ),
                                    color: const Color(0xFF16213E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: const Color(
                                          0xFF6366F1,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    onSelected: (value) {
                                      if (value == 'admin') {
                                        _toggleAdmin(usuario);
                                      } else if (value == 'edit') {
                                        _mostrarFormulario(usuario: usuario);
                                      } else if (value == 'delete') {
                                        _eliminarUsuario(usuario);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'admin',
                                        child: Row(
                                          children: [
                                            Icon(
                                              esAdmin
                                                  ? Icons.admin_panel_settings
                                                  : Icons
                                                        .admin_panel_settings_outlined,
                                              color: esAdmin
                                                  ? const Color(0xFF00FFF0)
                                                  : const Color(0xFFB4B4B8),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              esAdmin
                                                  ? 'Quitar admin'
                                                  : 'Hacer admin',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_rounded,
                                              color: Color(0xFF06B6D4),
                                              size: 20,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Editar',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_rounded,
                                              color: Color(0xFFEF4444),
                                              size: 20,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          esAdmin
                                              ? Icons.admin_panel_settings
                                              : Icons
                                                    .admin_panel_settings_outlined,
                                          color: esAdmin
                                              ? const Color(0xFF00FFF0)
                                              : const Color(0xFFB4B4B8),
                                        ),
                                        onPressed: () => _toggleAdmin(usuario),
                                        tooltip: esAdmin
                                            ? 'Quitar admin'
                                            : 'Hacer admin',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_rounded,
                                          color: Color(0xFF06B6D4),
                                        ),
                                        onPressed: () => _mostrarFormulario(
                                          usuario: usuario,
                                        ),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_rounded,
                                          color: Color(0xFFEF4444),
                                        ),
                                        onPressed: () =>
                                            _eliminarUsuario(usuario),
                                        tooltip: 'Eliminar',
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================
// FORMULARIO
// ============================================

class _FormularioUsuario extends StatefulWidget {
  final Usuario? usuario;

  const _FormularioUsuario({this.usuario});

  @override
  State<_FormularioUsuario> createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends State<_FormularioUsuario> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _zonaController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario?.nombre);
    _emailController = TextEditingController(text: widget.usuario?.email);
    _telefonoController = TextEditingController(text: widget.usuario?.telefono);
    _zonaController = TextEditingController(
      text: widget.usuario?.zonaPreferida,
    );
    _passwordController = TextEditingController();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.usuario == null) {
        // CREAR NUEVO USUARIO
        // Nota: No podemos usar signUp() porque cerraría la sesión del admin
        // En su lugar, mostramos instrucciones al usuario
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF16213E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                ),
              ),
              title: const Text(
                'Crear Usuario',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Para crear un nuevo usuario, el usuario debe registrarse normalmente en la aplicación usando:',
                      style: TextStyle(color: Color(0xFFB4B4B8)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F23),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.email_rounded,
                                color: Color(0xFF00FFF0),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _emailController.text.trim(),
                                  style: const TextStyle(
                                    color: Color(0xFF00FFF0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.lock_rounded,
                                color: Color(0xFF00FFF0),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _passwordController.text.trim(),
                                  style: const TextStyle(
                                    color: Color(0xFF00FFF0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Comparte estas credenciales con el nuevo usuario para que pueda registrarse.',
                      style: TextStyle(color: Color(0xFFB4B4B8), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nota: Por limitaciones de Supabase, no es posible crear usuarios directamente desde el panel de administrador sin usar una API de servidor.',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          );
        }
        return;
      } else {
        // ACTUALIZAR USUARIO EXISTENTE
        await supabase
            .from('usuarios')
            .update({
              'nombre': _nombreController.text.trim(),
              'telefono': _telefonoController.text.trim().isEmpty
                  ? null
                  : _telefonoController.text.trim(),
              'zona_preferida': _zonaController.text.trim().isEmpty
                  ? null
                  : _zonaController.text.trim(),
            })
            .eq('id', widget.usuario!.id);

        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      title: Text(
        widget.usuario == null ? 'Nuevo Usuario' : 'Editar Usuario',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre completo',
                icon: Icons.person_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_rounded,
                enabled: widget.usuario == null, // No se puede cambiar email
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              if (widget.usuario == null) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock_rounded,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telefonoController,
                label: 'Teléfono (opcional)',
                icon: Icons.phone_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _zonaController,
                label: 'Zona preferida (opcional)',
                icon: Icons.location_on_rounded,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFFB4B4B8)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Guardar'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      style: TextStyle(color: enabled ? Colors.white : const Color(0xFF6B7280)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB4B4B8)),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
        filled: true,
        fillColor: const Color(0xFF0F0F23).withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF6366F1).withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF6366F1).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00FFF0), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF6366F1).withOpacity(0.1),
          ),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _zonaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
