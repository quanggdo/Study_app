import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static final DateFormat _vietnameseDate = DateFormat('dd/MM/yyyy');
  static final DateFormat _vietnameseTime = DateFormat('HH:mm');
  static final DateFormat _fullDateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String formatDate(DateTime date) => _vietnameseDate.format(date);
  static String formatTime(DateTime time) => _vietnameseTime.format(time);
  static String formatFull(DateTime dateTime) => _fullDateTime.format(dateTime);

  static String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return formatFull(timestamp.toDate());
  }

  static String formatOnlyDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return formatDate(timestamp.toDate());
  }
}
