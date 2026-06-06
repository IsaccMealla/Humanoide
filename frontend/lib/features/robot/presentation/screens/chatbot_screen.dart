import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/agent_service.dart';
import '../../../../core/theme/app_colors.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final AgentService _agentService = AgentService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isListening = false;
  bool _wantsContinuousListening = false;
  String _text = "Pulsa el microfono o escribe un mensaje...";
  bool _isProcessing = false;
  String _sessionId = '';
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _bootstrapChat();
  }

  @override
  void dispose() {
    _speech.stop();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapChat() async {
    await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening' && _wantsContinuousListening) {
          _startListening();
        }
      },
    );

    final welcome = await _agentService.welcome();
    if (!mounted) return;

    setState(() {
      _sessionId = welcome.sessionId;
      _messages.add({'role': 'bot', 'text': welcome.respuesta});
    });
    _scrollToBottom();
    await _agentService.speakText(welcome.respuesta);
  }

  Future<void> _startListening() async {
    if (_isListening || _isProcessing) return;

    final available = await _speech.initialize();
    if (!available || !mounted) return;

    setState(() => _isListening = true);
    await _speech.listen(
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      pauseFor: const Duration(seconds: 3),
      onResult: (val) {
        if (!mounted) return;
        final transcript = val.recognizedWords.trim();
        if (transcript.isNotEmpty) {
          setState(() {
            _text = transcript;
            _inputController.text = transcript;
            _inputController.selection = TextSelection.fromPosition(
              TextPosition(offset: _inputController.text.length),
            );
          });
        }

        if (val.finalResult && transcript.isNotEmpty) {
          _sendMessage(transcript, fromVoice: true);
        }
      },
    );
  }

  Future<void> _toggleListening() async {
    if (_wantsContinuousListening) {
      _wantsContinuousListening = false;
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    _wantsContinuousListening = true;
    await _startListening();
  }

  Future<void> _sendMessage(String text, {bool fromVoice = false}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _isProcessing) return;

    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
    }

    _inputController.clear();

    setState(() {
      _messages.add({'role': 'user', 'text': cleanText});
      _isProcessing = true;
    });
    _scrollToBottom();

    final reply = await _agentService.sendMessage(
      cleanText,
      sessionId: _sessionId,
    );

    setState(() {
      if (reply.sessionId.isNotEmpty) {
        _sessionId = reply.sessionId;
      }
      _messages.add({'role': 'bot', 'text': reply.respuesta});
      _isProcessing = false;
      _text = fromVoice ? 'Comando enviado por voz.' : 'Mensaje enviado.';
    });
    _scrollToBottom();

    await _agentService.speakText(reply.respuesta);

    if (_wantsContinuousListening) {
      await _startListening();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendFromInput() {
    _sendMessage(_inputController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.espresso,
      appBar: AppBar(
        title: Text('Barista AI', style: GoogleFonts.philosopher()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m["role"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.caramel : AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      m["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : AppColors.cream,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppColors.caramel),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              _isListening
                  ? 'Escuchando en modo interactivo...'
                  : 'Puedes escribir o hablar al mismo tiempo.',
              style: GoogleFonts.inter(
                color: AppColors.bone.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        onSubmitted: (_) => _sendFromInput(),
                        textInputAction: TextInputAction.send,
                        style: GoogleFonts.inter(color: AppColors.cream),
                        decoration: InputDecoration(
                          hintText: 'Escribe tu pedido o duda...',
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.bone.withValues(alpha: 0.65),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isProcessing ? null : _sendFromInput,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.caramel,
                      ),
                      icon: const Icon(Icons.send),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleListening,
                      child:
                          Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _isListening
                                      ? Colors.red
                                      : AppColors.caramel,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (_isListening
                                                  ? Colors.red
                                                  : AppColors.caramel)
                                              .withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              )
                              .animate(target: _isListening ? 1 : 0)
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.1, 1.1),
                                duration: 450.ms,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _text,
                  style: GoogleFonts.inter(color: AppColors.bone, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
