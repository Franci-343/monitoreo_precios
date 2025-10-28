class Favorito {
  final int id;
  final int usuarioId;
  final int productoId;

  Favorito({required this.id, required this.usuarioId, required this.productoId});

  factory Favorito.fromMap(Map<String, dynamic> m) => Favorito(
        id: m['id'] as int,
        usuarioId: m['usuarioId'] as int,
        productoId: m['productoId'] as int,
      );

  Map<String, dynamic> toMap() => {'id': id, 'usuarioId': usuarioId, 'productoId': productoId};
}
