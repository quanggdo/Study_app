import 'flashcard_card.dart';
import 'review_state.dart';

/// Card kèm trạng thái ôn (ReviewState).
///
/// Nếu [state] == null nghĩa là thẻ chưa từng được ôn, coi như "đến hạn".
class DueCard {
  const DueCard({
    required this.card,
    required this.state,
  });

  final FlashcardCard card;
  final ReviewState? state;
}

