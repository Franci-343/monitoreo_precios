class Reporte {
  final int id;
  final int usuarioId;
  final int productoId;
  final int mercadoId;
  final double valorReportado;
  final DateTime fechaReporte;

  Reporte(
      {required this.id,
      required this.usuarioId,
      required this.productoId,
      required this.mercadoId,
      required this.valorReportado,
      required this.fechaReporte});

  factory Reporte.fromMap(Map<String, dynamic> m) => Reporte(
        id: m['id'] as int,
        usuarioId: m['usuarioId'] as int,
        productoId: m['productoId'] as int,
        mercadoId: m['mercadoId'] as int,
        valorReportado: (m['valorReportado'] as num).toDouble(),
        fechaReporte: DateTime.parse(m['fechaReporte'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'usuarioId': usuarioId,
        'productoId': productoId,
        'mercadoId': mercadoId,
        'valorReportado': valorReportado,
        'fechaReporte': fechaReporte.toIso8601String(),
      };
}
