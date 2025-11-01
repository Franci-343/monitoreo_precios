import 'package:flutter/material.dart';
import 'package:monitoreo_precios/main.dart';
import 'package:monitoreo_precios/services/auth_service.dart';
import 'package:monitoreo_precios/views/login_view.dart';
import 'package:monitoreo_precios/views/admin/admin_productos_view.dart';
import 'package:monitoreo_precios/views/admin/admin_mercados_view.dart';
import 'package:monitoreo_precios/views/admin/admin_categorias_view.dart';
import 'package:monitoreo_precios/views/admin/admin_reportes_view.dart';
import 'package:monitoreo_precios/views/admin/admin_usuarios_view.dart';

class AdminPanelView extends StatefulWidget {
  const AdminPanelView({super.key});

  @override
  State<AdminPanelView> createState() => _AdminPanelViewState();
}

class _AdminPanelViewState extends State<AdminPanelView> {
  final _authService = AuthService();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardView(),
    const AdminUsuariosView(),
    const AdminProductosView(),
    const AdminMercadosView(),
    const AdminCategoriasView(),
    const AdminReportesView(),
  ];

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E), // cardGlass
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
        title: const Text(
          '¿Cerrar Sesión?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: Color(0xFFB4B4B8)),
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
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23), // backgroundDark
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1), // primaryGradientStart (Indigo)
                Color(0xFF8B5CF6), // primaryGradientEnd (Púrpura)
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Panel de Administrador',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determinar si estamos en móvil
          final bool isMobile = constraints.maxWidth < 800;

          return Row(
            children: [
              // Sidebar
              NavigationRail(
                backgroundColor: const Color(
                  0xFF16213E,
                ).withOpacity(0.5), // cardGlass
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                // En móvil solo iconos, en escritorio con etiquetas
                labelType: isMobile
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                minWidth: isMobile ? 56 : 80,
                selectedIconTheme: const IconThemeData(
                  color: Color(0xFF00FFF0), // accentNeon
                  size: 28,
                ),
                unselectedIconTheme: const IconThemeData(
                  color: Color(0xFFB4B4B8), // textSecondary
                  size: 24,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF00FFF0), // accentNeon
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: Color(0xFFB4B4B8), // textSecondary
                  fontSize: 11,
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_rounded),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_rounded),
                    label: Text('Usuarios'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_rounded),
                    label: Text('Productos'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.store_rounded),
                    label: Text('Mercados'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.category_rounded),
                    label: Text('Categorías'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.report_rounded),
                    label: Text('Reportes'),
                  ),
                ],
              ),
              VerticalDivider(
                thickness: 1,
                width: 1,
                color: const Color(0xFF6366F1).withOpacity(0.3),
              ),
              // Contenido principal
              Expanded(child: _pages[_selectedIndex]),
            ],
          );
        },
      ),
    );
  }
}

// ============================================
// DASHBOARD
// ============================================

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  bool _isLoading = true;
  int _totalProductos = 0;
  int _totalMercados = 0;
  int _totalCategorias = 0;
  int _reportesPendientes = 0;
  int _totalUsuarios = 0;
  int _totalPrecios = 0;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() => _isLoading = true);

    try {
      // Cargar todas las estadísticas en paralelo
      final results = await Future.wait([
        supabase.from('productos').select('id').eq('activo', true),
        supabase.from('mercados').select('id').eq('activo', true),
        supabase.from('categorias').select('id').eq('activo', true),
        supabase.from('reportes').select('id').eq('estado', 'pendiente'),
        supabase.from('usuarios').select('id'),
        supabase.from('precios').select('id'),
      ]);

      setState(() {
        _totalProductos = (results[0] as List).length;
        _totalMercados = (results[1] as List).length;
        _totalCategorias = (results[2] as List).length;
        _reportesPendientes = (results[3] as List).length;
        _totalUsuarios = (results[4] as List).length;
        _totalPrecios = (results[5] as List).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estadísticas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive padding
        final double padding = constraints.maxWidth < 600
            ? 16
            : (constraints.maxWidth < 900 ? 24 : 32);
        final bool isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.dashboard_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Botón de actualizar
                            IconButton(
                              onPressed: _isLoading
                                  ? null
                                  : _cargarEstadisticas,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF00FFF0),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.refresh_rounded,
                                      color: Color(0xFF00FFF0),
                                      size: 24,
                                    ),
                              tooltip: 'Actualizar',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.only(left: 46),
                          child: Text(
                            'Resumen general del sistema',
                            style: TextStyle(
                              color: Color(0xFFB4B4B8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.dashboard_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Resumen general del sistema',
                                style: TextStyle(
                                  color: Color(0xFFB4B4B8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón de actualizar
                        IconButton(
                          onPressed: _isLoading ? null : _cargarEstadisticas,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF00FFF0),
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh_rounded,
                                  color: Color(0xFF00FFF0),
                                  size: 28,
                                ),
                          tooltip: 'Actualizar estadísticas',
                        ),
                      ],
                    ),
              SizedBox(height: isMobile ? 20 : 32),
              // Grid de estadísticas
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(
                          color: Color(0xFF00FFF0),
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Calcular columnas según el ancho
                        int crossAxisCount = 3;
                        if (constraints.maxWidth < 900) {
                          crossAxisCount = 2;
                        }
                        if (constraints.maxWidth < 600) {
                          crossAxisCount = 1;
                        }

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 1.5, // Hace las tarjetas más anchas
                          children: [
                            _buildStatCard(
                              'Total Productos',
                              _totalProductos.toString(),
                              Icons.inventory_rounded,
                              const Color(0xFF6366F1), // Indigo
                            ),
                            _buildStatCard(
                              'Total Mercados',
                              _totalMercados.toString(),
                              Icons.store_rounded,
                              const Color(0xFF8B5CF6), // Púrpura
                            ),
                            _buildStatCard(
                              'Total Categorías',
                              _totalCategorias.toString(),
                              Icons.category_rounded,
                              const Color(0xFF06B6D4), // Cyan
                            ),
                            _buildStatCard(
                              'Reportes Pendientes',
                              _reportesPendientes.toString(),
                              Icons.report_problem_rounded,
                              const Color(0xFF3B82F6), // Azul
                            ),
                            _buildStatCard(
                              'Usuarios Registrados',
                              _totalUsuarios.toString(),
                              Icons.people_rounded,
                              const Color(0xFF00FFF0), // Neon cyan
                            ),
                            _buildStatCard(
                              'Precios Registrados',
                              _totalPrecios.toString(),
                              Icons.attach_money_rounded,
                              const Color(0xFF8B5CF6), // Púrpura
                            ),
                          ],
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.3), // cardGlass
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono con fondo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const Spacer(),
          // Valor
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          // Título
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFB4B4B8), // textSecondary
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
