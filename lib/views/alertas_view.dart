import 'package:flutter/material.dart';
import 'package:monitoreo_precios/models/alerta_model.dart';
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/models/mercado_model.dart';
import 'package:monitoreo_precios/services/alert_service.dart';
import 'package:monitoreo_precios/services/auth_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';
import 'package:monitoreo_precios/main.dart';

class AlertasView extends StatefulWidget {
  const AlertasView({super.key});

  @override
  State<AlertasView> createState() => _AlertasViewState();
}

class _AlertasViewState extends State<AlertasView> {
  List<Alerta> _alertas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = AuthService();
      final usuario = authService.getCurrentUser();
      if (usuario == null) {
        throw Exception('Usuario no autenticado');
      }

      final alertas = await AlertService.getAlertasUsuario(usuario.id);
      setState(() {
        _alertas = alertas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAlerta(Alerta alerta) async {
    try {
      await AlertService.toggleAlerta(alerta.id, !alerta.activo);
      _cargarAlertas(); // Recargar lista
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              alerta.activo ? 'Alerta desactivada' : 'Alerta activada',
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _eliminarAlerta(Alerta alerta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          '¿Eliminar alerta?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta alerta para ${alerta.productoNombre ?? "este producto"}?',
          style: const TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AlertService.eliminarAlerta(alerta.id);
        _cargarAlertas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alerta eliminada'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }

  void _mostrarFormularioNuevaAlerta() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _FormularioNuevaAlerta(),
    ).then((created) {
      if (created == true) {
        _cargarAlertas();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Mis Alertas de Precio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar alertas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFF9CA3AF)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _cargarAlertas,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _alertas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: const Color(0xFF374151),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes alertas',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea alertas para recibir notificaciones\ncuando los precios cambien',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarAlertas,
              color: const Color(0xFF06B6D4),
              backgroundColor: const Color(0xFF1F2937),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header con estadísticas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_alertas.length} ${_alertas.length == 1 ? "alerta" : "alertas"}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_alertas.where((a) => a.activo).length} activas',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lista de alertas
                  ..._alertas.map((alerta) => _buildAlertaCard(alerta)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarFormularioNuevaAlerta,
        backgroundColor: const Color(0xFF06B6D4),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Alerta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAlertaCard(Alerta alerta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alerta.notificado
              ? const Color(0xFFEF4444)
              : alerta.activo
              ? const Color(0xFF10B981)
              : const Color(0xFF374151),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: alerta.notificado
                  ? const Color(0xFFEF4444).withOpacity(0.1)
                  : alerta.activo
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFF374151).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  alerta.notificado
                      ? Icons.notification_important
                      : Icons.notifications,
                  color: alerta.notificado
                      ? const Color(0xFFEF4444)
                      : alerta.activo
                      ? const Color(0xFF10B981)
                      : const Color(0xFF6B7280),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alerta.productoNombre ??
                            'Producto #${alerta.productoId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (alerta.mercadoNombre != null)
                        Text(
                          alerta.mercadoNombre!,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: alerta.activo,
                  onChanged: (_) => _toggleAlerta(alerta),
                  activeColor: const Color(0xFF10B981),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      alerta.esAlertaPrecioBajo
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: alerta.esAlertaPrecioBajo
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alerta.descripcion,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Color(0xFF06B6D4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bs. ${alerta.precioObjetivo.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (alerta.notificado) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '¡ALERTA ACTIVADA!',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Footer
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF374151).withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _eliminarAlerta(alerta),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// FORMULARIO NUEVA ALERTA
// ============================================

class _FormularioNuevaAlerta extends StatefulWidget {
  const _FormularioNuevaAlerta();

  @override
  State<_FormularioNuevaAlerta> createState() => _FormularioNuevaAlertaState();
}

class _FormularioNuevaAlertaState extends State<_FormularioNuevaAlerta> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();

  List<Producto> _productos = [];
  List<Mercado> _mercados = [];
  Producto? _productoSeleccionado;
  Mercado? _mercadoSeleccionado;
  String _tipoAlerta = 'menor_o_igual';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final productos = await ProductoService.fetchProducts();
      final mercados = await _cargarMercados();
      setState(() {
        _productos = productos;
        _mercados = mercados;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<List<Mercado>> _cargarMercados() async {
    try {
      final response = await supabase
          .from('mercados')
          .select()
          .eq('activo', true)
          .order('nombre');

      return (response as List).map((json) => Mercado.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar mercados: $e');
    }
  }

  Future<void> _crearAlerta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un producto'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final usuario = authService.getCurrentUser();
      if (usuario == null) throw Exception('Usuario no autenticado');

      await AlertService.crearAlerta(
        usuarioId: usuario.id,
        productoId: _productoSeleccionado!.id,
        mercadoId: _mercadoSeleccionado?.id,
        precioObjetivo: double.parse(_precioController.text),
        tipoAlerta: _tipoAlerta,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta creada exitosamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nueva Alerta de Precio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Producto>(
              value: _productoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Producto',
                labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                ),
                filled: true,
                fillColor: const Color(0xFF111827),
              ),
              dropdownColor: const Color(0xFF1F2937),
              style: const TextStyle(color: Colors.white),
              items: _productos.map((p) {
                return DropdownMenuItem(value: p, child: Text(p.nombre));
              }).toList(),
              onChanged: (value) {
                setState(() => _productoSeleccionado = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Mercado>(
              value: _mercadoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Mercado (opcional)',
                labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                ),
                filled: true,
                fillColor: const Color(0xFF111827),
              ),
              dropdownColor: const Color(0xFF1F2937),
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem<Mercado>(
                  value: null,
                  child: Text('Todos los mercados'),
                ),
                ..._mercados.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m.nombre));
                }),
              ],
              onChanged: (value) {
                setState(() => _mercadoSeleccionado = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoAlerta,
              decoration: InputDecoration(
                labelText: 'Tipo de Alerta',
                labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                ),
                filled: true,
                fillColor: const Color(0xFF111827),
              ),
              dropdownColor: const Color(0xFF1F2937),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(
                  value: 'menor_o_igual',
                  child: Text('Precio menor o igual a'),
                ),
                DropdownMenuItem(
                  value: 'mayor_o_igual',
                  child: Text('Precio mayor o igual a'),
                ),
              ],
              onChanged: (value) {
                setState(() => _tipoAlerta = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precioController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Precio Objetivo (Bs.)',
                labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(
                  Icons.monetization_on,
                  color: Color(0xFF06B6D4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                ),
                filled: true,
                fillColor: const Color(0xFF111827),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un precio';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingresa un número válido';
                }
                if (double.parse(value) <= 0) {
                  return 'El precio debe ser mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9CA3AF),
                      side: const BorderSide(color: Color(0xFF374151)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _crearAlerta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text(
                            'Crear Alerta',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }
}
