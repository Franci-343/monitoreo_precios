import 'package:flutter/material.dart';
import 'package:monitoreo_precios/services/reporte_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/models/reporte_model.dart';

class ReporteView extends StatefulWidget {
  const ReporteView({Key? key}) : super(key: key);

  @override
  State<ReporteView> createState() => _ReporteViewState();
}

class _ReporteViewState extends State<ReporteView> {
  List<Reporte> _reports = [];
  List<String> _productos = [];
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
    setState(() {
      _reports = reports;
      _productos = productos.map((p) => p.nombre).toList();
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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProducto.isEmpty ? null : _selectedProducto,
                    items: [const DropdownMenuItem(value: '', child: Text('Todos los productos'))]
                        .followedBy(_productos.map((p) => DropdownMenuItem(value: p, child: Text(p))))
                        .toList(),
                    onChanged: (v) async {
                      setState(() => _selectedProducto = v ?? '');
                      await _filterByProductName(_selectedProducto);
                    },
                    decoration: const InputDecoration(labelText: 'Filtrar por producto'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _loadAll, child: const Text('Refrescar')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _reports.isEmpty
                      ? const Center(child: Text('No hay reportes'))
                      : ListView.builder(
                          itemCount: _reports.length,
                          itemBuilder: (context, index) {
                            final r = _reports[index];
                            return Card(
                              child: ListTile(
                                title: Text('Producto ID: ${r.productoId} — ${r.valorReportado.toStringAsFixed(2)} Bs'),
                                subtitle: Text('Mercado ID: ${r.mercadoId} • Fecha: ${r.fechaReporte.toLocal().toString().split(' ').first}'),
                                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteReport(r.id)),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}

