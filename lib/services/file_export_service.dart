import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// حفظ الملفات على الجهاز (يفتح نافذة اختيار مكان الحفظ).
class FileExportService {
  FileExportService._();

  /// يعيد true إذا تم الحفظ، و false إذا ألغى المستخدم.
  static Future<bool> save({
    required Uint8List bytes,
    required String fileName,
    required String extension,
  }) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'حفظ الملف',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: <String>[extension],
      bytes: bytes,
    );
    if (path == null) return false;
    // على أندرويد وiOS تُكتب البيانات تلقائيًا، وعلى سطح المكتب نكتبها يدويًا.
    if (!(Platform.isAndroid || Platform.isIOS)) {
      await File(path).writeAsBytes(bytes);
    }
    return true;
  }
}
