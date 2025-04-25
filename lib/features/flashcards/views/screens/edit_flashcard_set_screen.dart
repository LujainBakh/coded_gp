import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditFlashcardSetScreen extends StatefulWidget {
  final String initialTitle;
  final List<Map<String, String>> initialFlashcards;

  const EditFlashcardSetScreen({
    super.key,
    required this.initialTitle,
    required this.initialFlashcards,
  });

  @override
  State<EditFlashcardSetScreen> createState() => _EditFlashcardSetScreenState();
}

class _EditFlashcardSetScreenState extends State<EditFlashcardSetScreen> {
  late TextEditingController _titleController;
  List<FlashcardInput> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _flashcards = widget.initialFlashcards.map((card) {
      return FlashcardInput(
        initialQuestion: card['question'] ?? '',
        initialAnswer: card['answer'] ?? '',
        onDelete: _removeFlashcard,
      );
    }).toList();
  }

  void _addFlashcard() {
    setState(() {
      _flashcards.add(
        FlashcardInput(
          onDelete: _removeFlashcard,
        ),
      );
    });
  }

  void _removeFlashcard(FlashcardInput card) {
    setState(() {
      _flashcards.remove(card);
    });
  }

  void _saveChanges() {
    if (_titleController.text.trim().isEmpty || _flashcards.isEmpty) {
      Get.snackbar("Missing Info", "Please provide a title and at least one flashcard.");
      return;
    }

    final updatedSet = {
      'title': _titleController.text.trim(),
      'flashcards': _flashcards.map((fc) => {
        'question': fc.questionController.text,
        'answer': fc.answerController.text,
      }).toList()
    };

    Navigator.of(context).pop(updatedSet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Edit Flashcards',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1a457b).withOpacity(0.95),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/coded_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Set Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a457b),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Science, Mobile Programming...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Flashcards section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Flashcards',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a457b),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addFlashcard,
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1a457b)),
                    label: const Text(
                      'Add Card',
                      style: TextStyle(color: Color(0xFF1a457b)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_flashcards.isEmpty)
                Column(
                  children: [
                    Image.asset('assets/images/Duck-01.png', height: 80),
                    const SizedBox(height: 12),
                    const Text(
                      'No flashcards yet. Tap "Add Card" to begin!',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                )
              else
                Column(children: _flashcards),
            ],
          ),
        ),
      ),
    );
  }
}

class FlashcardInput extends StatefulWidget {
  final String initialQuestion;
  final String initialAnswer;
  final void Function(FlashcardInput) onDelete;

  FlashcardInput({
    super.key,
    this.initialQuestion = '',
    this.initialAnswer = '',
    required this.onDelete,
  });

  final _FlashcardInputState _state = _FlashcardInputState();

  TextEditingController get questionController => _state.questionController;
  TextEditingController get answerController => _state.answerController;

  @override
  State<FlashcardInput> createState() => _state;
}

class _FlashcardInputState extends State<FlashcardInput> {
  late TextEditingController questionController;
  late TextEditingController answerController;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(text: widget.initialQuestion);
    answerController = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => widget.onDelete(widget),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 