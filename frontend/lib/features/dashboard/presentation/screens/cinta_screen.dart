import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../services/cinta_service.dart';

class CintaScreen extends StatefulWidget {
  const CintaScreen({super.key});

  @override
  State<CintaScreen> createState() => _CintaScreenState();
}

class _CintaScreenState extends State<CintaScreen>
    with SingleTickerProviderStateMixin {
  final CintaService _service = CintaService();
  Map<String, dynamic>? status;
  Timer? _timer;
  late AnimationController _gearController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _gearController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Polling cada 2 segundos para no saturar
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) => _fetchStatus(),
    );
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final data = await _service.getStatus();
      if (mounted) {
        setState(() {
          status = data;
          _isLoading = false;
          _hasError = false;
          if (status!['is_running'] == true) {
            _gearController.repeat();
          } else {
            _gearController.stop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      debugPrint("Error fetching cinta status: $e");
    }
  }

  Future<void> _sendCommand(String action) async {
    HapticFeedback.lightImpact();
    try {
      await _service.sendCommand(action);
      _fetchStatus(); // Refrescar inmediatamente
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: No se pudo enviar el comando $action'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isRunning = status?['is_running'] ?? false;
    bool isManual = status?['manual_override'] ?? false;
    String lastEvent = status?['last_event'] ?? 'Estado desconocido';
    bool sensorIR = status?['sensor_ir_triggered'] ?? false;
    bool sensorUltra = status?['sensor_ultra_triggered'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: CustomScrollView(
        slivers: [
          // Header Elegante
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.espresso,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'SISTEMA DE CINTA',
                style: GoogleFonts.oswald(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.cream,
                ),
              ),
              centerTitle: true,
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.caramel),
              ),
            )
          else if (_hasError)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: AppColors.clayRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error de Conexión',
                      style: GoogleFonts.poppins(
                        color: AppColors.cream,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verifica que el servidor FastAPI esté corriendo en\nhttp://192.168.1.224:8000',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _isLoading = true);
                        _fetchStatus();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caramel,
                      ),
                      child: const Text('REINTENTAR'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // --- VISUALIZADOR DE ESTADO ---
                  _buildStatusCard(isRunning, lastEvent),
                  const SizedBox(height: 24),

                  // --- SENSORES ---
                  Text(
                    'TELEMETRÍA DE SENSORES',
                    style: GoogleFonts.poppins(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSensorChip(
                          'SENSOR IR',
                          sensorIR,
                          Icons.sensors,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSensorChip(
                          'ULTRASÓNICO',
                          sensorUltra,
                          Icons.settings_input_antenna,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- CONTROLES MANUALES ---
                  Text(
                    'CONTROLES DEL SISTEMA',
                    style: GoogleFonts.poppins(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildControlPanel(isRunning, isManual),

                  const SizedBox(height: 40),
                  // Footer informativo
                  Center(
                    child: Text(
                      'Modo: ${isManual ? "MANUAL" : "AUTOMÁTICO"}',
                      style: GoogleFonts.poppins(
                        color: isManual ? AppColors.warmAmber : AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isRunning, String lastEvent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRunning
              ? AppColors.warmGreen.withOpacity(0.3)
              : AppColors.surfaceLight,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRunning ? 'EN FUNCIONAMIENTO' : 'SISTEMA DETENIDO',
                    style: GoogleFonts.poppins(
                      color: isRunning ? AppColors.warmGreen : AppColors.muted,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Estado actual del motor',
                    style: GoogleFonts.poppins(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              RotationTransition(
                turns: _gearController,
                child: Icon(
                  Icons.settings,
                  size: 40,
                  color: isRunning ? AppColors.caramel : AppColors.surfaceLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.espresso.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.caramel,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lastEvent,
                    style: GoogleFonts.poppins(
                      color: AppColors.bone,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildSensorChip(String label, bool active, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? AppColors.caramel.withOpacity(0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: active ? AppColors.caramel : AppColors.surfaceLight,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            active ? 'DETECTADO' : 'LIBRE',
            style: GoogleFonts.poppins(
              color: active ? AppColors.caramel : AppColors.bone,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(bool isRunning, bool isManual) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildControlButton(
                'INICIAR',
                isRunning ? null : () => _sendCommand('start'),
                AppColors.warmGreen,
                Icons.play_arrow_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildControlButton(
                'DETENER',
                !isRunning ? null : () => _sendCommand('stop'),
                AppColors.clayRed,
                Icons.stop_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildControlButton(
          'MODO AUTOMÁTICO',
          !isManual ? null : () => _sendCommand('auto'),
          AppColors.caramel,
          Icons.auto_mode_rounded,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildControlButton(
    String label,
    VoidCallback? onPressed,
    Color color,
    IconData icon, {
    bool isFullWidth = false,
  }) {
    bool isDisabled = onPressed == null;
    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: isFullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
              color: color.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
