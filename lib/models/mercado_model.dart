class Mercado {
  final int id;
  final String nombre;
  final String zona;
  final String? tipo;
  final String? direccion;

  Mercado({
    required this.id,
    required this.nombre,
    required this.zona,
    this.tipo,
    this.direccion,
  });

  factory Mercado.fromMap(Map<String, dynamic> m) => Mercado(
    id: m['id'] as int,
    nombre: m['nombre'] as String,
    zona: m['zona'] as String,
    tipo: m['tipo'] as String?,
    direccion: m['direccion'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'zona': zona,
    if (tipo != null) 'tipo': tipo,
    if (direccion != null) 'direccion': direccion,
  };
}
