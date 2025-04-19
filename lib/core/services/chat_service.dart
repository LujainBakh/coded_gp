import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class ChatService {
  // Base URL for your Python FastAPI server
  static const String _baseUrl = 'http://192.168.3.234:8000';

  /// Sends a message to the chatbot backend and returns its response.
  ///
  /// [userInput] is the message from the user.
  /// Returns the chatbot's reply as a [String].
  /// Throws an [Exception] if the request fails.
  static Future<String> sendMessage(String userInput) async {
    final url = Uri.parse('$_baseUrl/chat');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'user_input': userInput}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please check your connection.');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] as String;
      } else {
        print('❌ Server responded with status: ${response.statusCode}');
        print('🔍 Response body: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('🚨 Network error: $e');
      throw Exception(
        'Unable to connect to the server. Please check:\n'
        '1. The server is running\n'
        '2. Your device is connected to the network\n'
        '3. The server address is correct'
      );
    } catch (e) {
      print('🚨 Error sending message: $e');
      throw Exception('Failed to communicate with chatbot server: $e');
    }
  }
}
