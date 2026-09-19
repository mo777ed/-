import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../core/constants/app_constants.dart';
import '../core/utils/fmt.dart';
import '../models/transfer.dart';
import 'zip_writer.dart';

/// إنشاء ملف Word (DOCX) حقيقي بدون مكتبات خارجية:
/// ملف DOCX هو ZIP يحتوي على ملفات XML، وهنا نكتبها مباشرة.
class DocxService {
  DocxService._();

  static const String _brandHex = '2D2650';
  static const String _softHex = 'F1EFF8';

  static Future<Uint8List> buildTransferDocx(Transfer t) async {
    final data = await rootBundle.load(AppConstants.logoFull);
    final logo = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // أبعاد صورة PNG من الترويسة (عرض/ارتفاع).
    final bd = ByteData.sublistView(logo);
    final pxW = bd.getUint32(16);
    final pxH = bd.getUint32(20);
    const heightEmu = 1080000; // 3 سم
    final widthEmu = (heightEmu * pxW / pxH).round();

    final zip = ZipWriter()
      ..addString('[Content_Types].xml', _contentTypes)
      ..addString('_rels/.rels', _rootRels)
      ..addString('word/document.xml', _document(t, widthEmu, heightEmu))
      ..addString('word/styles.xml', _styles)
      ..addString('word/_rels/document.xml.rels', _documentRels)
      ..addBytes('word/media/logo.png', logo);
    return zip.toBytes();
  }

  // ---------- أجزاء المستند ----------

  static String _document(Transfer t, int logoW, int logoH) {
    final body = StringBuffer();

    body.write(_logoParagraph(logoW, logoH));
    body.write(_para(AppConstants.appName,
        bold: true, size: 40, color: _brandHex, jc: 'center', after: 0));
    body.write(_para(AppConstants.invoiceTitle,
        bold: true, size: 32, color: _brandHex, jc: 'center', after: 200));

    // بيانات الفاتورة (٤ أعمدة: عنوان، قيمة، عنوان، قيمة)
    const infoW = <int>[1500, 3453, 1500, 3453];
    body.write(_table(infoW, <String>[
      _infoRow(infoW, 'رقم التحويل', t.number, 'التاريخ', Fmt.date(t.date),
          ltr1: true, ltr2: true),
      _infoRow(infoW, 'من فرع', t.fromBranch, 'إلى فرع', t.toBranch),
      _infoRow(infoW, 'مسؤول التحويل', t.employeeName, 'جوال المسؤول',
          t.employeePhone,
          ltr2: true),
    ]));
    body.write('<w:p/>');

    // جدول الأصناف
    const w = <int>[600, 2700, 3000, 1000, 2606];
    final rows = <String>[
      _row(<String>[
        _cell(w[0], _para('#', bold: true, color: 'FFFFFF', jc: 'center', after: 0), fill: _brandHex),
        _cell(w[1], _para('الباركود', bold: true, color: 'FFFFFF', jc: 'center', after: 0), fill: _brandHex),
        _cell(w[2], _para('اسم الصنف', bold: true, color: 'FFFFFF', jc: 'center', after: 0), fill: _brandHex),
        _cell(w[3], _para('العدد', bold: true, color: 'FFFFFF', jc: 'center', after: 0), fill: _brandHex),
        _cell(w[4], _para('تاريخ الانتهاء', bold: true, color: 'FFFFFF', jc: 'center', after: 0), fill: _brandHex),
      ], header: true),
    ];
    for (var i = 0; i < t.items.length; i++) {
      final it = t.items[i];
      final fill = i.isOdd ? _softHex : null;
      rows.add(_row(<String>[
        _cell(w[0], _para('${i + 1}', jc: 'center', rtl: false, after: 0), fill: fill),
        _cell(w[1], _para(it.barcode, jc: 'center', rtl: false, after: 0), fill: fill),
        _cell(w[2], _para(it.displayName, jc: 'center', after: 0), fill: fill),
        _cell(w[3], _para('${it.quantity}', bold: true, jc: 'center', rtl: false, after: 0), fill: fill),
        _cell(w[4], _para(it.displayExpiry, jc: 'center', rtl: false, after: 0), fill: fill),
      ]));
    }
    body.write(_table(w, rows));

    body.write('<w:p/>');
    body.write(_para('إجمالي عدد الأصناف: ${t.items.length}',
        bold: true, size: 26, after: 40));
    body.write(_para('إجمالي الكميات: ${t.totalQuantity}', size: 24));
    body.write('<w:p/><w:p/>');
    body.write(_para(
        'توقيع مسؤول التحويل: ______________________          توقيع المستلم: ______________________',
        size: 24));

    body.write('<w:sectPr>'
        '<w:pgSz w:w="11906" w:h="16838"/>'
        '<w:pgMar w:top="1000" w:right="1000" w:bottom="1000" w:left="1000" w:header="708" w:footer="708" w:gutter="0"/>'
        '<w:bidi/>'
        '</w:sectPr>');

    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document'
        ' xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'
        ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
        ' xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"'
        ' xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"'
        ' xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">'
        '<w:body>$body</w:body></w:document>';
  }

  static String _logoParagraph(int w, int h) {
    return '<w:p><w:pPr><w:spacing w:before="0" w:after="60"/><w:jc w:val="center"/></w:pPr><w:r><w:drawing>'
        '<wp:inline distT="0" distB="0" distL="0" distR="0">'
        '<wp:extent cx="$w" cy="$h"/>'
        '<wp:docPr id="1" name="Logo" descr="المقداع"/>'
        '<wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/></wp:cNvGraphicFramePr>'
        '<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'
        '<pic:pic>'
        '<pic:nvPicPr><pic:cNvPr id="0" name="logo.png"/><pic:cNvPicPr/></pic:nvPicPr>'
        '<pic:blipFill><a:blip r:embed="rId2"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>'
        '<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="$w" cy="$h"/></a:xfrm>'
        '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>'
        '</pic:pic></a:graphicData></a:graphic>'
        '</wp:inline></w:drawing></w:r></w:p>';
  }

  static String _infoRow(
    List<int> w,
    String l1,
    String v1,
    String l2,
    String v2, {
    bool ltr1 = false,
    bool ltr2 = false,
  }) {
    String label(int width, String s) => _cell(
        width, _para(s, bold: true, color: _brandHex, after: 0),
        fill: _softHex);
    String value(int width, String s, bool ltr) => _cell(
        width,
        ltr
            ? _para(s, rtl: false, jc: 'right', after: 0)
            : _para(s, after: 0));
    return _row(<String>[
      label(w[0], l1),
      value(w[1], v1, ltr1),
      label(w[2], l2),
      value(w[3], v2, ltr2),
    ]);
  }

  // ---------- عناصر XML ----------

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  static String _para(
    String text, {
    bool bold = false,
    int size = 22,
    String? color,
    bool rtl = true,
    String? jc,
    int after = 60,
  }) {
    final rPr = StringBuffer('<w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/>');
    if (bold) rPr.write('<w:b/><w:bCs/>');
    if (color != null) rPr.write('<w:color w:val="$color"/>');
    rPr.write('<w:sz w:val="$size"/><w:szCs w:val="$size"/>');
    if (rtl) rPr.write('<w:rtl/>');
    rPr.write('</w:rPr>');

    final pPr = StringBuffer('<w:pPr>');
    if (rtl) pPr.write('<w:bidi/>');
    pPr.write('<w:spacing w:before="0" w:after="$after"/>');
    if (jc != null) pPr.write('<w:jc w:val="$jc"/>');
    pPr.write('</w:pPr>');

    return '<w:p>$pPr<w:r>$rPr<w:t xml:space="preserve">${_esc(text)}</w:t></w:r></w:p>';
  }

  static String _cell(int width, String paragraphs, {String? fill}) {
    final shd = fill == null
        ? ''
        : '<w:shd w:val="clear" w:color="auto" w:fill="$fill"/>';
    return '<w:tc><w:tcPr><w:tcW w:w="$width" w:type="dxa"/>$shd<w:vAlign w:val="center"/></w:tcPr>$paragraphs</w:tc>';
  }

  static String _row(List<String> cells, {bool header = false}) {
    final trPr = header
        ? '<w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>'
        : '<w:trPr><w:cantSplit/></w:trPr>';
    return '<w:tr>$trPr${cells.join()}</w:tr>';
  }

  static String _table(List<int> widths, List<String> rows) {
    final total = widths.fold<int>(0, (a, b) => a + b);
    final grid = widths.map((w) => '<w:gridCol w:w="$w"/>').join();
    const border = 'w:val="single" w:sz="4" w:space="0" w:color="BDB8D4"';
    return '<w:tbl><w:tblPr>'
        '<w:bidiVisual/>'
        '<w:tblW w:w="$total" w:type="dxa"/>'
        '<w:tblBorders>'
        '<w:top $border/><w:left $border/><w:bottom $border/><w:right $border/>'
        '<w:insideH $border/><w:insideV $border/>'
        '</w:tblBorders>'
        '<w:tblLayout w:type="fixed"/>'
        '<w:tblCellMar><w:top w:w="70" w:type="dxa"/><w:left w:w="90" w:type="dxa"/>'
        '<w:bottom w:w="70" w:type="dxa"/><w:right w:w="90" w:type="dxa"/></w:tblCellMar>'
        '</w:tblPr><w:tblGrid>$grid</w:tblGrid>${rows.join()}</w:tbl>';
  }

  // ---------- ملفات ثابتة ----------

  static const String _contentTypes =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Default Extension="png" ContentType="image/png"/>'
      '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
      '</Types>';

  static const String _rootRels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
      '</Relationships>';

  static const String _documentRels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
      '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/logo.png"/>'
      '</Relationships>';

  static const String _styles =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:docDefaults><w:rPrDefault><w:rPr>'
      '<w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:eastAsia="Arial" w:cs="Arial"/>'
      '<w:sz w:val="22"/><w:szCs w:val="22"/>'
      '<w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/>'
      '</w:rPr></w:rPrDefault></w:docDefaults>'
      '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/></w:style>'
      '</w:styles>';
}
