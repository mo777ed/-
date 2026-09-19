import 'dart:convert';
import 'dart:typed_data';

/// كاتب ZIP بسيط (بدون ضغط) يكفي لإنشاء ملفات DOCX بدون أي مكتبة خارجية.
class ZipWriter {
  final List<_Entry> _entries = <_Entry>[];

  void addBytes(String name, List<int> bytes) {
    _entries.add(_Entry(name, Uint8List.fromList(bytes)));
  }

  void addString(String name, String content) =>
      addBytes(name, utf8.encode(content));

  Uint8List toBytes() {
    const dosDate = ((2026 - 1980) << 9) | (1 << 5) | 1; // 2026-01-01
    const dosTime = 0;

    final out = BytesBuilder();
    final central = BytesBuilder();

    for (final e in _entries) {
      final nameBytes = utf8.encode(e.name);
      final crc = _crc32(e.data);
      final offset = out.length;

      // Local file header
      _u32(out, 0x04034b50);
      _u16(out, 20);
      _u16(out, 0x0800); // UTF-8 names
      _u16(out, 0); // stored
      _u16(out, dosTime);
      _u16(out, dosDate);
      _u32(out, crc);
      _u32(out, e.data.length);
      _u32(out, e.data.length);
      _u16(out, nameBytes.length);
      _u16(out, 0);
      out.add(nameBytes);
      out.add(e.data);

      // Central directory header
      _u32(central, 0x02014b50);
      _u16(central, 20);
      _u16(central, 20);
      _u16(central, 0x0800);
      _u16(central, 0);
      _u16(central, dosTime);
      _u16(central, dosDate);
      _u32(central, crc);
      _u32(central, e.data.length);
      _u32(central, e.data.length);
      _u16(central, nameBytes.length);
      _u16(central, 0);
      _u16(central, 0);
      _u16(central, 0);
      _u16(central, 0);
      _u32(central, 0);
      _u32(central, offset);
      central.add(nameBytes);
    }

    final centralOffset = out.length;
    final centralBytes = central.toBytes();
    out.add(centralBytes);

    // End of central directory
    _u32(out, 0x06054b50);
    _u16(out, 0);
    _u16(out, 0);
    _u16(out, _entries.length);
    _u16(out, _entries.length);
    _u32(out, centralBytes.length);
    _u32(out, centralOffset);
    _u16(out, 0);

    return out.toBytes();
  }

  static void _u16(BytesBuilder b, int v) {
    b.addByte(v & 0xFF);
    b.addByte((v >> 8) & 0xFF);
  }

  static void _u32(BytesBuilder b, int v) {
    b.addByte(v & 0xFF);
    b.addByte((v >> 8) & 0xFF);
    b.addByte((v >> 16) & 0xFF);
    b.addByte((v >> 24) & 0xFF);
  }

  static final List<int> _table = List<int>.generate(256, (n) {
    var c = n;
    for (var k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
    }
    return c;
  });

  static int _crc32(List<int> data) {
    var c = 0xFFFFFFFF;
    for (final b in data) {
      c = _table[(c ^ b) & 0xFF] ^ (c >> 8);
    }
    return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }
}

class _Entry {
  _Entry(this.name, this.data);
  final String name;
  final Uint8List data;
}
