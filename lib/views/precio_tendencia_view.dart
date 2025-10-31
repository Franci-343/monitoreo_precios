import 'package:flutter/material.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';
import 'package:monitoreo_precios/services/precio_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';

class PrecioTendenciaScreen extends StatefulWidget {
  final int productoId;
  final String productoNombre;

  const PrecioTendenciaScreen({Key? key, required this.productoId, required this.productoNombre}) : super(key: key);

  @override
  State<PrecioTendenciaScreen> createState() => _PrecioTendenciaScreenState();
}

class _PrecioTendenciaScreenState extends State<PrecioTendenciaScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tendenciaData = [];

  @override
  void initState() {
    super.initState();
    _loadTendenciaData();
  }

  Future<void> _loadTendenciaData() async {
    setState(() => _loading = true);

    // Simular datos de tendencia por los últimos 7 días
    final precios = await PrecioService.fetchPricesByProduct(widget.productoId);
    final mercados = await ProductoService.fetchMarkets();

    // Agrupar por mercado y calcular tendencia
    final tendencias = <Map<String, dynamic>>[];
    for (final mercado in mercados) {
      final preciosMercado = precios.where((p) => p.mercadoId == mercado.id).toList();
      if (preciosMercado.isNotEmpty) {
        preciosMercado.sort((a, b) => b.fechaActualizacion.compareTo(a.fechaActualizacion));
        final precioActual = preciosMercado.first.valor;
        final precioAnterior = preciosMercado.length > 1 ? preciosMercado[1].valor : precioActual;
        final cambio = precioActual - precioAnterior;
        final porcentajeCambio = precioAnterior > 0 ? (cambio / precioAnterior) * 100 : 0.0;

        tendencias.add({
          'mercado': mercado.nombre,
          'precioActual': precioActual,
          'cambio': cambio,
          'porcentajeCambio': porcentajeCambio,
          'fecha': preciosMercado.first.fechaActualizacion,
        });
      }
    }

    setState(() {
      _tendenciaData = tendencias;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Tendencias — ${widget.productoNombre}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00FFF0),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Header con información del producto
                      Web3GlassCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up,
                                    color: Colors.white,
                                    size: 24,
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
                                        'Tendencia de precios por mercado',
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
                            if (_tendenciaData.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00FFF0).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '${_tendenciaData.length}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF00FFF0),
                                          ),
                                        ),
                                        Text(
                                          'Mercados',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '${_getPromedioPrecio().toStringAsFixed(2)} Bs',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF00FFF0),
                                          ),
                                        ),
                                        Text(
                                          'Precio promedio',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Lista de tendencias por mercado
                      Expanded(
                        child: _tendenciaData.isEmpty
                            ? Center(
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
                                          Icons.show_chart,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Sin datos de tendencia',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No hay suficientes datos para mostrar tendencias de precio',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _tendenciaData.length,
                                itemBuilder: (context, index) {
                                  final data = _tendenciaData[index];
                                  final isPositive = data['cambio'] >= 0;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Web3GlassCard(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: isPositive
                                                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                                          : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    isPositive ? Icons.trending_up : Icons.trending_down,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        data['mercado'],
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Precio actual: ${data['precioActual'].toStringAsFixed(2)} Bs',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white.withOpacity(0.8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${data['cambio'] >= 0 ? '+' : ''}${data['cambio'].toStringAsFixed(2)} Bs',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: isPositive
                                                            ? const Color(0xFF10B981)
                                                            : const Color(0xFFEF4444),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${data['porcentajeCambio'] >= 0 ? '+' : ''}${data['porcentajeCambio'].toStringAsFixed(1)}%',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white.withOpacity(0.7),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
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
                  ),
                ),
        ),
      ),
    );
  }

  double _getPromedioPrecio() {
    if (_tendenciaData.isEmpty) return 0.0;
    final suma = _tendenciaData.fold(0.0, (sum, item) => sum + item['precioActual']);
    return suma / _tendenciaData.length;
  }
}
