import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:coded_gp/features/summariser/services/openai_service.dart';
import 'dart:convert';
import 'package:coded_gp/core/config/api_config.dart';

class PDFSummarizerService {
  final OpenAIService _openAIService = OpenAIService();
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const int _maxChunkSize = 4000;
  static const int _maxRetries = 3;
  static const int _initialRetryDelay = 5;
  static const int _maxDelay = 30;
  static const int _concurrentRequests = 3;
  static const int _chunkDelay = 5;

  Future<String> summarizePDFFromUrl(String pdfUrl, String title) async {
    try {
      // Download the PDF file
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }

      // Save the PDF to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(pdfUrl);
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      // Extract text from PDF
      final pdfText = await _extractTextFromPDF(file.path);

      // Summarize the text
      return await _openAIService.summarizeFile(pdfText, title);
    } catch (e) {
      throw Exception('Error summarizing PDF: $e');
    }
  }

  Future<String> summarizePDFFromFile(File pdfFile, String title) async {
    try {
      // Extract text from PDF
      final pdfText = await _extractTextFromPDF(pdfFile.path);

      // Summarize the text
      return await _openAIService.summarizeFile(pdfText, title);
    } catch (e) {
      throw Exception('Error summarizing PDF: $e');
    }
  }

  Future<String> _extractTextFromPDF(String pdfPath) async {
    try {
      final bytes = await File(pdfPath).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final text = StringBuffer();

      for (var i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        final pageText = PdfTextExtractor(document)
            .extractText(startPageIndex: i, endPageIndex: i);
        text.writeln(pageText);
      }

      document.dispose();
      return text.toString();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  Future<String> extractTextFromPDF(List<int> pdfBytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      String text = '';
      for (int i = 0; i < document.pages.count; i++) {
        text += PdfTextExtractor(document).extractText(startPageIndex: i);
      }
      document.dispose();
      return text;
    } catch (e) {
      throw Exception('Error extracting text from PDF: $e');
    }
  }

  List<String> _splitIntoChunks(String text) {
    List<String> chunks = [];
    int start = 0;

    while (start < text.length) {
      int end = start + _maxChunkSize;
      if (end > text.length) {
        end = text.length;
      } else {
        int lastNewline = text.lastIndexOf('\n', end);
        int lastPeriod = text.lastIndexOf('. ', end);
        int lastSpace = text.lastIndexOf(' ', end);

        if (lastNewline > start + _maxChunkSize * 0.8) {
          end = lastNewline + 1;
        } else if (lastPeriod > start + _maxChunkSize * 0.8) {
          end = lastPeriod + 2;
        } else if (lastSpace > start + _maxChunkSize * 0.8) {
          end = lastSpace + 1;
        }
      }

      chunks.add(text.substring(start, end));
      start = end;
    }

    return chunks;
  }

  Future<String> _summarizeChunk(
      String chunk, String title, int chunkNumber, int totalChunks) async {
    int retryCount = 0;
    String lastError = '';
    int currentDelay = _initialRetryDelay;

    while (retryCount < _maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
          },
          body: jsonEncode({
            'model': 'gpt-4-turbo-preview',
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are a helpful assistant that summarizes documents. Provide a clear and concise summary of this part of the content. This is part $chunkNumber of $totalChunks of the document.'
              },
              {
                'role': 'user',
                'content':
                    'Please summarize this part of the document titled "$title":\n\n$chunk'
              }
            ],
            'temperature': 0.7,
            'max_tokens': 200,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'];
        } else {
          final errorData = jsonDecode(response.body);
          lastError =
              'API Error: ${errorData['error']['message'] ?? response.body}';

          if (response.statusCode == 429) {
            currentDelay = (currentDelay * 1.5).ceil();
            if (currentDelay > _maxDelay) currentDelay = _maxDelay;
            await Future.delayed(Duration(seconds: currentDelay));
          } else {
            await Future.delayed(Duration(seconds: currentDelay));
          }

          retryCount++;
          continue;
        }
      } catch (e) {
        lastError = 'Network Error: $e';
        if (retryCount < _maxRetries - 1) {
          retryCount++;
          await Future.delayed(Duration(seconds: currentDelay));
          continue;
        }
        throw Exception('Failed to summarize chunk: $lastError');
      }
    }
    throw Exception(
        'Failed to summarize chunk after $_maxRetries attempts. Last error: $lastError');
  }

  Future<String> summarizePDF(List<int> pdfBytes, String title) async {
    try {
      final text = await extractTextFromPDF(pdfBytes);
      if (text.isEmpty) {
        throw Exception('PDF content is empty');
      }

      final chunks = _splitIntoChunks(text);
      final totalChunks = chunks.length;
      List<String> summaries = [];

      for (int i = 0; i < chunks.length; i += _concurrentRequests) {
        final currentBatch = chunks.sublist(
          i,
          i + _concurrentRequests > chunks.length
              ? chunks.length
              : i + _concurrentRequests,
        );

        final batchFutures = currentBatch.asMap().entries.map((entry) {
          final chunkIndex = i + entry.key;
          return _summarizeChunk(
            entry.value,
            title,
            chunkIndex + 1,
            totalChunks,
          );
        }).toList();

        final batchResults = await Future.wait(batchFutures);
        summaries.addAll(batchResults);

        if (i + _concurrentRequests < chunks.length) {
          await Future.delayed(Duration(seconds: _chunkDelay));
        }
      }

      final combinedSummaries = summaries.join('\n\n');
      int retryCount = 0;
      String lastError = '';
      int currentDelay = _initialRetryDelay;

      while (retryCount < _maxRetries) {
        try {
          final finalResponse = await http.post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
            },
            body: jsonEncode({
              'model': 'gpt-4-turbo-preview',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a helpful assistant that creates a final, coherent summary from multiple partial summaries. Combine these summaries into one clear, concise summary.'
                },
                {
                  'role': 'user',
                  'content':
                      'Please combine these partial summaries of the document titled "$title" into one final summary:\n\n$combinedSummaries'
                }
              ],
              'temperature': 0.7,
              'max_tokens': 500,
            }),
          );

          if (finalResponse.statusCode == 200) {
            final data = jsonDecode(finalResponse.body);
            return data['choices'][0]['message']['content'];
          }

          final errorData = jsonDecode(finalResponse.body);
          lastError =
              'API Error: ${errorData['error']['message'] ?? finalResponse.body}';

          if (finalResponse.statusCode == 429) {
            currentDelay = (currentDelay * 1.5).ceil();
            if (currentDelay > _maxDelay) currentDelay = _maxDelay;
            await Future.delayed(Duration(seconds: currentDelay));
          } else {
            await Future.delayed(Duration(seconds: currentDelay));
          }

          retryCount++;
          continue;
        } catch (e) {
          lastError = 'Network Error: $e';
          if (retryCount < _maxRetries - 1) {
            retryCount++;
            await Future.delayed(Duration(seconds: currentDelay));
            continue;
          }
          throw Exception('Failed to create final summary: $lastError');
        }
      }
      throw Exception(
          'Failed to create final summary after $_maxRetries attempts. Last error: $lastError');
    } catch (e) {
      throw Exception('Error summarizing PDF: $e');
    }
  }
}
