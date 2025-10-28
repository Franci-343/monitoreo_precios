class Producto {
  final int id;
  final String nombre;
  final String categoria;

  Producto({required this.id, required this.nombre, required this.categoria});

  factory Producto.fromMap(Map<String, dynamic> m) => Producto(
        id: m['id'] as int,
        nombre: m['nombre'] as String,
        categoria: m['categoria'] as String,
      );

  Map<String, dynamic> toMap() => {'id': id, 'nombre': nombre, 'categoria': categoria};
}
