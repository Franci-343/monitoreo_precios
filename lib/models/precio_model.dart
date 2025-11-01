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
    productoId: m['producto_id'] as int, // snake_case de la BD
    mercadoId: m['mercado_id'] as int, // snake_case de la BD
    valor: (m['precio'] as num).toDouble(), // la columna se llama "precio"
    fechaActualizacion: DateTime.parse(
      m['fecha_actualizacion'] as String,
    ), // snake_case de la BD
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'producto_id': productoId, // snake_case para la BD
    'mercado_id': mercadoId, // snake_case para la BD
    'precio': valor, // la columna se llama "precio"
    'fecha_actualizacion': fechaActualizacion
        .toIso8601String(), // snake_case para la BD
  };
}
