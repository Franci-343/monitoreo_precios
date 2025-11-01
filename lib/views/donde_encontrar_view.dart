import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/mercado_model.dart';
import 'package:monitoreo_precios/models/precio_model.dart';
import 'package:monitoreo_precios/services/precio_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';

/// Vista que muestra DÓNDE encontrar un producto específico
/// Lista todos los mercados que tienen el producto con sus precios
class DondeEncontrarView extends StatefulWidget {
  final int productoId;
  final String productoNombre;

  const DondeEncontrarView({
    Key? key,
    required this.productoId,
    required this.productoNombre,
  }) : super(key: key);

  @override
  State<DondeEncontrarView> createState() => _DondeEncontrarViewState();
}

class _DondeEncontrarViewState extends State<DondeEncontrarView> {
  List<Mercado> _mercados = [];
  Map<int, Precio?> _precios = {}; // mercado_id -> precio
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final mercados = await ProductoService.fetchMarkets();
      final Map<int, Precio?> preciosMap = {};

      // Cargar precio para cada mercado
      for (final mercado in mercados) {
        final precio = await PrecioService().getPrecioActual(
          widget.productoId,
          mercado.id,
        );
        preciosMap[mercado.id] = precio;
      }

      setState(() {
        _mercados = mercados;
        _precios = preciosMap;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  // Ordenar mercados: primero los que tienen precio, luego sin precio
  List<Mercado> get _mercadosOrdenados {
    final conPrecio = _mercados.where((m) => _precios[m.id] != null).toList();
    final sinPrecio = _mercados.where((m) => _precios[m.id] == null).toList();

    // Ordenar los que tienen precio de menor a mayor
    conPrecio.sort((a, b) {
      final precioA = _precios[a.id]!.valor;
      final precioB = _precios[b.id]!.valor;
      return precioA.compareTo(precioB);
    });

    return [...conPrecio, ...sinPrecio];
  }

  // Encontrar el precio más bajo
  Precio? get _precioMasBajo {
    final preciosValidos = _precios.values.where((p) => p != null).toList();
    if (preciosValidos.isEmpty) return null;

    return preciosValidos.reduce((a, b) => a!.valor < b!.valor ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('¿Dónde Encontrar?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FFF0)),
                )
              : Column(
                  children: [
                    const SizedBox(height: 16),

                    // Header con info del producto
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Web3GlassCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEC4899),
                                    Color(0xFFF97316),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.productoNombre,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Disponible en ${_precios.values.where((p) => p != null).length} mercados',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Título de la lista
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.store,
                            color: Color(0xFF00FFF0),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mercados y Precios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Lista de mercados
                    Expanded(
                      child: _mercadosOrdenados.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _mercadosOrdenados.length,
                              itemBuilder: (context, index) {
                                final mercado = _mercadosOrdenados[index];
                                final precio = _precios[mercado.id];
                                final esMasBarato =
                                    precio != null &&
                                    _precioMasBajo != null &&
                                    precio.valor == _precioMasBajo!.valor;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildMercadoCard(
                                    mercado,
                                    precio,
                                    esMasBarato,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMercadoCard(Mercado mercado, Precio? precio, bool esMasBarato) {
    final disponible = precio != null;

    return Web3GlassCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: esMasBarato
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEF4444), width: 2),
              )
            : null,
        child: Row(
          children: [
            // Icono del mercado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: disponible
                      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                      : [Colors.grey.shade700, Colors.grey.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                mercado.tipo == 'supermercado'
                    ? Icons.shopping_cart
                    : Icons.store,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Info del mercado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mercado.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: const Color(0xFF00FFF0).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mercado.zona,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Precio
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (disponible) ...[
                  Text(
                    '${precio.valor.toStringAsFixed(2)} Bs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: esMasBarato
                          ? const Color(0xFFEF4444)
                          : Colors.white,
                    ),
                  ),
                  if (esMasBarato) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        'MÁS BARATO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'No disponible',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Web3GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.search_off,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No hay mercados disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
