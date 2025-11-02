import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/models/categoria_model.dart';
import 'package:monitoreo_precios/models/mercado_model.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/main.dart';

class AdminProductosView extends StatefulWidget {
  const AdminProductosView({super.key});

  @override
  State<AdminProductosView> createState() => _AdminProductosViewState();
}

class _AdminProductosViewState extends State<AdminProductosView> {
  final _productoService = ProductoService();
  List<Producto> _productos = [];
  List<Categoria> _categorias = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final productos = await _productoService.getProductos();
      final categorias = await _productoService.getCategorias();
      setState(() {
        _productos = productos;
        _categorias = categorias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Producto> get _productosFiltrados {
    if (_searchQuery.isEmpty) return _productos;
    return _productos
        .where(
          (p) => p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Future<void> _mostrarFormulario({Producto? producto}) async {
    await showDialog(
      context: context,
      builder: (context) =>
          _FormularioProducto(producto: producto, categorias: _categorias),
    );
    _cargarDatos();
  }

  Future<void> _eliminarProducto(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E), // cardGlass
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
        title: const Text(
          '¿Eliminar Producto?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de eliminar "${producto.nombre}"?',
          style: const TextStyle(color: Color(0xFFB4B4B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFB4B4B8)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Eliminar'),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await supabase.from('productos').delete().eq('id', producto.id);
        _cargarDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E).withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF6366F1).withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    hintStyle: const TextStyle(color: Color(0xFFB4B4B8)),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF00FFF0),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F0F23),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF00FFF0),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarFormulario(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo Producto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FFF0)),
                )
              : _productosFiltrados.isEmpty
              ? const Center(
                  child: Text(
                    'No hay productos',
                    style: TextStyle(color: Color(0xFFB4B4B8), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _productosFiltrados.length,
                  itemBuilder: (context, index) {
                    final producto = _productosFiltrados[index];
                    return Card(
                      elevation: 0,
                      color: const Color(0xFF16213E).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              producto.nombre[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          producto.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${producto.categoria} • ${producto.unidadMedida ?? "unidad"}',
                          style: const TextStyle(color: Color(0xFFB4B4B8)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: Color(0xFF06B6D4),
                              ),
                              onPressed: () =>
                                  _mostrarFormulario(producto: producto),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_rounded,
                                color: Color(0xFFEF4444),
                              ),
                              onPressed: () => _eliminarProducto(producto),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ============================================
// FORMULARIO
// ============================================

class _FormularioProducto extends StatefulWidget {
  final Producto? producto;
  final List<Categoria> categorias;

  const _FormularioProducto({this.producto, required this.categorias});

  @override
  State<_FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends State<_FormularioProducto> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _unidadController;
  int? _categoriaSeleccionada;
  bool _isLoading = false;

  // Para gestión de precios
  List<Mercado> _mercados = [];
  List<Map<String, dynamic>> _preciosIniciales = [];
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto?.nombre);
    _descripcionController = TextEditingController();
    _unidadController = TextEditingController(
      text: widget.producto?.unidadMedida ?? 'unidad',
    );
    _categoriaSeleccionada = widget.producto?.categoriaId;
    _cargarMercados();
  }

  Future<void> _cargarMercados() async {
    try {
      final response = await supabase
          .from('mercados')
          .select('*')
          .eq('activo', true)
          .order('nombre');
      setState(() {
        _mercados = (response as List)
            .map((json) => Mercado.fromMap(json))
            .toList();
      });
    } catch (e) {
      // Silently fail, user can add prices later
    }
  }

  void _agregarPrecio() {
    showDialog(
      context: context,
      builder: (context) => _DialogoAgregarPrecio(
        mercados: _mercados,
        onAgregar: (mercadoId, mercadoNombre, precio) {
          setState(() {
            _preciosIniciales.add({
              'mercado_id': mercadoId,
              'mercado_nombre': mercadoNombre,
              'precio': precio,
            });
          });
        },
      ),
    );
  }

  void _eliminarPrecio(int index) {
    setState(() {
      _preciosIniciales.removeAt(index);
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.producto == null) {
        // Crear producto
        final response = await supabase.from('productos').insert({
          'nombre': _nombreController.text.trim(),
          'categoria_id': _categoriaSeleccionada,
          'descripcion': _descripcionController.text.trim(),
          'unidad_medida': _unidadController.text.trim(),
          'activo': true,
        }).select();

        final productoId = response[0]['id'];

        // Insertar precios iniciales
        if (_preciosIniciales.isNotEmpty) {
          for (var precio in _preciosIniciales) {
            await supabase.from('precios').insert({
              'producto_id': productoId,
              'mercado_id': precio['mercado_id'],
              'precio': precio['precio'],
              'verificado': true,
              'usuario_reporto_id': supabase.auth.currentUser?.id,
            });
          }
        }
      } else {
        // Actualizar
        await supabase
            .from('productos')
            .update({
              'nombre': _nombreController.text.trim(),
              'categoria_id': _categoriaSeleccionada,
              'descripcion': _descripcionController.text.trim(),
              'unidad_medida': _unidadController.text.trim(),
            })
            .eq('id', widget.producto!.id);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        // Usar rootNavigator para cerrar el diálogo correctamente
        Navigator.of(context, rootNavigator: true).pop();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.producto == null
                  ? 'Producto creado con ${_preciosIniciales.length} precios'
                  : 'Producto actualizado',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.producto == null
                  ? Icons.add_shopping_cart_rounded
                  : Icons.edit_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.producto == null ? 'Nuevo Producto' : 'Editar Producto',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0) {
              if (_formKey.currentState!.validate() &&
                  _categoriaSeleccionada != null) {
                setState(() => _currentStep = 1);
              } else if (_categoriaSeleccionada == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selecciona una categoría'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } else {
              _guardar();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_currentStep == 1 ? 'Guardar' : 'Siguiente'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _isLoading ? null : details.onStepCancel,
                    child: Text(
                      _currentStep == 0 ? 'Cancelar' : 'Atrás',
                      style: const TextStyle(color: Color(0xFFB4B4B8)),
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text(
                'Información del Producto',
                style: TextStyle(color: Colors.white),
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: const TextStyle(color: Color(0xFFB4B4B8)),
                        prefixIcon: const Icon(
                          Icons.shopping_bag_rounded,
                          color: Color(0xFF6366F1),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F0F23).withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00FFF0),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _categoriaSeleccionada,
                      dropdownColor: const Color(0xFF0F0F23),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        labelStyle: const TextStyle(color: Color(0xFFB4B4B8)),
                        prefixIcon: const Icon(
                          Icons.category_rounded,
                          color: Color(0xFF6366F1),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F0F23).withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00FFF0),
                            width: 2,
                          ),
                        ),
                      ),
                      items: widget.categorias.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nombre),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _categoriaSeleccionada = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Descripción (opcional)',
                        labelStyle: const TextStyle(color: Color(0xFFB4B4B8)),
                        prefixIcon: const Icon(
                          Icons.description_rounded,
                          color: Color(0xFF6366F1),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F0F23).withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00FFF0),
                            width: 2,
                          ),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unidadController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Unidad de Medida',
                        labelStyle: const TextStyle(color: Color(0xFFB4B4B8)),
                        hintText: 'kg, litro, unidad, etc.',
                        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                        prefixIcon: const Icon(
                          Icons.straighten_rounded,
                          color: Color(0xFF6366F1),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F0F23).withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00FFF0),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text(
                'Precios Iniciales (Opcional)',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: widget.producto != null
                  ? const Text(
                      'Solo al crear productos nuevos',
                      style: TextStyle(color: Color(0xFFB4B4B8), fontSize: 12),
                    )
                  : null,
              content: widget.producto != null
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'La gestión de precios para productos existentes se hace desde la sección "Precios" del panel de administración.',
                        style: TextStyle(
                          color: Color(0xFFB4B4B8),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF06B6D4).withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF06B6D4),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Agrega precios en diferentes mercados (opcional)',
                                  style: TextStyle(
                                    color: Color(0xFF06B6D4),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _agregarPrecio,
                            icon: const Icon(
                              Icons.add_rounded,
                              color: Color(0xFF00FFF0),
                            ),
                            label: const Text(
                              'Agregar Precio',
                              style: TextStyle(color: Color(0xFF00FFF0)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00FFF0)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_preciosIniciales.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 48,
                                    color: const Color(
                                      0xFFB4B4B8,
                                    ).withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Sin precios agregados',
                                    style: TextStyle(
                                      color: Color(0xFFB4B4B8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._preciosIniciales.asMap().entries.map((entry) {
                            final index = entry.key;
                            final precio = entry.value;
                            return Card(
                              color: const Color(0xFF0F0F23).withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF06B6D4),
                                        Color(0xFF3B82F6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.store_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  precio['mercado_nombre'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  'Bs. ${precio['precio'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF00FFF0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  onPressed: () => _eliminarPrecio(index),
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _unidadController.dispose();
    super.dispose();
  }
}

// ============================================
// DIALOGO AGREGAR PRECIO
// ============================================

class _DialogoAgregarPrecio extends StatefulWidget {
  final List<Mercado> mercados;
  final Function(int mercadoId, String mercadoNombre, double precio) onAgregar;

  const _DialogoAgregarPrecio({
    required this.mercados,
    required this.onAgregar,
  });

  @override
  State<_DialogoAgregarPrecio> createState() => _DialogoAgregarPrecioState();
}

class _DialogoAgregarPrecioState extends State<_DialogoAgregarPrecio> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();
  Mercado? _mercadoSeleccionado;

  void _agregar() {
    if (!_formKey.currentState!.validate() || _mercadoSeleccionado == null) {
      if (_mercadoSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona un mercado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final precio = double.tryParse(_precioController.text.trim());
    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Precio inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onAgregar(
      _mercadoSeleccionado!.id,
      _mercadoSeleccionado!.nombre,
      precio,
    );
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      title: const Row(
        children: [
          Icon(Icons.attach_money_rounded, color: Color(0xFF00FFF0)),
          SizedBox(width: 12),
          Text(
            'Agregar Precio',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Mercado>(
              value: _mercadoSeleccionado,
              dropdownColor: const Color(0xFF0F0F23),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Mercado',
                labelStyle: const TextStyle(color: Color(0xFFB4B4B8)),
                prefixIcon: const Icon(
                  Icons.store_rounded,
                  color: Color(0xFF6366F1),
                ),
                filled: true,
                fillColor: const Color(0xFF0F0F23).withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF00FFF0),
                    width: 2,
                  ),
                ),
              ),
              items: widget.mercados.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text('${m.nombre} - ${m.zona}'),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _mercadoSeleccionado = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Precio (Bs)',
                labelStyle: const TextStyle(color: Color(0xFFB4B4B8)),
                prefixIcon: const Icon(
                  Icons.attach_money_rounded,
                  color: Color(0xFF6366F1),
                ),
                filled: true,
                fillColor: const Color(0xFF0F0F23).withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF00FFF0),
                    width: 2,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                final precio = double.tryParse(v);
                if (precio == null || precio <= 0) return 'Precio inválido';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFFB4B4B8)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: _agregar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: const Text('Agregar'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }
}
