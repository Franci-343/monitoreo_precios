import 'package:flutter/material.dart';
import 'package:monitoreo_precios/main.dart';
import 'package:monitoreo_precios/models/mercado_model.dart';

class AdminMercadosView extends StatefulWidget {
  const AdminMercadosView({super.key});

  @override
  State<AdminMercadosView> createState() => _AdminMercadosViewState();
}

class _AdminMercadosViewState extends State<AdminMercadosView> {
  List<Mercado> _mercados = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filtroTipo = 'todos'; // todos, mercado, supermercado

  @override
  void initState() {
    super.initState();
    _cargarMercados();
  }

  Future<void> _cargarMercados() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('mercados')
          .select('*')
          .order('nombre', ascending: true);
      setState(() {
        _mercados = (response as List)
            .map((json) => Mercado.fromMap(json))
            .toList();
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

  List<Mercado> get _mercadosFiltrados {
    var filtrados = _mercados;

    // Filtrar por tipo
    if (_filtroTipo != 'todos') {
      filtrados = filtrados.where((m) => m.tipo == _filtroTipo).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((m) {
        return m.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.zona.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (m.direccion?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    return filtrados;
  }

  Future<void> _mostrarFormulario({Mercado? mercado}) async {
    await showDialog(
      context: context,
      builder: (context) => _FormularioMercado(mercado: mercado),
    );
    _cargarMercados();
  }

  Future<void> _eliminarMercado(Mercado mercado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
        title: const Text(
          '¿Eliminar Mercado?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de eliminar "${mercado.nombre}"?\nEsto también eliminará sus precios asociados.',
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
        await supabase.from('mercados').delete().eq('id', mercado.id);
        _cargarMercados();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mercado eliminado correctamente'),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E).withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Buscador y botón
                  isMobile
                      ? Column(
                          children: [
                            TextField(
                              onChanged: (value) =>
                                  setState(() => _searchQuery = value),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Buscar mercados...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB4B4B8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF00FFF0),
                                ),
                                filled: true,
                                fillColor: const Color(0xFF0F0F23),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.3),
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
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () => _mostrarFormulario(),
                                  icon: const Icon(
                                    Icons.add_business_rounded,
                                    size: 20,
                                  ),
                                  label: const Text('Nuevo Mercado'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) =>
                                    setState(() => _searchQuery = value),
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Buscar mercados...',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFFB4B4B8),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF00FFF0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF0F0F23),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withOpacity(0.3),
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
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _mostrarFormulario(),
                                icon: const Icon(Icons.add_business_rounded),
                                label: const Text('Nuevo Mercado'),
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
                  const SizedBox(height: 16),
                  // Filtros por tipo
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFiltroChip(
                          'Todos',
                          'todos',
                          Icons.grid_view_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildFiltroChip(
                          'Mercados',
                          'mercado',
                          Icons.store_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildFiltroChip(
                          'Supermercados',
                          'supermercado',
                          Icons.shopping_cart_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Lista
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00FFF0),
                      ),
                    )
                  : _mercadosFiltrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_mall_directory_outlined,
                            size: 64,
                            color: const Color(0xFFB4B4B8).withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay mercados'
                                : 'No se encontraron mercados',
                            style: const TextStyle(
                              color: Color(0xFFB4B4B8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      itemCount: _mercadosFiltrados.length,
                      itemBuilder: (context, index) {
                        final mercado = _mercadosFiltrados[index];
                        final esSupermercado = mercado.tipo == 'supermercado';

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
                            contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                            leading: Container(
                              width: isMobile ? 48 : 56,
                              height: isMobile ? 48 : 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: esSupermercado
                                      ? [
                                          const Color(0xFF06B6D4),
                                          const Color(0xFF3B82F6),
                                        ]
                                      : [
                                          const Color(0xFF6366F1),
                                          const Color(0xFF8B5CF6),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                esSupermercado
                                    ? Icons.shopping_cart_rounded
                                    : Icons.store_rounded,
                                color: Colors.white,
                                size: isMobile ? 24 : 28,
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    mercado.nombre,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: esSupermercado
                                        ? const Color(
                                            0xFF06B6D4,
                                          ).withOpacity(0.2)
                                        : const Color(
                                            0xFF8B5CF6,
                                          ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: esSupermercado
                                          ? const Color(0xFF06B6D4)
                                          : const Color(0xFF8B5CF6),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    esSupermercado ? 'SUPER' : 'MERCADO',
                                    style: TextStyle(
                                      color: esSupermercado
                                          ? const Color(0xFF06B6D4)
                                          : const Color(0xFF8B5CF6),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: isMobile ? 14 : 16,
                                      color: const Color(0xFF00FFF0),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        mercado.zona,
                                        style: TextStyle(
                                          color: const Color(0xFFB4B4B8),
                                          fontSize: isMobile ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (mercado.direccion != null) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.map_rounded,
                                        size: isMobile ? 14 : 16,
                                        color: const Color(0xFFB4B4B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          mercado.direccion!,
                                          style: TextStyle(
                                            color: const Color(0xFFB4B4B8),
                                            fontSize: isMobile ? 11 : 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: isMobile
                                ? PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert_rounded,
                                      color: Color(0xFFB4B4B8),
                                    ),
                                    color: const Color(0xFF16213E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: const Color(
                                          0xFF6366F1,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _mostrarFormulario(mercado: mercado);
                                      } else if (value == 'delete') {
                                        _eliminarMercado(mercado);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_rounded,
                                              color: Color(0xFF06B6D4),
                                              size: 20,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Editar',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_rounded,
                                              color: Color(0xFFEF4444),
                                              size: 20,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_rounded,
                                          color: Color(0xFF06B6D4),
                                        ),
                                        onPressed: () => _mostrarFormulario(
                                          mercado: mercado,
                                        ),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_rounded,
                                          color: Color(0xFFEF4444),
                                        ),
                                        onPressed: () =>
                                            _eliminarMercado(mercado),
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
      },
    );
  }

  Widget _buildFiltroChip(String label, String valor, IconData icon) {
    final isSelected = _filtroTipo == valor;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.black : const Color(0xFFB4B4B8),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filtroTipo = valor);
      },
      backgroundColor: const Color(0xFF16213E).withOpacity(0.3),
      selectedColor: const Color(0xFF00FFF0),
      checkmarkColor: Colors.black,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : const Color(0xFFB4B4B8),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF00FFF0)
            : const Color(0xFF6366F1).withOpacity(0.3),
      ),
    );
  }
}

// ============================================
// FORMULARIO
// ============================================

class _FormularioMercado extends StatefulWidget {
  final Mercado? mercado;

  const _FormularioMercado({this.mercado});

  @override
  State<_FormularioMercado> createState() => _FormularioMercadoState();
}

class _FormularioMercadoState extends State<_FormularioMercado> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _zonaController;
  late TextEditingController _direccionController;
  String _tipo = 'mercado';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.mercado?.nombre);
    _zonaController = TextEditingController(text: widget.mercado?.zona);
    _direccionController = TextEditingController(
      text: widget.mercado?.direccion,
    );
    _tipo = widget.mercado?.tipo ?? 'mercado';
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'zona': _zonaController.text.trim(),
        'direccion': _direccionController.text.trim().isEmpty
            ? null
            : _direccionController.text.trim(),
        'tipo': _tipo,
        'activo': true,
      };

      if (widget.mercado == null) {
        await supabase.from('mercados').insert(data);
      } else {
        await supabase
            .from('mercados')
            .update(data)
            .eq('id', widget.mercado!.id);
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.mercado == null ? 'Mercado creado' : 'Mercado actualizado',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.mercado == null ? 'Nuevo Mercado' : 'Editar Mercado',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre del mercado',
                icon: Icons.business_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _zonaController,
                label: 'Zona',
                icon: Icons.location_city_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                hint: 'Ej: Centro, Sopocachi, Villa Fátima',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _direccionController,
                label: 'Dirección (opcional)',
                icon: Icons.map_rounded,
                hint: 'Ej: Av. 20 de Octubre',
              ),
              const SizedBox(height: 16),
              // Selector de tipo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F23).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tipo de establecimiento',
                          style: TextStyle(
                            color: Color(0xFFB4B4B8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTipoOption(
                            'Mercado',
                            'mercado',
                            Icons.store_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTipoOption(
                            'Supermercado',
                            'supermercado',
                            Icons.shopping_cart_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFFB4B4B8)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _guardar,
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
                : const Text('Guardar'),
          ),
        ),
      ],
    );
  }

  Widget _buildTipoOption(String label, String valor, IconData icon) {
    final isSelected = _tipo == valor;
    return InkWell(
      onTap: () => setState(() => _tipo = valor),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF0F0F23),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFF6366F1).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFFB4B4B8),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFB4B4B8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB4B4B8)),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
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
          borderSide: const BorderSide(color: Color(0xFF00FFF0), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _zonaController.dispose();
    _direccionController.dispose();
    super.dispose();
  }
}
