import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/mercado_model.dart';
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/models/precio_model.dart';
import 'package:monitoreo_precios/models/categoria_model.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/services/precio_service.dart';
import 'package:monitoreo_precios/widgets/web3_widgets.dart';

/// Vista para comparar precios entre DOS mercados lado a lado
class CompararMercadosView extends StatefulWidget {
  const CompararMercadosView({Key? key}) : super(key: key);

  @override
  State<CompararMercadosView> createState() => _CompararMercadosViewState();
}

class _CompararMercadosViewState extends State<CompararMercadosView> {
  List<Mercado> _mercados = [];
  List<Producto> _productos = [];
  List<Categoria> _categorias = [];

  Mercado? _mercadoIzquierda;
  Mercado? _mercadoDerecha;
  Categoria? _categoriaSeleccionada;

  Map<int, Precio?> _preciosMercadoIzq = {}; // producto_id -> precio
  Map<int, Precio?> _preciosMercadoDer = {}; // producto_id -> precio

  bool _loading = true;
  bool _loadingPrecios = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);

    try {
      final mercados = await ProductoService.fetchMarkets();
      final categorias = await ProductoService.fetchCategoriesComplete();

      setState(() {
        _mercados = mercados;
        _categorias = categorias;

        // Pre-seleccionar los dos primeros mercados si existen
        if (_mercados.length >= 2) {
          _mercadoIzquierda = _mercados[0];
          _mercadoDerecha = _mercados[1];
        }

        _loading = false;
      });

      // Cargar productos de la primera categoría
      if (_categorias.isNotEmpty) {
        _onCategoriaChanged(_categorias[0]);
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _onCategoriaChanged(Categoria? categoria) async {
    if (categoria == null) return;

    setState(() {
      _categoriaSeleccionada = categoria;
      _loadingPrecios = true;
    });

    try {
      final productos = await ProductoService.fetchProductsByCategory(
        categoria.id,
      );
      setState(() => _productos = productos);

      await _loadPrecios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    } finally {
      setState(() => _loadingPrecios = false);
    }
  }

  Future<void> _loadPrecios() async {
    if (_mercadoIzquierda == null || _mercadoDerecha == null) return;

    setState(() => _loadingPrecios = true);

    final Map<int, Precio?> preciosIzq = {};
    final Map<int, Precio?> preciosDer = {};

    try {
      // Cargar precios para cada producto en ambos mercados
      for (final producto in _productos) {
        // Mercado izquierdo
        final precioIzq = await PrecioService().getPrecioActual(
          producto.id,
          _mercadoIzquierda!.id,
        );
        preciosIzq[producto.id] = precioIzq;

        // Mercado derecho
        final precioDer = await PrecioService().getPrecioActual(
          producto.id,
          _mercadoDerecha!.id,
        );
        preciosDer[producto.id] = precioDer;
      }

      setState(() {
        _preciosMercadoIzq = preciosIzq;
        _preciosMercadoDer = preciosDer;
        _loadingPrecios = false;
      });
    } catch (e) {
      setState(() => _loadingPrecios = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar precios: $e')));
      }
    }
  }

  Future<void> _onMercadoChanged() async {
    if (_mercadoIzquierda != null && _mercadoDerecha != null) {
      await _loadPrecios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Comparar Mercados'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Web3GradientBackground(
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FFF0)),
                )
              : Column(
                  children: [
                    const SizedBox(height: 16),

                    // Header con selectores
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Web3GlassCard(
                        child: Column(
                          children: [
                            // Título
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6),
                                      ],
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
                                const Expanded(
                                  child: Text(
                                    'Comparación de Mercados',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Selector de categoría
                            _buildCategorySelector(),
                            const SizedBox(height: 16),

                            // Selectores de mercados lado a lado
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMarketSelector(
                                    'Mercado A',
                                    _mercadoIzquierda,
                                    (mercado) {
                                      setState(
                                        () => _mercadoIzquierda = mercado,
                                      );
                                      _onMercadoChanged();
                                    },
                                    const Color(0xFF6366F1),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildMarketSelector(
                                    'Mercado B',
                                    _mercadoDerecha,
                                    (mercado) {
                                      setState(() => _mercadoDerecha = mercado);
                                      _onMercadoChanged();
                                    },
                                    const Color(0xFF06B6D4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tabla de comparación
                    Expanded(
                      child: _loadingPrecios
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF00FFF0),
                              ),
                            )
                          : _buildComparisonTable(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.category, color: Color(0xFF00FFF0), size: 20),
          const SizedBox(width: 12),
          const Text(
            'Categoría:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Categoria>(
                value: _categoriaSeleccionada,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                items: _categorias.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.nombre));
                }).toList(),
                onChanged: _onCategoriaChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketSelector(
    String label,
    Mercado? selected,
    void Function(Mercado?) onChanged,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<Mercado>(
              value: selected,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: _mercados.map((mercado) {
                return DropdownMenuItem(
                  value: mercado,
                  child: Text(mercado.nombre, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    if (_productos.isEmpty) {
      return Center(
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
                  Icons.shopping_basket,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay productos en esta categoría',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Web3GlassCard(
        child: Column(
          children: [
            // Header de la tabla
            _buildTableHeader(),
            const Divider(color: Color(0xFF6366F1), height: 1),

            // Filas de productos
            Expanded(
              child: ListView.separated(
                itemCount: _productos.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Color(0xFF6366F1), height: 1),
                itemBuilder: (context, index) {
                  final producto = _productos[index];
                  return _buildProductRow(producto);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.2),
            const Color(0xFF8B5CF6).withOpacity(0.2),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Producto',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _mercadoIzquierda?.nombre.split(' ').first ?? 'Mercado A',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _mercadoDerecha?.nombre.split(' ').first ?? 'Mercado B',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(Producto producto) {
    final precioIzq = _preciosMercadoIzq[producto.id];
    final precioDer = _preciosMercadoDer[producto.id];

    // Calcular cuál es más barato
    bool? izqMasBarato;

    if (precioIzq != null && precioDer != null) {
      izqMasBarato = precioIzq.valor < precioDer.valor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Nombre del producto
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (producto.unidadMedida != null)
                  Text(
                    producto.unidadMedida!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Precio mercado izquierda
          Expanded(
            flex: 1,
            child: _buildPriceCell(
              precioIzq,
              izqMasBarato == true ? const Color(0xFFEF4444) : null,
            ),
          ),

          // Precio mercado derecha
          Expanded(
            flex: 1,
            child: _buildPriceCell(
              precioDer,
              izqMasBarato == false ? const Color(0xFFEF4444) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCell(Precio? precio, Color? highlightColor) {
    if (precio == null) {
      return Center(
        child: Text(
          '---',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: highlightColor != null
          ? BoxDecoration(
              color: highlightColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: highlightColor.withOpacity(0.5),
                width: 1,
              ),
            )
          : null,
      child: Text(
        '${precio.valor.toStringAsFixed(2)} Bs',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: highlightColor ?? Colors.white,
          fontWeight: highlightColor != null
              ? FontWeight.w700
              : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}
