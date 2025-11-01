class Favorito {
  final int id;
  final String usuarioId; // UUID en Supabase
  final int productoId;
  final DateTime? createdAt;

  Favorito({
    required this.id,
    required this.usuarioId,
    required this.productoId,
    this.createdAt,
  });

  factory Favorito.fromMap(Map<String, dynamic> m) => Favorito(
    id: m['id'] as int,
    usuarioId: m['usuario_id'] as String, // Corregido: snake_case
    productoId: m['producto_id'] as int, // Corregido: snake_case
    createdAt: m['created_at'] != null
        ? DateTime.parse(m['created_at'] as String)
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'usuario_id': usuarioId, // Corregido: snake_case
    'producto_id': productoId, // Corregido: snake_case
    'created_at': createdAt?.toIso8601String(),
  };
}
