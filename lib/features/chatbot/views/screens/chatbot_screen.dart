import 'package:coded_gp/core/common/widgets/custom_back_button.dart';
import 'package:coded_gp/core/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'isBot': true,
      'message': 'Welcome to CodEd. How can I help you?',
    });
  }

  Future<void> _handleUserMessage(String message) async {
    setState(() {
      _messages.add({
        'isBot': false,
        'message': message,
      });
    });

    try {
      final botReply = await ChatService.sendMessage(message);
      setState(() {
        _messages.add({
          'isBot': true,
          'message': botReply,
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'isBot': true,
          'message': 'Oops! Something went wrong. Please try again later.',
        });
      });
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/vibrantskybg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // White bottom overlay to block background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 100, // make sure this is enough to cover the home bar
            child: Container(color: Colors.white),
          ),

          // Main chat layout
          Column(
            children: [
              const SafeArea(child: SizedBox()), // just for top notch

              // Back button and logo container
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                child: Row(
                  children: [
                    CustomBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'ChatBot',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isBot = message['isBot'] as bool;

                    return Column(
                      crossAxisAlignment: isBot
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        if (isBot)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/Duck-01.png',
                                height: 40,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    message['message'] as String,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBBDE4E),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message['message'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              // Bottom chat bar
              SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Start typing',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(color: Colors.black),
                          onSubmitted: _handleUserMessage,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFFBBDE4E)),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          final text = _messageController.text.trim();
                          if (text.isNotEmpty) {
                            _handleUserMessage(text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
