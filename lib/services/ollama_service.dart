import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  // Active ngrok tunnel for judges to access Gemma 4
  static const String _baseUrl = 'https://coping-gainfully-grievous.ngrok-free.dev';
  static const String _model = 'gemma4:latest';
  static const String _systemPrompt = '''
You are a highly concise AI CPR coach.
Your task is to provide EXACTLY ONE short, highly practical tip (max 15 words) on how to perform the requested step safely and effectively.
Rule 1: Focus purely on practical advice for the specific step requested.
Rule 2: Never mention chest compressions or rescue breaths UNLESS the step explicitly mentions them.
Rule 3: Keep it strictly under 15 words.
Rule 4: Start directly with a strong action verb. NEVER start with "Your", "The", or "This".
Rule 5: Use simple language. Avoid medical jargon like "supine" (use "on their back") or "sternum" (use "center of chest").
''';

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  /// Check if Ollama is running and reachable
  Future<bool> checkAvailability() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/tags'),
            headers: {
              'ngrok-skip-browser-warning': '69420',
              'User-Agent': 'FlutterApp',
            },
          )
          .timeout(const Duration(seconds: 5));
      _isAvailable = response.statusCode == 200;
      return _isAvailable;
    } catch (e) {
      _isAvailable = false;
      return false;
    }
  }

  /// Helper to call Ollama chat API with proper message format
  Future<String?> _chatRequest({
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.4,
    int numPredict = 500,
    int timeoutSeconds = 90,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/chat'),
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': '69420',
              'User-Agent': 'FlutterApp',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userMessage},
              ],
              'stream': false,
              'options': {
                'temperature': temperature,
                'num_predict': numPredict,
              },
            }),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['message']?['content']?.toString().trim();
        if (content != null && content.isNotEmpty) {
          return content;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Generate a calming AI tip for a given CPR step
  Future<String?> generateTip(String stepTitle, String stepDescription) async {
    if (!_isAvailable) return null;

    return _chatRequest(
      systemPrompt: _systemPrompt,
      userMessage: 'Step: "$stepTitle"\nInstruction: "$stepDescription"\n\nProvide one actionable tip.',
      temperature: 0.4,
      numPredict: 60,
      timeoutSeconds: 15,
    );
  }

  /// Get encouragement during active CPR
  Future<String?> getEncouragement() async {
    if (!_isAvailable) return null;

    return _chatRequest(
      systemPrompt: _systemPrompt,
      userMessage: 'The user is doing CPR compressions right now. Give ONE short sentence of encouragement. Be calm and supportive.',
      temperature: 0.5,
      numPredict: 40,
      timeoutSeconds: 10,
    );
  }

  /// Conversational chat for the Voice Assistant / Ask Gemma feature
  static const String _chatSystemPrompt = '''
You are Revive AI, a knowledgeable first-aid and CPR assistant.
Answer the user's medical/first-aid question clearly and concisely in 2-3 sentences max.
Rule 1: Only answer questions related to first-aid, CPR, AED, choking, or medical emergencies.
Rule 2: If the question is unrelated to medical emergencies, politely decline and redirect.
Rule 3: Always remind the user to call emergency services (911) for real emergencies.
Rule 4: Use simple, easy-to-understand language. Avoid medical terms like "supine" or "occlusion".
''';

  Future<String?> chatAnswer(String userQuestion) async {
    if (!_isAvailable) return null;

    return _chatRequest(
      systemPrompt: _chatSystemPrompt,
      userMessage: userQuestion,
      temperature: 0.5,
      numPredict: 100,
      timeoutSeconds: 20,
    );
  }

  /// High-speed conversational response for emergency mode
  Future<String?> emergencyChatAnswer(String userQuestion) async {
    if (!_isAvailable) return null;

    return _chatRequest(
      systemPrompt: "You are an emergency CPR coach. Answer in under 10 words. Be direct.",
      userMessage: userQuestion,
      temperature: 0.2, 
      numPredict: 25,  
      timeoutSeconds: 15,
    );
  }
}
