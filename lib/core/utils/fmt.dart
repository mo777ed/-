import 'package:intl/intl.dart';

/// تنسيق التواريخ (بأرقام لاتينية لتتوافق مع أرقام الباركود).
class Fmt {
  Fmt._();

  static final DateFormat _display = DateFormat('dd/MM/yyyy', 'en');
  static final DateFormat _iso = DateFormat('yyyy-MM-dd', 'en');
  static final DateFormat _compact = DateFormat('yyMMdd', 'en');

  static String date(DateTime d) => _display.format(d);
  static String iso(DateTime d) => _iso.format(d);
  static String compact(DateTime d) => _compact.format(d);

  static DateTime? tryParseIso(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  static DateTime today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}
