import 'dart:math' as math;

import 'package:flutter/services.dart';

/// يحوّل الأرقام العربية (٠-٩) والفارسية (۰-۹) إلى أرقام لاتينية.
String normalizeDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(rune - 0x0660 + 0x30);
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(rune - 0x06F0 + 0x30);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// يقبل الأرقام فقط (ويحوّل الأرقام العربية تلقائيًا).
class DigitsOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned =
        normalizeDigits(newValue.text).replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned == newValue.text) return newValue;
    final offset =
        math.min(math.max(newValue.selection.baseOffset, 0), cleaned.length);
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
