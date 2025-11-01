/// Modelo para alertas de precio
/// Representa una alerta configurada por el usuario
class Alerta {
  final int id;
  final String usuarioId;
  final int productoId;
  final int? mercadoId;
  final double precioObjetivo;
  final String tipoAlerta; // 'menor_o_igual' o 'mayor_o_igual'
  final bool activo;
  final bool notificado;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Información adicional (no en DB)
  final String? productoNombre;
  final String? mercadoNombre;

  Alerta({
    required this.id,
    required this.usuarioId,
    required this.productoId,
    this.mercadoId,
    required this.precioObjetivo,
    required this.tipoAlerta,
    this.activo = true,
    this.notificado = false,
    required this.createdAt,
    required this.updatedAt,
    this.productoNombre,
    this.mercadoNombre,
  });

  factory Alerta.fromMap(Map<String, dynamic> map) {
    return Alerta(
      id: map['id'] as int,
      usuarioId: map['usuario_id'] as String,
      productoId: map['producto_id'] as int,
      mercadoId: map['mercado_id'] as int?,
      precioObjetivo: (map['precio_objetivo'] as num).toDouble(),
      tipoAlerta: map['tipo_alerta'] as String? ?? 'menor_o_igual',
      activo: map['activo'] as bool? ?? true,
      notificado: map['notificado'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      productoNombre: map['producto_nombre'] as String?,
      mercadoNombre: map['mercado_nombre'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'producto_id': productoId,
      if (mercadoId != null) 'mercado_id': mercadoId,
      'precio_objetivo': precioObjetivo,
      'tipo_alerta': tipoAlerta,
      'activo': activo,
      'notificado': notificado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Método auxiliar para saber si es alerta de precio bajo
  bool get esAlertaPrecioBajo => tipoAlerta == 'menor_o_igual';

  // Método auxiliar para saber si es alerta de precio alto
  bool get esAlertaPrecioAlto => tipoAlerta == 'mayor_o_igual';

  // Descripción legible de la alerta
  String get descripcion {
    final tipo = esAlertaPrecioBajo ? 'baje de' : 'suba de';
    final mercadoInfo = mercadoNombre != null ? ' en $mercadoNombre' : '';
    return 'Notificar cuando el precio $tipo ${precioObjetivo.toStringAsFixed(2)} Bs$mercadoInfo';
  }
}
