import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddFlashcardSetScreen extends StatefulWidget {
  const AddFlashcardSetScreen({super.key});

  @override
  State<AddFlashcardSetScreen> createState() => _AddFlashcardSetScreenState();
}

class _AddFlashcardSetScreenState extends State<AddFlashcardSetScreen> {
  final TextEditingController _setTitleController = TextEditingController();
  final List<FlashcardInput> _flashcards = [];

  void _addFlashcard() {
    print('Adding new flashcard');
    setState(() {
      final newCard = FlashcardInput(
        key: UniqueKey(),
        onDelete: _removeFlashcard,
      );
      _flashcards.add(newCard);
      print('Current flashcards count: ${_flashcards.length}');
    });
  }

  void _removeFlashcard(FlashcardInput flashcard) {
    print('Removing flashcard');
    setState(() {
      _flashcards.remove(flashcard);
      print('Current flashcards count: ${_flashcards.length}');
    });
  }

  void _saveSet() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final title = _setTitleController.text.trim();
      final flashcardsData = _flashcards.map((fc) => {
        'question': fc.questionController.text.trim(),
        'answer': fc.answerController.text.trim(),
      }).toList();

      print('Saving flashcard set:');
      print('Title: $title');
      print('Flashcards data: $flashcardsData');

      if (title.isEmpty || flashcardsData.any((fc) => fc['question']!.isEmpty || fc['answer']!.isEmpty)) {
        Get.snackbar('Missing Info', 'Please fill out all fields');
        return;
      }

      Navigator.of(context).pop({
        'title': title,
        'flashcards': flashcardsData,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Create Flashcard Set',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1a457b),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSet,
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
                controller: _setTitleController,
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
                      'No flashcards added yet.',
                      style: TextStyle(color: Colors.grey),
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
    print('Initializing FlashcardInput controllers');
    questionController = TextEditingController(text: widget.initialQuestion);
    answerController = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    print('Disposing FlashcardInput controllers');
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              onChanged: (value) {
                print('Question updated: $value');
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                print('Answer updated: $value');
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => widget.onDelete(widget),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 