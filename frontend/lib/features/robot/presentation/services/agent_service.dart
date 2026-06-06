import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AgentReply {
  final String respuesta;
  final String rol;
  final String sessionId;
  final String action;

  const AgentReply({
    required this.respuesta,
    required this.rol,
    required this.sessionId,
    required this.action,
  });

  factory AgentReply.fromJson(Map<String, dynamic> json) {
    return AgentReply(
      respuesta: (json['respuesta'] ?? '').toString(),
      rol: (json['rol'] ?? 'cliente').toString(),
      sessionId: (json['session_id'] ?? '').toString(),
      action: (json['action'] ?? 'none').toString(),
    );
  }
}

class AgentService {
  static String _resolveBaseUrl() {
    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  final String _baseUrl = _resolveBaseUrl();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _resolveBaseUrl(),
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<AgentReply> welcome() async {
    try {
      final response = await _dio.get('/agent/welcome');
      return AgentReply.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error en bienvenida: $e');
      return const AgentReply(
        respuesta: 'Hola, soy tu asistente barista. ¿Que quieres hacer hoy?',
        rol: 'cliente',
        sessionId: '',
        action: 'welcome',
      );
    }
  }

  Future<AgentReply> sendMessage(String message, {String? sessionId}) async {
    try {
      final payload = <String, dynamic>{'mensaje': message, 'rol': 'cliente'};
      if (sessionId != null && sessionId.isNotEmpty) {
        payload['session_id'] = sessionId;
      }

      final response = await _dio.post('/agent/chat', data: payload);
      return AgentReply.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error en chat: $e');
      return const AgentReply(
        respuesta:
            'Lo siento, tuve un problema al conectarme con el backend del chatbot.',
        rol: 'cliente',
        sessionId: '',
        action: 'error',
      );
    }
  }

  Future<void> speakText(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final encodedText = Uri.encodeQueryComponent(text);
      await _audioPlayer.stop();
      await _audioPlayer.play(
        UrlSource('$_baseUrl/agent/tts?text=$encodedText'),
      );
    } catch (e) {
      debugPrint('Error en TTS: $e');
    }
  }
}
