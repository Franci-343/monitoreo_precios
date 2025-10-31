class Producto {
  final int id;
  final String nombre;
  final String categoria; // Nombre de la categoría para compatibilidad
  final int? categoriaId; // ID de la categoría en BD
  final String? unidadMedida;

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    this.categoriaId,
    this.unidadMedida,
  });

  factory Producto.fromMap(Map<String, dynamic> m) {
    // Si viene de Supabase con categoria_id, lo manejamos
    if (m.containsKey('categoria_id')) {
      return Producto(
        id: m['id'] as int,
        nombre: m['nombre'] as String,
        categoria: m['categoria'] as String? ?? 'Sin categoría',
        categoriaId: m['categoria_id'] as int?,
        unidadMedida: m['unidad_medida'] as String?,
      );
    }

    // Compatibilidad con datos anteriores
    return Producto(
      id: m['id'] as int,
      nombre: m['nombre'] as String,
      categoria: m['categoria'] as String,
      categoriaId: m['categoria_id'] as int?,
      unidadMedida: m['unidad_medida'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'categoria': categoria,
    if (categoriaId != null) 'categoria_id': categoriaId,
    if (unidadMedida != null) 'unidad_medida': unidadMedida,
  };
}
