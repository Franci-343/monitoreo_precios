import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/models/mercado_model.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/services/precio_service.dart';
import 'package:monitoreo_precios/services/favorito_service.dart';
import 'package:monitoreo_precios/models/favorito_model.dart';
import 'package:monitoreo_precios/views/comparador_view.dart';

class ProductoView extends StatefulWidget {
  const ProductoView({Key? key}) : super(key: key);

  @override
  State<ProductoView> createState() => _ProductoViewState();
}

class _ProductoViewState extends State<ProductoView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  Mercado? _selectedMarket;

  // Simular usuario autenticado (temporal)
  static const int _currentUserId = 1;
  Set<int> _favoriteProductIds = {};

  List<Producto> _productos = [];
  List<String> _categorias = [];
  List<Mercado> _mercados = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _loadFavorites();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final cats = await ProductoService.fetchCategories();
    final markets = await ProductoService.fetchMarkets();
    final prods = await ProductoService.fetchProducts();
    setState(() {
      _categorias = cats;
      _mercados = markets;
      _productos = prods;
      _loading = false;
    });
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritoService.getFavoritesForUser(_currentUserId);
    setState(() {
      _favoriteProductIds = favs.map((f) => f.productoId).toSet();
    });
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    final query = _searchController.text;
    final categoria = _selectedCategory.isEmpty ? null : _selectedCategory;
    var prods = await ProductoService.fetchProducts(query: query, categoria: categoria);

    // Si hay market seleccionado, filtrar productos que tengan precio en ese mercado
    if (_selectedMarket != null) {
      // Filtrar productos que tengan al menos un precio reportado en el mercado seleccionado
      final filtered = <Producto>[];
      for (final p in prods) {
        final prices = await PrecioService.fetchPricesByProductAndMarket(p.id, _selectedMarket!.id);
        if (prices.isNotEmpty) filtered.add(p);
      }
      prods = filtered;
    }

    setState(() {
      _productos = prods;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de productos')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _search, child: const Text('Buscar')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
                    items: [const DropdownMenuItem(value: '', child: Text('Todas las categorías'))]
                        .followedBy(_categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCategory = v ?? '';
                      });
                      _search();
                    },
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<Mercado>(
                    initialValue: _selectedMarket,
                    items: [
                      const DropdownMenuItem<Mercado>(value: null, child: Text('Todos los mercados'))
                    ].followedBy(_mercados.map((m) => DropdownMenuItem(value: m, child: Text(m.nombre)))).toList(),
                    onChanged: (v) async {
                      setState(() {
                        _selectedMarket = v;
                      });
                      await _search();
                    },
                    decoration: const InputDecoration(labelText: 'Mercado / Zona'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _productos.isEmpty
                      ? const Center(child: Text('No se encontraron productos'))
                      : ListView.builder(
                          itemCount: _productos.length,
                          itemBuilder: (context, index) {
                            final p = _productos[index];
                            final isFav = _favoriteProductIds.contains(p.id);
                            return Card(
                              child: ListTile(
                                leading: IconButton(
                                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                                  onPressed: () async {
                                    await FavoritoService.toggleFavorite(_currentUserId, p.id);
                                    await _loadFavorites();
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isFav ? 'Eliminado de favoritos' : 'Agregado a favoritos')));
                                  },
                                ),
                                title: Text(p.nombre),
                                subtitle: Text(p.categoria),
                                trailing: ElevatedButton(
                                  child: const Text('Comparar precios'),
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => ComparadorView(productoId: p.id, productoNombre: p.nombre),
                                    ));
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
