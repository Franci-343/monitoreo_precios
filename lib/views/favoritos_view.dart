import 'package:flutter/material.dart';
import 'package:monitoreo_precios/services/favorito_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/views/comparador_view.dart';

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
    final favProducts = allProducts.where((p) => favs.any((f) => f.productoId == p.id)).toList();
    setState(() {
      _favoritos = favProducts;
      _loading = false;
    });
  }

  Future<void> _remove(int productoId) async {
    await FavoritoService.removeFavorite(_currentUserId, productoId);
    await _loadFavorites();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favorito eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _favoritos.isEmpty
                ? const Center(child: Text('No tienes favoritos'))
                : ListView.builder(
                    itemCount: _favoritos.length,
                    itemBuilder: (context, index) {
                      final p = _favoritos[index];
                      return Card(
                        child: ListTile(
                          title: Text(p.nombre),
                          subtitle: Text(p.categoria),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _remove(p.id),
                              ),
                              ElevatedButton(
                                child: const Text('Comparar precios'),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComparadorView(productoId: p.id, productoNombre: p.nombre)));
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

