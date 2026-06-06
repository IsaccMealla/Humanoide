/// Modelo que mapea la tabla `tabla_estado_robot` de Supabase.
class RobotStatus {
  final int id;
  final double pesoActual;
  final bool paroEmergencia;
  final DateTime? updatedAt;

  const RobotStatus({
    required this.id,
    required this.pesoActual,
    required this.paroEmergencia,
    this.updatedAt,
  });

  factory RobotStatus.fromJson(Map<String, dynamic> json) {
    return RobotStatus(
      id: json['id'] as int,
      pesoActual: (json['peso_actual'] as num?)?.toDouble() ?? 0.0,
      paroEmergencia: json['paro_emergencia'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Estado por defecto cuando no hay conexión.
  factory RobotStatus.empty() {
    return const RobotStatus(
      id: 1,
      pesoActual: 0.0,
      paroEmergencia: false,
    );
  }
}
