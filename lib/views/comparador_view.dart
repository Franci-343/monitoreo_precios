import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/precio_model.dart';
import 'package:monitoreo_precios/services/precio_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';

class ComparadorView extends StatefulWidget {
  final int productoId;
  final String productoNombre;

  const ComparadorView({Key? key, required this.productoId, required this.productoNombre}) : super(key: key);

  @override
  State<ComparadorView> createState() => _ComparadorViewState();
}

class _ComparadorViewState extends State<ComparadorView> {
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

  @override
  Widget build(BuildContext context) {
    final mercados = ProductoService.getMarketsSync();

    return Scaffold(
      appBar: AppBar(title: Text('Comparador — ${widget.productoNombre}')),
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
                      source: _PrecioDataSource(_precios, mercados, context),
                    ),
                  ),
      ),
    );
  }
}

class _PrecioDataSource extends DataTableSource {
  final List<Precio> _precios;
  final List mercados; // list of Mercado
  final BuildContext context;

  _PrecioDataSource(this._precios, this.mercados, this.context);

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
        DataCell(Text('${p.fechaActualizacion.toLocal().toString().split(' ').first}')),
        DataCell(ElevatedButton(
          child: const Text('Ver productos'),
          onPressed: () {
            // En un flujo real navegaríamos a la vista de productos filtrada por mercado
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ver productos en ${_marketName(p.mercadoId)}')));
          },
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

