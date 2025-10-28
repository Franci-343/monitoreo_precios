import 'dart:async';

import 'package:monitoreo_precios/models/reporte_model.dart';

class ReporteService {
  static final List<Reporte> _reports = [];
  static int _nextId = 1;

  static Future<Reporte> addReport(int usuarioId, int productoId, int mercadoId, double valorReportado) async {
    final r = Reporte(id: _nextId++, usuarioId: usuarioId, productoId: productoId, mercadoId: mercadoId, valorReportado: valorReportado, fechaReporte: DateTime.now());
    _reports.add(r);
    await Future.delayed(const Duration(milliseconds: 100));
    return r;
  }

  static Future<List<Reporte>> getReportsForProduct(int productoId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _reports.where((r) => r.productoId == productoId).toList();
  }

  static Future<List<Reporte>> getAllReports() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List<Reporte>.from(_reports);
  }

  static Future<void> removeReport(int id) async {
    _reports.removeWhere((r) => r.id == id);
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
