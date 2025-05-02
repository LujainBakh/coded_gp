import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:coded_gp/core/config/api_config.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const int _maxChunkSize = 4000;
  static const int _maxRetries = 3;
  static const int _initialRetryDelay = 5;
  static const int _maxDelay = 30;
  static const int _concurrentRequests = 3;
  static const int _chunkDelay = 5;

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
        print(
            'Attempting to summarize chunk $chunkNumber of $totalChunks (Attempt ${retryCount + 1})');

        final response = await http.post(
          Uri.parse('$_baseUrl/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiConfig.openAiApiKeySummarizer}',
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
            // Exponential backoff for rate limits
            currentDelay = (currentDelay * 1.5).ceil();
            if (currentDelay > _maxDelay) currentDelay = _maxDelay;

            print('Rate limit hit. Waiting ${currentDelay}s before retry...');
            await Future.delayed(Duration(seconds: currentDelay));
          } else {
            print(
                'Error status code: ${response.statusCode}. Waiting $currentDelay seconds before retry...');
            await Future.delayed(Duration(seconds: currentDelay));
          }

          retryCount++;
          continue;
        }
      } catch (e) {
        lastError = 'Network Error: $e';
        if (retryCount < _maxRetries - 1) {
          retryCount++;
          print('Error occurred: $e. Retrying in $currentDelay seconds...');
          await Future.delayed(Duration(seconds: currentDelay));
          continue;
        }
        throw Exception('Failed to summarize chunk: $lastError');
      }
    }
    throw Exception(
        'Failed to summarize chunk after $_maxRetries attempts. Last error: $lastError');
  }

  Future<String> summarizeFile(String fileContent, String title) async {
    try {
      if (fileContent.isEmpty) {
        throw Exception('File content is empty');
      }

      final chunks = _splitIntoChunks(fileContent);
      final totalChunks = chunks.length;
      print('Processing $totalChunks chunks...');
      List<String> summaries = [];

      // Process chunks in parallel with a limit on concurrent requests
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

        // Add a smaller delay between batches
        if (i + _concurrentRequests < chunks.length) {
          print('Waiting $_chunkDelay seconds before next batch...');
          await Future.delayed(Duration(seconds: _chunkDelay));
        }
      }

      print('All chunks processed. Creating final summary...');
      await Future.delayed(Duration(seconds: _chunkDelay));

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
              'Authorization': 'Bearer ${ApiConfig.openAiApiKeySummarizer}',
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

            print(
                'Rate limit hit. Waiting ${currentDelay}s before final summary...');
            await Future.delayed(Duration(seconds: currentDelay));
          } else {
            print(
                'Error status code: ${finalResponse.statusCode}. Waiting $currentDelay seconds before retry...');
            await Future.delayed(Duration(seconds: currentDelay));
          }

          retryCount++;
          continue;
        } catch (e) {
          lastError = 'Network Error: $e';
          if (retryCount < _maxRetries - 1) {
            retryCount++;
            print(
                'Error occurred: $e. Retrying final summary in $currentDelay seconds...');
            await Future.delayed(Duration(seconds: currentDelay));
            continue;
          }
          throw Exception('Failed to create final summary: $lastError');
        }
      }
      throw Exception(
          'Failed to create final summary after $_maxRetries attempts. Last error: $lastError');
    } catch (e) {
      throw Exception('Error summarizing file: $e');
    }
  }
}
