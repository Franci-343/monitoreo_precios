class Usuario {
  final String id; // UUID de Supabase Auth
  final String nombre;
  final String email;
  final String? telefono;
  final String? zonaPreferida;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.zonaPreferida,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
    id: m['id'] as String,
    nombre: m['nombre'] as String,
    email: m['email'] as String,
    telefono: m['telefono'] as String?,
    zonaPreferida: m['zona_preferida'] as String?,
    avatarUrl: m['avatar_url'] as String?,
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'telefono': telefono,
    'zona_preferida': zonaPreferida,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // Para actualizar perfil (sin ID, created_at)
  Map<String, dynamic> toUpdateMap() => {
    'nombre': nombre,
    'telefono': telefono,
    'zona_preferida': zonaPreferida,
    'avatar_url': avatarUrl,
  };

  // Copiar con cambios
  Usuario copyWith({
    String? nombre,
    String? email,
    String? telefono,
    String? zonaPreferida,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return Usuario(
      id: id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      zonaPreferida: zonaPreferida ?? this.zonaPreferida,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
