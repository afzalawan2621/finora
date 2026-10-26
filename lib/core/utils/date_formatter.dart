import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String full(DateTime? date) =>
      date == null ? '-' : DateFormat('dd MMM yyyy').format(date);

  static String dayMonth(DateTime? date) =>
      date == null ? '-' : DateFormat('dd MMM').format(date);

  static String monthYear(DateTime? date) =>
      date == null ? '-' : DateFormat('MMMM yyyy').format(date);

  static String monthShort(DateTime? date) =>
      date == null ? '-' : DateFormat('MMM').format(date);

  static String time(DateTime? date) =>
      date == null ? '-' : DateFormat('hh:mm a').format(date);

  static String fullDateTime(DateTime? date) =>
      date == null ? '-' : DateFormat('dd MMM yyyy, hh:mm a').format(date);

  static String iso(DateTime? date) =>
      date == null ? '' : DateFormat('yyyy-MM-dd').format(date);

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}