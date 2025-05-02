import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get openAiApiKeyMain => dotenv.env['OPENAI_API_KEY_MAIN'] ?? '';
  
  static String get openAiApiKeySummarizer => dotenv.env['OPENAI_API_KEY_SUMMARIZER'] ?? '';
} 