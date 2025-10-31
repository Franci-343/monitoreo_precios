import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/precio_model.dart';
import 'package:monitoreo_precios/models/mercado_model.dart';
import 'package:monitoreo_precios/services/precio_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/services/alert_service.dart';
import 'package:monitoreo_precios/services/reporte_service.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';
import 'precio_tendencia_view.dart';

class ComparadorView extends StatefulWidget {
  final int productoId;
  final String productoNombre;

  const ComparadorView({
    Key? key,
    required this.productoId,
    required this.productoNombre,
  }) : super(key: key);

  @override
  State<ComparadorView> createState() => _ComparadorViewState();
}

class _ComparadorViewState extends State<ComparadorView> {
  static const int _currentUserId = 1; // usuario simulado
  List<Precio> _precios = [];
  bool _loading = true;

  int _sortColumnIndex = 1; // default sort by price
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final precios = await PrecioService.fetchPricesByProduct(widget.productoId);
    setState(() {
      _precios = precios;
      _loading = false;
    });

    // Comprobar alertas activas para este producto
    final triggered = await AlertService.checkAlertsForProduct(
      widget.productoId,
      precios,
    );
    if (triggered.isNotEmpty && mounted) {
      final messages = triggered
          .map(
            (a) =>
                '${a.direction == AlertDirection.above ? 'por encima' : 'por debajo'} de ${a.threshold} Bs',
          )
          .join('; ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alerta(s) disparada(s): $messages')),
      );
    }
  }

  void _sort<T>(
    Comparable<T> Function(Precio p) getField,
    int columnIndex,
    bool ascending,
  ) {
    _precios.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Future<void> _showAddAlertDialog() async {
    final thresholdCtrl = TextEditingController();
    AlertDirection direction = AlertDirection.above;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF6366F1), width: 1),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_alert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Crear Alerta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Web3NeonTextField(
                      hintText: 'Ejemplo: 15.50',
                      labelText: 'Umbral (Bs)',
                      controller: thresholdCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: Icons.monetization_on,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Ingrese un umbral';
                        final val = double.tryParse(v.replaceAll(',', '.'));
                        if (val == null) return 'Ingrese un número válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de Alerta',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: direction == AlertDirection.above
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6),
                                          ],
                                        )
                                      : null,
                                  color: direction != AlertDirection.above
                                      ? const Color(0xFF16213E).withOpacity(0.3)
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: direction == AlertDirection.above
                                        ? Colors.transparent
                                        : const Color(
                                            0xFF6366F1,
                                          ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        direction = AlertDirection.above;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.trending_up,
                                            color:
                                                direction ==
                                                    AlertDirection.above
                                                ? Colors.white
                                                : const Color(0xFF00FFF0),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Avisar si el precio sube',
                                              style: TextStyle(
                                                color:
                                                    direction ==
                                                        AlertDirection.above
                                                    ? Colors.white
                                                    : Colors.white.withOpacity(
                                                        0.7,
                                                      ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: direction == AlertDirection.below
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF06B6D4),
                                            Color(0xFF3B82F6),
                                          ],
                                        )
                                      : null,
                                  color: direction != AlertDirection.below
                                      ? const Color(0xFF16213E).withOpacity(0.3)
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: direction == AlertDirection.below
                                        ? Colors.transparent
                                        : const Color(
                                            0xFF6366F1,
                                          ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        direction = AlertDirection.below;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.trending_down,
                                            color:
                                                direction ==
                                                    AlertDirection.below
                                                ? Colors.white
                                                : const Color(0xFF00FFF0),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Avisar si el precio baja',
                                              style: TextStyle(
                                                color:
                                                    direction ==
                                                        AlertDirection.below
                                                    ? Colors.white
                                                    : Colors.white.withOpacity(
                                                        0.7,
                                                      ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF00FFF0)),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final val = double.parse(
                        thresholdCtrl.text.replaceAll(',', '.'),
                      );
                      await AlertService.addAlert(
                        widget.productoId,
                        val,
                        direction,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Alerta creada exitosamente'),
                            backgroundColor: Color(0xFF00FFF0),
                          ),
                        );
                      }
                      Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      'Crear Alerta',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAlertsSheet() async {
    final alerts = await AlertService.getAlertsForProduct(widget.productoId);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF16213E).withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle del modal
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header
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
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Gestionar Alertas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Web3GradientButton(
                        text: 'Nueva',
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await _showAddAlertDialog();
                        },
                        icon: Icons.add,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Lista de alertas
                  if (alerts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.notifications_off,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay alertas configuradas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea tu primera alerta para este producto',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...alerts.map(
                      (alert) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        alert.direction == AlertDirection.above
                                        ? [
                                            const Color(0xFFEC4899),
                                            const Color(0xFFF97316),
                                          ]
                                        : [
                                            const Color(0xFF10B981),
                                            const Color(0xFF059669),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  alert.direction == AlertDirection.above
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert.direction == AlertDirection.above
                                          ? 'Precio por encima de:'
                                          : 'Precio por debajo de:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${alert.threshold.toStringAsFixed(2)} Bs',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF00FFF0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await AlertService.removeAlert(alert.id);
                                  Navigator.of(ctx).pop();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Alerta eliminada'),
                                        backgroundColor: Color(0xFF00FFF0),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Fecha simple en español (abreviada)
  static const List<String> _monthAbbr = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = _monthAbbr[d.month - 1];
    final year = d.year.toString();
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Comparador — ${widget.productoNombre}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PrecioTendenciaScreen(
                    productoId: widget.productoId,
                    productoNombre: widget.productoNombre,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.show_chart),
            tooltip: 'Ver tendencias',
          ),
          IconButton(
            onPressed: _showAlertsSheet,
            icon: const Icon(Icons.notifications),
            tooltip: 'Gestionar alertas',
          ),
        ],
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Título del producto con estilo Web3
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
                              Icons.compare_arrows,
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
                                  'Comparación de precios por mercado',
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
                      const SizedBox(height: 16),

                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: Web3GradientButton(
                              text: 'Ver Tendencias',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PrecioTendenciaScreen(
                                      productoId: widget.productoId,
                                      productoNombre: widget.productoNombre,
                                    ),
                                  ),
                                );
                              },
                              icon: Icons.show_chart,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF06B6D4),
                                    Color(0xFF3B82F6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _showAlertsSheet,
                                  borderRadius: BorderRadius.circular(16),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Alertas',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Lista de precios optimizada para móviles
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00FFF0),
                          ),
                        )
                      : _precios.isEmpty
                      ? Center(
                          child: Web3GlassCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Icon(
                                    Icons.trending_down,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No hay precios reportados',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sé el primero en reportar precios para este producto',
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
                      : Column(
                          children: [
                            // Header con información de ordenamiento
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16213E).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sort,
                                    color: Color(0xFF00FFF0),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ordenado por: ${_sortColumnIndex == 1 ? "Precio" : "Fecha"} ${_sortAscending ? "↑" : "↓"}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      _sort<num>(
                                        (p) => p.valor,
                                        1,
                                        !_sortAscending,
                                      );
                                    },
                                    child: const Text(
                                      'Ordenar por precio',
                                      style: TextStyle(
                                        color: Color(0xFF00FFF0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Lista de precios con cards
                            Expanded(
                              child: FutureBuilder<List<Mercado>>(
                                future: ProductoService.fetchMarkets(),
                                builder: (context, snapshot) {
                                  final mercados = snapshot.data ?? [];
                                  return ListView.builder(
                                    itemCount: _precios.length,
                                    itemBuilder: (context, index) {
                                      final precio = _precios[index];
                                      final mercado = _getMercadoName(
                                        precio.mercadoId,
                                        mercados,
                                      );

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        child: Web3PriceCard(
                                          productName: mercado,
                                          marketName: _formatDate(
                                            precio.fechaActualizacion.toLocal(),
                                          ),
                                          price: precio.valor.toStringAsFixed(
                                            2,
                                          ),
                                          currency: 'Bs',
                                          onTap: () => _showPriceDetailsDialog(
                                            precio,
                                            mercado,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
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
      floatingActionButton: Web3FloatingActionButton(
        onPressed: _showAddAlertDialog,
        icon: Icons.add_alert,
        heroTag: "add_alert",
      ),
    );
  }

  String _getMercadoName(int mercadoId, List mercados) {
    try {
      final m = mercados.firstWhere((x) => x.id == mercadoId);
      return m.nombre as String;
    } catch (_) {
      return 'Mercado $mercadoId';
    }
  }

  Future<void> _showPriceDetailsDialog(
    Precio precio,
    String mercadoName,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF6366F1), width: 1),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.store, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mercadoName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FFF0), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Precio Actual',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${precio.valor.toStringAsFixed(2)} Bs',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF00FFF0),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Actualizado: ${_formatDate(precio.fechaActualizacion.toLocal())}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Color(0xFF00FFF0)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showReportDialog(precio.mercadoId);
                },
                child: const Text(
                  'Reportar Nuevo Precio',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReportDialog(int mercadoId) async {
    final formKey = GlobalKey<FormState>();
    final priceCtrl = TextEditingController();
    String mercadoName;
    try {
      final mercados = await ProductoService.fetchMarkets();
      mercadoName = mercados.firstWhere((m) => m.id == mercadoId).nombre;
    } catch (_) {
      mercadoName = 'Mercado $mercadoId';
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF6366F1), width: 1),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.report, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Reportar Precio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información del mercado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.store,
                            color: Color(0xFF00FFF0),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mercado:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mercadoName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de precio
                Web3NeonTextField(
                  hintText: 'Ejemplo: 12.50',
                  labelText: 'Precio (Bs)',
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: Icons.monetization_on,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Ingrese un precio';
                    final val = double.tryParse(v.replaceAll(',', '.'));
                    if (val == null) return 'Precio inválido';
                    if (val <= 0) return 'El precio debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tu reporte ayuda a mantener actualizada la información de precios',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
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
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF00FFF0)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final val = double.parse(priceCtrl.text.replaceAll(',', '.'));

                  // Guardar reporte
                  await ReporteService.addReport(
                    _currentUserId,
                    widget.productoId,
                    mercadoId,
                    val,
                  );

                  // Añadir precio a servicio de precios (simulación)
                  final newPrecio = Precio(
                    id: DateTime.now().millisecondsSinceEpoch.remainder(
                      1000000,
                    ),
                    productoId: widget.productoId,
                    mercadoId: mercadoId,
                    valor: val,
                    fechaActualizacion: DateTime.now(),
                  );
                  PrecioService.addPrice(newPrecio);

                  Navigator.of(ctx).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Reporte enviado exitosamente!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                    await _load(); // Recargar datos
                  }
                },
                child: const Text(
                  'Enviar Reporte',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ignore: unused_element
class _PrecioDataSource extends DataTableSource {
  final List<Precio> _precios;
  final List mercados; // list of Mercado
  final BuildContext context;
  final String Function(DateTime) _formatDate;
  final int productoId;
  final Future<void> Function(int mercadoId) onReport;

  _PrecioDataSource(
    this._precios,
    this.mercados,
    this.context,
    this._formatDate,
    this.productoId,
    this.onReport,
  );

  String _marketName(int mercadoId) {
    try {
      final m = mercados.firstWhere((x) => x.id == mercadoId);
      return m.nombre as String;
    } catch (_) {
      return 'Mercado $mercadoId';
    }
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _precios.length) return const DataRow(cells: []);
    final p = _precios[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(_marketName(p.mercadoId))),
        DataCell(Text(p.valor.toStringAsFixed(2))),
        DataCell(Text(_formatDate(p.fechaActualizacion.toLocal()))),
        DataCell(
          Row(
            children: [
              ElevatedButton(
                child: const Text('Reportar'),
                onPressed: () async {
                  await onReport(p.mercadoId);
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                child: const Text('Ver productos'),
                onPressed: () {
                  // En un flujo real navegaríamos a la vista de productos filtrada por mercado
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ver productos en ${_marketName(p.mercadoId)}',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _precios.length;

  @override
  int get selectedRowCount => 0;
}
