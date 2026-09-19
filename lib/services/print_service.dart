import 'dart:typed_data';

import 'package:printing/printing.dart';

/// الطباعة والمشاركة عبر مكتبة printing.
class PrintService {
  PrintService._();

  static Future<void> printPdf(Uint8List bytes, String name) async {
    await Printing.layoutPdf(
      name: name,
      onLayout: (format) async => bytes,
    );
  }

  static Future<void> sharePdf(Uint8List bytes, String fileName) async {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }
}
