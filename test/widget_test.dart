import 'package:almegdaa/core/utils/digits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeDigits converts Arabic-Indic and Persian digits', () {
    expect(normalizeDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    expect(normalizeDigits('۰۱۲'), '012');
    expect(normalizeDigits('AB-12'), 'AB-12');
  });
}
