import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/precio_model.dart';
import 'package:monitoreo_precios/services/precio_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/services/alert_service.dart';
import 'package:monitoreo_precios/services/historial_service.dart';
import 'package:monitoreo_precios/views/precio_tendencia_view.dart';
import 'package:monitoreo_precios/services/reporte_service.dart';

class ComparadorView extends StatefulWidget {
  final int productoId;
  final String productoNombre;

  const ComparadorView({Key? key, required this.productoId, required this.productoNombre}) : super(key: key);

  @override
  State<ComparadorView> createState() => _ComparadorViewState();
}

class _ComparadorViewState extends State<ComparadorView> {
  static const int _currentUserId = 1; // usuario simulado
  List<Precio> _precios = [];
  bool _loading = true;

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
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
    final triggered = await AlertService.checkAlertsForProduct(widget.productoId, precios);
    if (triggered.isNotEmpty && mounted) {
      final messages = triggered.map((a) => '${a.direction == AlertDirection.above ? 'por encima' : 'por debajo'} de ${a.threshold} Bs').join('; ');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alerta(s) disparada(s): $messages')));
    }
  }

  void _sort<T>(Comparable<T> Function(Precio p) getField, int columnIndex, bool ascending) {
    _precios.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
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

    await showDialog<void>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Crear alerta'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: thresholdCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Umbral (Bs)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese un umbral';
                  final val = double.tryParse(v.replaceAll(',', '.'));
                  if (val == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              DropdownButton<AlertDirection>(
                value: direction,
                items: const [
                  DropdownMenuItem(value: AlertDirection.above, child: Text('Avisar si el precio sube por encima')),
                  DropdownMenuItem(value: AlertDirection.below, child: Text('Avisar si el precio baja por debajo')),
                ],
                onChanged: (d) {
                  if (d != null) direction = d;
                },
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final val = double.parse(thresholdCtrl.text.replaceAll(',', '.'));
            await AlertService.addAlert(widget.productoId, val, direction);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alerta creada')));
            Navigator.of(ctx).pop();
          }, child: const Text('Crear')),
        ],
      );
    });
  }

  Future<void> _showAlertsSheet() async {
    final alerts = await AlertService.getAlertsForProduct(widget.productoId);
    if (!mounted) return;
    await showModalBottomSheet<void>(context: context, builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Alertas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () async { Navigator.of(ctx).pop(); await _showAddAlertDialog(); }, child: const Text('Nueva'))
              ],
            ),
            const SizedBox(height: 8),
            if (alerts.isEmpty) const Text('No hay alertas para este producto'),
            ...alerts.map((a) => ListTile(
              title: Text('${a.direction == AlertDirection.above ? 'Por encima' : 'Por debajo'} ${a.threshold} Bs'),
              trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async { await AlertService.removeAlert(a.id); Navigator.of(ctx).pop(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alerta eliminada'))); }),
            ))
          ],
        ),
      );
    });
  }

  // Fecha simple en español (abreviada)
  static const List<String> _monthAbbr = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = _monthAbbr[d.month - 1];
    final year = d.year.toString();
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    final mercados = ProductoService.getMarketsSync();

    return Scaffold(
      appBar: AppBar(title: Text('Comparador — ${widget.productoNombre}'), actions: [
        IconButton(onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => PrecioTendenciaView(productoId: widget.productoId, productoNombre: widget.productoNombre))); }, icon: const Icon(Icons.show_chart)),
        IconButton(onPressed: _showAlertsSheet, icon: const Icon(Icons.notifications)),
      ],),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _precios.isEmpty
                ? const Center(child: Text('No hay precios reportados para este producto'))
                : SingleChildScrollView(
                    child: PaginatedDataTable(
                      header: Text('Precios por mercado — ${widget.productoNombre}'),
                      rowsPerPage: _rowsPerPage,
                      onRowsPerPageChanged: (r) {
                        if (r != null) setState(() => _rowsPerPage = r);
                      },
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columns: [
                        const DataColumn(label: Text('Mercado')),
                        DataColumn(
                            label: const Text('Precio (Bs)'),
                            numeric: true,
                            onSort: (ci, asc) => _sort<num>((p) => p.valor, ci, asc)),
                        DataColumn(
                            label: const Text('Fecha'),
                            onSort: (ci, asc) => _sort<DateTime>((p) => p.fechaActualizacion, ci, asc)),
                        const DataColumn(label: Text('Acciones')),
                      ],
                      source: _PrecioDataSource(_precios, mercados, context, _formatDate, widget.productoId, _showReportDialog),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlertDialog,
        child: const Icon(Icons.add_alert),
        tooltip: 'Crear alerta',
      ),
    );
  }

  Future<void> _showReportDialog(int mercadoId) async {
    final formKey = GlobalKey<FormState>();
    final priceCtrl = TextEditingController();

    await showDialog<void>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Reportar precio'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mercado: ${ProductoService.getMarketsSync().firstWhere((m) => m.id == mercadoId).nombre}'),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Precio (Bs)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese un precio';
                  final val = double.tryParse(v.replaceAll(',', '.'));
                  if (val == null) return 'Precio inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final val = double.parse(priceCtrl.text.replaceAll(',', '.'));
            // guardar reporte
            await ReporteService.addReport(_currentUserId, widget.productoId, mercadoId, val);
            // añadir precio a servicio de precios (simulación)
            final newPrecio = Precio(id: DateTime.now().millisecondsSinceEpoch.remainder(1000000), productoId: widget.productoId, mercadoId: mercadoId, valor: val, fechaActualizacion: DateTime.now());
            PrecioService.addPrice(newPrecio);
            Navigator.of(ctx).pop();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado.')));
              await _load();
            }
          }, child: const Text('Enviar')),
        ],
      );
    });
  }
}

class _PrecioDataSource extends DataTableSource {
  final List<Precio> _precios;
  final List mercados; // list of Mercado
  final BuildContext context;
  final String Function(DateTime) _formatDate;
  final int productoId;
  final Future<void> Function(int mercadoId) onReport;

  _PrecioDataSource(this._precios, this.mercados, this.context, this._formatDate, this.productoId, this.onReport);

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
        DataCell(Row(
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ver productos en ${_marketName(p.mercadoId)}')));
              },
            ),
          ],
        )),
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
