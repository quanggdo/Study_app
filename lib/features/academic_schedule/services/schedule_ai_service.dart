import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../../../secret.dart';
import '../models/class_session_model.dart';

class ScheduleAiService {
  static const String _modelCandidates = 'gemini-2.5-flash';
  static const String _apiKey = GEMINI_API_KEY;

  Future<ScheduleAiResult> extractScheduleFromImage(XFile imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    final String mimeType = _guessMimeType(imageFile.name);

    const String prompt = '''
Hãy trích xuất toàn bộ văn bản trong ảnh này. Nếu là bảng, hãy giữ đúng cấu trúc hàng và cột.
Sau đó, hãy chuẩn hóa về JSON hợp lệ theo schema:
{
  "raw_text": "string",
  "rows": [
    {
      "subject_name": "string",
      "day_of_week": 2,
      "start_time": "HH:mm",
      "end_time": "HH:mm",
      "room": "string"
    }
  ]
}
Quy ước day_of_week: 2=Thứ 2, 3=Thứ 3, ..., 7=Thứ 7, 8=Chủ nhật.
Nếu không xác định được trường nào thì để rỗng hoặc bỏ qua dòng đó.
Chỉ trả về JSON, không dùng markdown.
''';

    final GenerateContentResponse response = await _generateWithFallback(
      apiKey: _apiKey,
      prompt: prompt,
      mimeType: mimeType,
      bytes: bytes,
    );

    final String text = (response.text ?? '').trim();
    if (text.isEmpty) {
      throw Exception('Gemini không trả về dữ liệu.');
    }

    final Map<String, dynamic> payload = _tryDecodeJson(text);
    final String rawText = payload['raw_text'] as String? ?? '';
    final List<dynamic> rows = payload['rows'] as List<dynamic>? ?? <dynamic>[];

    final List<ClassSessionModel> sessions = rows
        .whereType<Map<String, dynamic>>()
        .map(_toSession)
        .whereType<ClassSessionModel>()
        .toList();

    return ScheduleAiResult(rawText: rawText, sessions: sessions);
  }

  String _guessMimeType(String fileName) {
    final String lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerName.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
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

  ClassSessionModel? _toSession(Map<String, dynamic> row) {
    final String subjectName = (row['subject_name'] as String? ?? '').trim();
    final int? dayOfWeek = _toInt(row['day_of_week']);
    final String startTime = (row['start_time'] as String? ?? '').trim();
    final String endTime = (row['end_time'] as String? ?? '').trim();
    final String room = (row['room'] as String? ?? '').trim();

    if (subjectName.isEmpty ||
        dayOfWeek == null ||
        dayOfWeek < 2 ||
        dayOfWeek > 8 ||
        !_isValidTime(startTime) ||
        !_isValidTime(endTime)) {
      return null;
    }

    return ClassSessionModel(
      id: '',
      uid: '',
      subjectName: subjectName,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      room: room,
      isFromOcr: true,
      createdAt: DateTime.now(),
    );
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  bool _isValidTime(String value) {
    return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value);
  }

  Future<GenerateContentResponse> _generateWithFallback({
    required String apiKey,
    required String prompt,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    Object? lastError;

    {
      try {
        final GenerativeModel model = GenerativeModel(
          model: _modelCandidates,
          apiKey: apiKey,
        );

        return await model.generateContent(
          <Content>[
            Content.multi(<Part>[
              TextPart(prompt),
              DataPart(mimeType, bytes),
            ]),
          ],
        );
      } catch (e) {
        lastError = e;
        final String message = e.toString().toLowerCase();
        final bool quotaExceeded = message.contains('quota exceeded') ||
            message.contains('rate limit') ||
            message.contains('resource_exhausted');

        if (quotaExceeded) {
          final double? retrySeconds = _extractRetrySeconds(e.toString());
          final String retryText = retrySeconds == null
              ? ''
              : ' Vui lòng thử lại sau ${retrySeconds.toStringAsFixed(0)} giây.';

          throw Exception(
            'Gemini đã hết quota hoặc vượt giới hạn tốc độ cho API key hiện tại.'
            ' Hãy bật billing/nâng gói hoặc đổi API key khác.$retryText',
          );
        }

        final bool unsupportedModel =
            message.contains('not found') || message.contains('not supported');

        if (!unsupportedModel) {
          rethrow;
        }
      }
    }

    throw Exception(
      'Không tìm thấy model Gemini tương thích với API key hiện tại. '
      'Chi tiết: $lastError',
    );
  }

  double? _extractRetrySeconds(String message) {
    final RegExp retryRegex =
        RegExp(r'retry in\s+([0-9]+(?:\.[0-9]+)?)s', caseSensitive: false);
    final RegExpMatch? match = retryRegex.firstMatch(message);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(1) ?? '');
  }
}

final scheduleAiServiceProvider = Provider<ScheduleAiService>((ref) {
  return ScheduleAiService();
});

class ScheduleAiResult {
  final String rawText;
  final List<ClassSessionModel> sessions;

  const ScheduleAiResult({
    required this.rawText,
    required this.sessions,
  });
}
