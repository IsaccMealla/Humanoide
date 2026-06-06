import 'dart:convert';
import 'package:flutter/material.dart';

class RobotScreen extends StatefulWidget {
  const RobotScreen({super.key});

  @override
  State<RobotScreen> createState() => _RobotScreenState();
}

class _RobotScreenState extends State<RobotScreen> {
  // Ángulos actuales de los servos
  double _baseAngle = 90;
  double _shoulderAngle = 90;
  double _elbowAngle = 90;
  double _gripperAngle = 90;

  // Consola simulada
  final List<String> _consoleLogs = [];

  void _logCommand(String command, String target, double angle) {
    final payload = {
      "cmd": command,
      "servo": target,
      "angle": angle.toInt(),
      "timestamp": DateTime.now().toIso8601String().split('T').last.substring(0, 8),
    };
    setState(() {
      _consoleLogs.insert(0, jsonEncode(payload));
      if (_consoleLogs.length > 20) _consoleLogs.removeLast();
    });
  }

  void _sendEmergencyStop() {
    final payload = {
      "cmd": "stop",
      "timestamp": DateTime.now().toIso8601String().split('T').last.substring(0, 8),
    };
    setState(() {
      _consoleLogs.insert(0, jsonEncode(payload));
      // Reset angles as visual feedback
      _baseAngle = 90;
      _shoulderAngle = 90;
      _elbowAngle = 90;
      _gripperAngle = 90;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Panel de Control Manual', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Sección de Sliders
          Expanded(
            flex: 6,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildServoSlider("Base", _baseAngle, (v) {
                  setState(() => _baseAngle = v);
                  _logCommand("move", "base", v);
                }),
                _buildServoSlider("Hombro", _shoulderAngle, (v) {
                  setState(() => _shoulderAngle = v);
                  _logCommand("move", "shoulder", v);
                }),
                _buildServoSlider("Codo", _elbowAngle, (v) {
                  setState(() => _elbowAngle = v);
                  _logCommand("move", "elbow", v);
                }),
                _buildServoSlider("Pinza", _gripperAngle, (v) {
                  setState(() => _gripperAngle = v);
                  _logCommand("move", "gripper", v);
                }),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _sendEmergencyStop,
                  icon: const Icon(Icons.warning, color: Colors.white),
                  label: const Text("PARO DE EMERGENCIA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          
          // Consola Simulada ESP32
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.terminal, color: Colors.greenAccent, size: 20),
                      SizedBox(width: 8),
                      Text("Consola Serial ESP32 Simulada", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.greenAccent),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _consoleLogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            "> ${_consoleLogs[index]}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServoSlider(String name, double value, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text("${value.toInt()}°", style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 180,
            divisions: 180,
            activeColor: Colors.amber,
            inactiveColor: Colors.white24,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
