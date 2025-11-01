import 'package:flutter/material.dart';
import 'package:monitoreo_precios/services/historial_service.dart';
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/views/donde_encontrar_view.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';

/// Vista del historial de consultas de precios del usuario
/// Muestra los últimos productos consultados ordenados por fecha
class HistorialView extends StatefulWidget {
  const HistorialView({Key? key}) : super(key: key);

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<HistorialView> {
  List<Map<String, dynamic>> _historial = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  Future<void> _loadHistorial() async {
    setState(() => _loading = true);

    try {
      final historial = await HistorialService.getHistorial();

      setState(() {
        _historial = historial;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar historial: $e')),
        );
      }
    }
  }

  Future<void> _limpiarHistorial() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF6366F1), width: 1),
        ),
        title: const Text('Limpiar Historial'),
        content: const Text(
          '¿Estás seguro que deseas eliminar todo el historial de consultas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await HistorialService.limpiarHistorial();
      await _loadHistorial();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial eliminado'),
            backgroundColor: Color(0xFF00FFF0),
          ),
        );
      }
    }
  }

  Future<void> _eliminarItem(int productoId) async {
    await HistorialService.eliminarDelHistorial(productoId);
    await _loadHistorial();
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) {
      return 'Hace un momento';
    } else if (diferencia.inHours < 1) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inDays < 1) {
      return 'Hace ${diferencia.inHours} horas';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'frutas':
        return Icons.apple;
      case 'verduras':
        return Icons.spa;
      case 'carnes':
        return Icons.set_meal;
      case 'lácteos':
        return Icons.coffee;
      case 'granos':
        return Icons.grain;
      case 'tubérculos':
        return Icons.local_dining;
      case 'abarrotes':
        return Icons.shopping_basket;
      case 'condimentos':
        return Icons.emoji_food_beverage;
      default:
        return Icons.shopping_cart;
    }
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'frutas':
        return const Color(0xFFFF6B6B);
      case 'verduras':
        return const Color(0xFF4ECDC4);
      case 'carnes':
        return const Color(0xFFFF8B94);
      case 'lácteos':
        return const Color(0xFFFFE66D);
      case 'granos':
        return const Color(0xFF95E1D3);
      case 'tubérculos':
        return const Color(0xFFFFEAA7);
      case 'abarrotes':
        return const Color(0xFFA8E6CF);
      case 'condimentos':
        return const Color(0xFFFAB1A0);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Historial de Consultas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_historial.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _limpiarHistorial,
              tooltip: 'Limpiar historial',
            ),
        ],
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FFF0)),
                )
              : _historial.isEmpty
              ? _buildEmptyState()
              : _buildHistorialList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Web3GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.history, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sin historial aún',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tus consultas de productos aparecerán aquí',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Web3GradientButton(
                text: 'Explorar Productos',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/productos');
                },
                icon: Icons.search,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorialList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Header con contador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Últimas Consultas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_historial.length} productos consultados',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista de productos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _historial.length,
            itemBuilder: (context, index) {
              final item = _historial[index];
              final producto = item['producto'] as Producto;
              final fecha = item['fecha'] as DateTime;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Web3GlassCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          producto.categoria,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCategoryColor(
                            producto.categoria,
                          ).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(producto.categoria),
                        color: _getCategoryColor(producto.categoria),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FFF0).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                producto.categoria.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00FFF0),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatearFecha(fecha),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Color(0xFF6366F1),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DondeEncontrarView(
                                  productoId: producto.id,
                                  productoNombre: producto.nombre,
                                ),
                              ),
                            );
                          },
                          tooltip: '¿Dónde encontrar?',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _eliminarItem(producto.id),
                          tooltip: 'Eliminar del historial',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
