import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../secret.dart';

class NoteAiService {
  static const String _modelName = 'gemini-2.5-flash';
  static const String _apiKey = GEMINI_API_KEY;

  Future<NoteAiResult> buildNoteFromTranscript({
    required String transcript,
    String? subjectHint,
  }) async {
    final String normalizedTranscript = transcript.trim();
    if (normalizedTranscript.isEmpty) {
      throw Exception('Nội dung giọng nói đang trống.');
    }

    final String prompt = _buildPrompt(
      sourceType: 'voice_text',
      subjectHint: subjectHint,
      transcript: normalizedTranscript,
    );

    final GenerateContentResponse response = await _generateContent(
      prompt: prompt,
      audioMimeType: null,
      audioBytes: null,
    );

    return _parseResponse(response.text ?? '');
  }

  Future<NoteAiResult> buildNoteFromAudioFile({
    required PlatformFile file,
    String? subjectHint,
  }) async {
    final Uint8List audioBytes = await _readAudioBytes(file);
    final String mimeType = _guessAudioMimeType(file);

    final String prompt = _buildPrompt(
      sourceType: 'audio_file',
      subjectHint: subjectHint,
      transcript: null,
    );

    final GenerateContentResponse response = await _generateContent(
      prompt: prompt,
      audioMimeType: mimeType,
      audioBytes: audioBytes,
    );

    return _parseResponse(response.text ?? '');
  }

  Future<GenerateContentResponse> _generateContent({
    required String prompt,
    required String? audioMimeType,
    required Uint8List? audioBytes,
  }) async {
    try {
      final GenerativeModel model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
      );

      final List<Part> parts = <Part>[TextPart(prompt)];
      if (audioMimeType != null && audioBytes != null) {
        parts.add(DataPart(audioMimeType, audioBytes));
      }

      final GenerateContentResponse response = await model.generateContent(
        <Content>[Content.multi(parts)],
      );

      final String text = (response.text ?? '').trim();
      if (text.isEmpty) {
        throw Exception('Gemini không trả về dữ liệu.');
      }

      return response;
    } catch (e) {
      final String message = e.toString().toLowerCase();
      final bool quotaExceeded = message.contains('quota exceeded') ||
          message.contains('rate limit') ||
          message.contains('resource_exhausted');

      if (quotaExceeded) {
        throw Exception(
          'Gemini đã hết quota hoặc vượt giới hạn tốc độ cho API key hiện tại. '
          'Vui lòng thử lại sau hoặc đổi API key.',
        );
      }

      rethrow;
    }
  }

  Future<Uint8List> _readAudioBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes!;
    }

    final String? path = file.path;
    if (path == null || path.isEmpty) {
      throw Exception('Không thể đọc file ghi âm đã chọn.');
    }

    return File(path).readAsBytes();
  }

  String _guessAudioMimeType(PlatformFile file) {
    final String extension = (file.extension ?? '').toLowerCase();
    switch (extension) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      case 'webm':
        return 'audio/webm';
      default:
        return 'audio/mpeg';
    }
  }

  NoteAiResult _parseResponse(String rawResponse) {
    final String cleaned = rawResponse.trim();
    if (cleaned.isEmpty) {
      throw Exception('Gemini không trả về dữ liệu.');
    }

    final Map<String, dynamic> payload = _tryDecodeJson(cleaned);
    final String subjectName = (payload['subject_name'] as String? ?? '').trim();
    final String content = (payload['content'] as String? ?? '').trim();

    if (content.isEmpty) {
      throw Exception('Không thể tạo nội dung ghi chú từ dữ liệu ASR.');
    }

    return NoteAiResult(
      subjectName: subjectName,
      content: content,
      rawResponse: cleaned,
    );
  }

  Map<String, dynamic> _tryDecodeJson(String content) {
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      final RegExp fencedRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
      final RegExpMatch? match = fencedRegex.firstMatch(content);
      if (match != null) {
        final String inner = match.group(1) ?? '';
        return jsonDecode(inner) as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  String _buildPrompt({
    required String sourceType,
    required String? subjectHint,
    required String? transcript,
  }) {
    final String cleanSubjectHint = (subjectHint ?? '').trim();
    final String normalizedSubjectHint =
        cleanSubjectHint.isEmpty ? 'Không có' : cleanSubjectHint;
    final String transcriptInput = transcript == null || transcript.trim().isEmpty
        ? 'Không có transcript sẵn, hãy tự phiên âm từ audio.'
        : transcript.trim();

    return '''
Bạn là trợ lý học tập tiếng Việt cho sinh viên đại học. Hãy chuyển đầu vào ASR thành ghi chú chất lượng cao để ôn thi.

MỤC TIÊU CHÍNH:
- Suy luận tên môn học phù hợp nhất từ nội dung. Ưu tiên subject_hint nếu hợp lý.
- Tổ chức nội dung thành nhiều ý rõ ràng, dễ học lại nhanh.

QUY TẮC BIÊN TẬP:
- Chuẩn hóa chính tả, dùng tiếng Việt tự nhiên.
- Không bịa thông tin ngoài dữ liệu đầu vào.
- Bắt buộc format nội dung bằng gạch đầu dòng, mỗi ý một dòng bắt đầu bằng "- ".
- Nếu có công thức/định nghĩa, tách riêng thành dòng bullet độc lập.
- Nếu chưa chắc môn học, để subject_name là chuỗi rỗng.

ĐẦU VÀO:
- source_type: $sourceType
- subject_hint: $normalizedSubjectHint
- transcript_text: $transcriptInput

ĐẦU RA JSON HỢP LỆ (chỉ trả JSON, không markdown):
{
  "subject_name": "string",
  "content": "string"
}
''';
  }
}

final noteAiServiceProvider = Provider<NoteAiService>((ref) {
  return NoteAiService();
});

class NoteAiResult {
  final String subjectName;
  final String content;
  final String rawResponse;

  const NoteAiResult({
    required this.subjectName,
    required this.content,
    required this.rawResponse,
  });

  NoteAiResult copyWith({
    String? subjectName,
    String? content,
    String? rawResponse,
  }) {
    return NoteAiResult(
      subjectName: subjectName ?? this.subjectName,
      content: content ?? this.content,
      rawResponse: rawResponse ?? this.rawResponse,
    );
  }
}
