import '../models/reporte_model.dart';
import '../services/auth_service.dart';
import '../main.dart';

class ReporteService {
  // Singleton pattern
  static final ReporteService _instance = ReporteService._internal();
  factory ReporteService() => _instance;
  ReporteService._internal();

  final _authService = AuthService();

  // ============================================
  // CREAR REPORTE
  // ============================================
  Future<Reporte> crearReporte({
    required int productoId,
    required int mercadoId,
    required double valorReportado,
    String? notas,
  }) async {
    final user = _authService.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      final response = await supabase
          .from('reportes')
          .insert({
            'usuario_id': user.id,
            'producto_id': productoId,
            'mercado_id': mercadoId,
            'precio_reportado': valorReportado,
            'notas': notas,
            'estado': 'pendiente',
          })
          .select()
          .single();

      return Reporte.fromMap(response);
    } catch (e) {
      throw Exception('Error al crear reporte: $e');
    }
  }

  // ============================================
  // OBTENER MIS REPORTES
  // ============================================
  Future<List<Reporte>> getMisReportes() async {
    final user = _authService.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      final response = await supabase
          .from('reportes')
          .select('*')
          .eq('usuario_id', user.id)
          .order('fecha_reporte', ascending: false);

      return (response as List).map((json) => Reporte.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener reportes: $e');
    }
  }

  // ============================================
  // OBTENER REPORTES POR PRODUCTO
  // ============================================
  Future<List<Reporte>> getReportesPorProducto(int productoId) async {
    try {
      final response = await supabase
          .from('reportes')
          .select('*')
          .eq('producto_id', productoId)
          .order('fecha_reporte', ascending: false);

      return (response as List).map((json) => Reporte.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener reportes: $e');
    }
  }

  // ============================================
  // OBTENER TODOS LOS REPORTES
  // ============================================
  Future<List<Reporte>> getTodosReportes() async {
    try {
      final response = await supabase
          .from('reportes')
          .select('*')
          .order('fecha_reporte', ascending: false);

      return (response as List).map((json) => Reporte.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener reportes: $e');
    }
  }

  // ============================================
  // ELIMINAR REPORTE
  // ============================================
  Future<void> eliminarReporte(int reporteId) async {
    try {
      await supabase.from('reportes').delete().eq('id', reporteId);
    } catch (e) {
      throw Exception('Error al eliminar reporte: $e');
    }
  }

  // ============================================
  // MÉTODOS DE COMPATIBILIDAD
  // ============================================
  static Future<Reporte> addReport(
    int usuarioId,
    int productoId,
    int mercadoId,
    double valorReportado,
  ) async {
    final service = ReporteService();
    return await service.crearReporte(
      productoId: productoId,
      mercadoId: mercadoId,
      valorReportado: valorReportado,
    );
  }

  static Future<List<Reporte>> getReportsForProduct(int productoId) async {
    final service = ReporteService();
    return await service.getReportesPorProducto(productoId);
  }

  static Future<List<Reporte>> getAllReports() async {
    final service = ReporteService();
    return await service
        .getMisReportes(); // Ahora muestra solo los del usuario actual
  }

  static Future<void> removeReport(int id) async {
    final service = ReporteService();
    await service.eliminarReporte(id);
  }
}
