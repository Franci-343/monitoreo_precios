class Mercado {
  final int id;
  final String nombre;
  final String zona;

  Mercado({required this.id, required this.nombre, required this.zona});

  factory Mercado.fromMap(Map<String, dynamic> m) => Mercado(
        id: m['id'] as int,
        nombre: m['nombre'] as String,
        zona: m['zona'] as String,
      );

  Map<String, dynamic> toMap() => {'id': id, 'nombre': nombre, 'zona': zona};
}
