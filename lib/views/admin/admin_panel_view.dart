import 'package:flutter/material.dart';
import 'package:monitoreo_precios/services/auth_service.dart';
import 'package:monitoreo_precios/views/login_view.dart';
import 'package:monitoreo_precios/views/admin/admin_productos_view.dart';
import 'package:monitoreo_precios/views/admin/admin_mercados_view.dart';
import 'package:monitoreo_precios/views/admin/admin_categorias_view.dart';
import 'package:monitoreo_precios/views/admin/admin_reportes_view.dart';

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
    const AdminProductosView(),
    const AdminMercadosView(),
    const AdminCategoriasView(),
    const AdminReportesView(),
  ];

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          '¿Cerrar Sesión?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Cerrar Sesión'),
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
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings, size: 24),
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            backgroundColor: const Color(0xFF1F2937),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(
              color: Color(0xFFEF4444),
              size: 28,
            ),
            unselectedIconTheme: const IconThemeData(
              color: Color(0xFF9CA3AF),
              size: 24,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Productos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.store),
                label: Text('Mercados'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category),
                label: Text('Categorías'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.report),
                label: Text('Reportes'),
              ),
            ],
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: Color(0xFF374151),
          ),
          // Contenido principal
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}

// ============================================
// DASHBOARD
// ============================================

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Productos',
                  '31',
                  Icons.inventory,
                  const Color(0xFF10B981),
                ),
                _buildStatCard(
                  'Total Mercados',
                  '10',
                  Icons.store,
                  const Color(0xFF3B82F6),
                ),
                _buildStatCard(
                  'Total Categorías',
                  '8',
                  Icons.category,
                  const Color(0xFF8B5CF6),
                ),
                _buildStatCard(
                  'Reportes Pendientes',
                  '0',
                  Icons.report_problem,
                  const Color(0xFFF59E0B),
                ),
                _buildStatCard(
                  'Usuarios Registrados',
                  '0',
                  Icons.people,
                  const Color(0xFFEC4899),
                ),
                _buildStatCard(
                  'Precios Registrados',
                  '128',
                  Icons.attach_money,
                  const Color(0xFF06B6D4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
