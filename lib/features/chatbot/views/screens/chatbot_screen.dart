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
      'options': [
        'Drop Dates',
        'Course Requirements',
        'E-Library Website',
      ],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ChatBot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                    if (message['options'] != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (message['options'] as List<String>)
                              .map((option) => InkWell(
                                    onTap: () {
                                      setState(() {
                                        _messages.add({
                                          'isBot': false,
                                          'message': option,
                                        });
                                        if (option == 'E-Library Website') {
                                          _messages.add({
                                            'isBot': true,
                                            'message': 'E-Library',
                                          });
                                          _messages.add({
                                            'isBot': true,
                                            'message': 'Can I help you with something else?',
                                          });
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFBBDE4E),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(option),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Start typing',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {},
                ),
              ],
            ),
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
