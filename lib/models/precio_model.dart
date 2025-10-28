class Precio {
  final int id;
  final int productoId;
  final int mercadoId;
  final double valor;
  final DateTime fechaActualizacion;

  Precio({
    required this.id,
    required this.productoId,
    required this.mercadoId,
    required this.valor,
    required this.fechaActualizacion,
  });

  factory Precio.fromMap(Map<String, dynamic> m) => Precio(
        id: m['id'] as int,
        productoId: m['productoId'] as int,
        mercadoId: m['mercadoId'] as int,
        valor: (m['valor'] as num).toDouble(),
        fechaActualizacion: DateTime.parse(m['fechaActualizacion'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'productoId': productoId,
        'mercadoId': mercadoId,
        'valor': valor,
        'fechaActualizacion': fechaActualizacion.toIso8601String(),
      };
}
