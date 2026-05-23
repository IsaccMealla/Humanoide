import 'package:flutter/material.dart';

class RobotScreen extends StatelessWidget {
  const RobotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Robot")),
      body: const Center(child: Text("Estado del robot")),
    );
  }
}
