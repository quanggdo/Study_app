/// Helpers để preview interval/label cho các nút Again/Hard/Good/Easy
/// giống cách Anki hiển thị trước khi bấm.
library;

import '../models/review_state.dart';
import 'sm2.dart';

/// Các lựa chọn chấm điểm trên UI.
enum ReviewAction { again, hard, good, easy }

extension ReviewActionX on ReviewAction {
  int get quality {
    switch (this) {
      case ReviewAction.again:
        return 1;
      case ReviewAction.hard:
        return 3;
      case ReviewAction.good:
        return 4;
      case ReviewAction.easy:
        return 5;
    }
  }

  String get title {
    switch (this) {
      case ReviewAction.again:
        return 'Again';
      case ReviewAction.hard:
        return 'Hard';
      case ReviewAction.good:
        return 'Good';
      case ReviewAction.easy:
        return 'Easy';
    }
  }
}

/// Kết quả preview hiển thị trên UI.
class Sm2Preview {
  final ReviewAction action;
  final Duration interval;

  const Sm2Preview({required this.action, required this.interval});

  String get label => _formatInterval(interval);

  static String _formatInterval(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    if (d.inDays < 30) return '${d.inDays}d';

    // Anki thường chuyển sang tháng/năm khi đủ lớn.
    final months = (d.inDays / 30).round();
    if (months < 12) return '${months}mo';

    final years = (d.inDays / 365).round();
    return '${years}y';
  }
}

/// Tạo preview cho 4 nút, dự đoán đúng theo Sm2.grade().
///
/// - `now` nên là DateTime.now() từ UI.
/// - `previous` là ReviewState hiện tại của card.
List<Sm2Preview> buildSm2Previews({
  required ReviewState previous,
  required DateTime now,
}) {
  final actions = ReviewAction.values;
  return actions.map((a) {
    final next = Sm2.grade(previous: previous, quality: a.quality, now: now);
    final interval = next.dueAt.difference(now);
    return Sm2Preview(action: a, interval: interval);
  }).toList(growable: false);
}

