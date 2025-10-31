import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/models/mercado_model.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/services/precio_service.dart';
import 'package:monitoreo_precios/services/favorito_service.dart';
import 'package:monitoreo_precios/models/favorito_model.dart';
import 'package:monitoreo_precios/views/comparador_view.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';

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
    var prods = await ProductoService.fetchProducts(
      query: query,
      categoria: categoria,
    );

    // Si hay market seleccionado, filtrar productos que tengan precio en ese mercado
    if (_selectedMarket != null) {
      // Filtrar productos que tengan al menos un precio reportado en el mercado seleccionado
      final filtered = <Producto>[];
      for (final p in prods) {
        final prices = await PrecioService.fetchPricesByProductAndMarket(
          p.id,
          _selectedMarket!.id,
        );
        if (prices.isNotEmpty) filtered.add(p);
      }
      prods = filtered;
    }

    setState(() {
      _productos = prods;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(int productoId) async {
    if (_favoriteProductIds.contains(productoId)) {
      await FavoritoService.removeFavorite(_currentUserId, productoId);
      setState(() => _favoriteProductIds.remove(productoId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Eliminado de favoritos')));
      }
    } else {
      await FavoritoService.addFavorite(_currentUserId, productoId);
      setState(() => _favoriteProductIds.add(productoId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Agregado a favoritos')));
      }
    }
  }

  List<Color> _getCategoryColors(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'frutas':
        return [const Color(0xFFEC4899), const Color(0xFFF97316)];
      case 'verduras':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case 'carnes':
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case 'granos':
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case 'lacteos':
        return [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'frutas':
        return Icons.local_grocery_store;
      case 'verduras':
        return Icons.eco;
      case 'carnes':
        return Icons.restaurant;
      case 'granos':
        return Icons.grain;
      case 'lacteos':
        return Icons.local_drink;
      default:
        return Icons.shopping_basket;
    }
  }

  Future<void> _showFiltersSheet() async {
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Filtros de búsqueda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Dropdown de categorías
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.category,
                      color: Color(0xFF00FFF0),
                    ),
                    title: Text(
                      'Seleccionar categoría',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    onTap: () => _showCategoryPicker(),
                  ),
                ),
                const SizedBox(height: 16),

                // Dropdown de mercados
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.store, color: Color(0xFF00FFF0)),
                    title: Text(
                      'Seleccionar mercado',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    onTap: () => _showMarketPicker(),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = '';
                            _selectedMarket = null;
                          });
                          _search();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Limpiar filtros',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Web3GradientButton(
                        text: 'Aplicar',
                        onPressed: () {
                          _search();
                          Navigator.pop(ctx);
                        },
                        icon: Icons.check,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCategoryPicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text(
            'Seleccionar categoría',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Todas las categorías',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ''),
              ),
              ..._categorias.map(
                (categoria) => ListTile(
                  title: Text(
                    categoria,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, categoria),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _selectedCategory = selected);
    }
  }

  Future<void> _showMarketPicker() async {
    final selected = await showDialog<Mercado?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text(
            'Seleccionar mercado',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Todos los mercados',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, null),
              ),
              ..._mercados.map(
                (mercado) => ListTile(
                  title: Text(
                    mercado.nombre,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, mercado),
                ),
              ),
            ],
          ),
        );
      },
    );
    // Asignar directamente; puede ser null para representar "todos los mercados".
    setState(() => _selectedMarket = selected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showFiltersSheet(),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Barra de búsqueda compacta
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Web3NeonTextField(
                        hintText: 'Buscar producto...',
                        controller: _searchController,
                        prefixIcon: Icons.search,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Web3FloatingActionButton(
                      onPressed: _showFiltersSheet,
                      icon: Icons.tune,
                      heroTag: "filters",
                    ),
                  ],
                ),
              ),

              // Chips de filtros activos (compactos)
              if (_selectedCategory.isNotEmpty || _selectedMarket != null)
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_selectedCategory.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(_selectedCategory),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() => _selectedCategory = '');
                              _search();
                            },
                            backgroundColor: const Color(0xFF6366F1),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                      if (_selectedMarket != null)
                        Chip(
                          label: Text(_selectedMarket!.nombre),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() => _selectedMarket = null);
                            _search();
                          },
                          backgroundColor: const Color(0xFF00FFF0),
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                    ],
                  ),
                ),

              // Lista de productos
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00FFF0),
                        ),
                      )
                    : _productos.isEmpty
                    ? Center(
                        child: Web3GlassCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
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
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No encontramos productos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Intenta con otros filtros o términos de búsqueda',
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
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          itemCount: _productos.length,
                          itemBuilder: (context, index) {
                            final producto = _productos[index];
                            final isFavorite = _favoriteProductIds.contains(
                              producto.id,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Web3GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Icono de categoría
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _getCategoryColors(
                                              producto.categoria,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(producto.categoria),
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Información del producto
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              producto.nombre,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF00FFF0,
                                                ).withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                producto.categoria
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF00FFF0),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Botones de acción
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () =>
                                                _toggleFavorite(producto.id),
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorite
                                                  ? Colors.red
                                                  : Colors.white.withOpacity(
                                                      0.7,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ComparadorView(
                                                        productoId: producto.id,
                                                        productoNombre:
                                                            producto.nombre,
                                                      ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF6366F1,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              minimumSize: Size.zero,
                                            ),
                                            child: const Text(
                                              'Ver precios',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
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
