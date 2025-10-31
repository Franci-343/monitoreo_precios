import 'package:flutter/material.dart';
import 'package:monitoreo_precios/services/reporte_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/models/reporte_model.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';

class ReporteView extends StatefulWidget {
  const ReporteView({Key? key}) : super(key: key);

  @override
  State<ReporteView> createState() => _ReporteViewState();
}

class _ReporteViewState extends State<ReporteView> {
  List<Reporte> _reports = [];
  Map<int, String> _productNames = {};
  Map<int, String> _marketNames = {};
  String _selectedProducto = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final reports = await ReporteService.getAllReports();
    final productos = await ProductoService.fetchProducts();
    final mercados = await ProductoService.fetchMarkets();

    // Crear mapas para nombres
    final productMap = <int, String>{};
    final marketMap = <int, String>{};

    for (final p in productos) {
      productMap[p.id] = p.nombre;
    }
    for (final m in mercados) {
      marketMap[m.id] = m.nombre;
    }

    setState(() {
      _reports = reports;
      _productNames = productMap;
      _marketNames = marketMap;
      _loading = false;
    });
  }

  Future<void> _filterByProductName(String name) async {
    setState(() => _loading = true);
    if (name.isEmpty) {
      final r = await ReporteService.getAllReports();
      setState(() {
        _reports = r;
        _loading = false;
      });
      return;
    }
    final prods = await ProductoService.fetchProducts(query: name);
    final ids = prods.map((p) => p.id).toSet();
    final all = await ReporteService.getAllReports();
    setState(() {
      _reports = all.where((r) => ids.contains(r.productoId)).toList();
      _loading = false;
    });
  }

  Future<void> _deleteReport(int id) async {
    await ReporteService.removeReport(id);
    await _loadAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte eliminado'),
          backgroundColor: Color(0xFF00FFF0),
        ),
      );
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace unos momentos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Reportes de Precios'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Filtro compacto
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Web3NeonTextField(
                  hintText: 'Filtrar por producto...',
                  prefixIcon: Icons.filter_list,
                  onSuffixIconPressed: () {
                    _filterByProductName(_selectedProducto);
                  },
                ),
              ),

              // Lista de reportes
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00FFF0),
                        ),
                      )
                    : _reports.isEmpty
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
                                      Icons.report_off,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'No hay reportes aún',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                    Text(
                                      'Los reportes de precios aparecerán aquí',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.builder(
                              itemCount: _reports.length,
                              itemBuilder: (context, index) {
                                final reporte = _reports[index];
                                final productName = _productNames[reporte.productoId] ?? 'Producto desconocido';
                                final marketName = _marketNames[reporte.mercadoId] ?? 'Mercado desconocido';

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
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.report,
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
                                                      productName,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.store,
                                                          size: 14,
                                                          color: Color(0xFF00FFF0),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          marketName,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white.withValues(alpha: 0.8),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => _deleteReport(reporte.id),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Precio reportado
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF00FFF0), Color(0xFF06B6D4)],
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Precio reportado',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '${reporte.valorReportado.toStringAsFixed(2)} Bs',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),

                                          // Tiempo transcurrido
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Color(0xFF00FFF0),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _getTimeAgo(reporte.fechaReporte),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white.withValues(alpha: 0.7),
                                                ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

