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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Consulta de Productos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Título con estilo Web3
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFF0), Color(0xFF6366F1)],
                  ).createShader(bounds),
                  child: const Text(
                    'Encuentra los mejores precios',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Barra de búsqueda mejorada
                Web3GlassCard(
                  child: Column(
                    children: [
                      // Campo de búsqueda
                      Web3NeonTextField(
                        hintText: 'Buscar producto...',
                        controller: _searchController,
                        prefixIcon: Icons.search,
                        suffixIcon: Icons.send,
                        onSuffixIconPressed: _search,
                      ),
                      const SizedBox(height: 16),

                      // Filtros en columna para mejor espacio
                      Column(
                        children: [
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
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory.isEmpty ? null : _selectedCategory,
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('Todas las categorías'),
                                )
                              ].followedBy(
                                _categorias.map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                              ).toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedCategory = v ?? '';
                                });
                                _search();
                              },
                              decoration: InputDecoration(
                                labelText: 'Categoría',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                prefixIcon: Icon(
                                  Icons.category,
                                  color: const Color(0xFF00FFF0).withOpacity(0.7),
                                ),
                              ),
                              dropdownColor: const Color(0xFF1A1A2E),
                              style: const TextStyle(color: Colors.white),
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
                            child: DropdownButtonFormField<Mercado>(
                              value: _selectedMarket,
                              items: [
                                const DropdownMenuItem<Mercado>(
                                  value: null,
                                  child: Text('Todos los mercados'),
                                )
                              ].followedBy(
                                _mercados.map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m.nombre),
                                ))
                              ).toList(),
                              onChanged: (v) async {
                                setState(() {
                                  _selectedMarket = v;
                                });
                                await _search();
                              },
                              decoration: InputDecoration(
                                labelText: 'Mercado / Zona',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                prefixIcon: Icon(
                                  Icons.store,
                                  color: const Color(0xFF00FFF0).withOpacity(0.7),
                                ),
                              ),
                              dropdownColor: const Color(0xFF1A1A2E),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Botón de búsqueda con estilo Web3
                      Web3GradientButton(
                        text: 'Buscar Productos',
                        onPressed: _search,
                        icon: Icons.search,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Lista de productos con mejor diseño
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
                                      padding: const EdgeInsets.all(16),
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
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No se encontraron productos',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Intenta con otros términos de búsqueda',
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
                              itemCount: _productos.length,
                              itemBuilder: (context, index) {
                                final p = _productos[index];
                                final isFav = _favoriteProductIds.contains(p.id);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Web3GlassCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Icono del producto
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.shopping_basket,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // Información del producto
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.nombre,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF00FFF0).withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      p.categoria,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xFF00FFF0),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Botón de favorito
                                            IconButton(
                                              onPressed: () async {
                                                await FavoritoService.toggleFavorite(_currentUserId, p.id);
                                                await _loadFavorites();
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        isFav
                                                          ? 'Eliminado de favoritos'
                                                          : 'Agregado a favoritos'
                                                      ),
                                                      backgroundColor: const Color(0xFF00FFF0).withOpacity(0.8),
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                isFav ? Icons.favorite : Icons.favorite_border,
                                                color: isFav
                                                  ? const Color(0xFF00FFF0)
                                                  : Colors.white.withOpacity(0.5),
                                                size: 28,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Botón de comparar precios
                                        Web3GradientButton(
                                          text: 'Comparar Precios',
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => ComparadorView(
                                                  productoId: p.id,
                                                  productoNombre: p.nombre,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Icons.compare_arrows,
                                          width: double.infinity,
                                        ),
                                      ],
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
}
