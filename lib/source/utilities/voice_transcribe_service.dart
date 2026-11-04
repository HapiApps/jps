import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../constant/api.dart';

class VoiceTranscribeService {

  static const String _prompt = 'Transcribe this voice note exactly as spoken, '
      'in the same language the speaker used. '
      'Do NOT translate. '
      'Write each language in its own native script. '
      'Return only the transcript text, nothing else.';

  static String _mimeType(String pathOrUrl) {
    var ext = pathOrUrl.split('.').last.toLowerCase();
    ext = ext.split('&').first.split('#').first.split('?').first.trim();
    switch (ext) {
      case 'wav':
        return 'audio/wav';
      case 'mp3':
        return 'audio/mp3';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
      case 'opus':
        return 'audio/ogg';
      case 'amr':
      case '3gp':
        return 'audio/3gpp';
      default:
        return 'audio/mp4'; // m4a
    }
  }

  /// Local file path
  static Future<String> transcribe(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return _send(bytes, _mimeType(filePath));
  }

  /// ✅ Network URL (task details page voice notes / chat voice)
  static Future<String> transcribeUrl(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
      throw Exception('Audio download failed (${res.statusCode})');
    }
    return _send(res.bodyBytes, _mimeType(url));
  }

  static Future<String> _send(Uint8List bytes, String mime) async {
    if (geminiKey.isEmpty) throw Exception('Gemini key not set');

    final base64Audio = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(geminiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': geminiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': _prompt},
              {
                'inline_data': {
                  'mime_type': mime,
                  'data': base64Audio,
                }
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (text == null || text.toString().trim().isEmpty) {
      throw Exception('Empty transcript');
    }
    return text.toString().trim();
  }
}