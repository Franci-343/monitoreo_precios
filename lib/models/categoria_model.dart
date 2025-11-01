class Categoria {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final String? color;
  final int orden;
  final bool activo;

  Categoria({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.icono,
    this.color,
    this.orden = 0,
    this.activo = true,
  });

  factory Categoria.fromMap(Map<String, dynamic> m) => Categoria(
    id: m['id'] as int,
    nombre: m['nombre'] as String,
    descripcion: m['descripcion'] as String?,
    icono: m['icono'] as String?,
    color: m['color'] as String?,
    orden: m['orden'] as int? ?? 0,
    activo: m['activo'] as bool? ?? true,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'icono': icono,
    'color': color,
    'orden': orden,
    'activo': activo,
  };
}
