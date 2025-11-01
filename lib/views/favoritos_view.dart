import 'package:flutter/material.dart';
import 'package:monitoreo_precios/services/favorito_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/views/donde_encontrar_view.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';

class FavoritosView extends StatefulWidget {
  const FavoritosView({Key? key}) : super(key: key);

  @override
  State<FavoritosView> createState() => _FavoritosViewState();
}

class _FavoritosViewState extends State<FavoritosView> {
  static const int _currentUserId = 1;
  List<Producto> _favoritos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    final favs = await FavoritoService.getFavoritesForUser(_currentUserId);
    final allProducts = await ProductoService.fetchProducts();
    final favProducts = allProducts
        .where((p) => favs.any((f) => f.productoId == p.id))
        .toList();
    setState(() {
      _favoritos = favProducts;
      _loading = false;
    });
  }

  Future<void> _remove(int productoId) async {
    await FavoritoService.removeFavorite(_currentUserId, productoId);
    await _loadFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorito eliminado'),
          backgroundColor: Color(0xFF00FFF0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FFF0)),
                )
              : _favoritos.isEmpty
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
                            Icons.favorite_border,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No tienes favoritos aún',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Agrega productos a favoritos para acceder rápidamente a sus precios',
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        '${_favoritos.length} productos favoritos',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _favoritos.length,
                          itemBuilder: (context, index) {
                            final producto = _favoritos[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Web3GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFEC4899),
                                                  Color(0xFFF97316),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.favorite,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  producto.nombre,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF00FFF0,
                                                    ).withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    producto.categoria
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF00FFF0),
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _remove(producto.id),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Web3GradientButton(
                                          text: '¿Dónde Encontrar?',
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DondeEncontrarView(
                                                      productoId: producto.id,
                                                      productoNombre:
                                                          producto.nombre,
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: Icons.location_on,
                                        ),
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
}
