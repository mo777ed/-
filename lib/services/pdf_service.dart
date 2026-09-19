import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/constants/app_constants.dart';
import '../core/utils/fmt.dart';
import '../models/transfer.dart';

/// إنشاء فاتورة PDF حقيقية (نص وليس صورة) باللغة العربية.
///
/// ملاحظة: تركيب الصفحة هنا LTR عمدًا مع ترتيب الأعمدة معكوسًا يدويًا،
/// أما النصوص نفسها فتُرسم RTL. هذا يعطي نتيجة ثابتة على جميع الإصدارات.
class PdfService {
  PdfService._();

  static final PdfColor _brand = PdfColor.fromInt(0xFF2D2650);
  static final PdfColor _soft = PdfColor.fromInt(0xFFF1EFF8);
  static final PdfColor _line = PdfColor.fromInt(0xFFBDB8D4);

  static final pw.EdgeInsets _pad =
      pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5);

  static pw.Font? _regular;
  static pw.Font? _bold;
  static Uint8List? _logo;

  static Uint8List _bytes(ByteData d) =>
      d.buffer.asUint8List(d.offsetInBytes, d.lengthInBytes);

  static Future<Uint8List> buildTransferPdf(Transfer t) async {
    final regular = _regular ??=
        pw.Font.ttf(await rootBundle.load(AppConstants.pdfFontRegular));
    final bold = _bold ??=
        pw.Font.ttf(await rootBundle.load(AppConstants.pdfFontBold));
    final logoBytes = _logo ??=
        _bytes(await rootBundle.load(AppConstants.logoFull));
    final logo = pw.MemoryImage(logoBytes);

    final doc = pw.Document(
      title: '${AppConstants.invoiceTitle} ${t.number}',
      author: t.employeeName,
      creator: AppConstants.appName,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 28),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        footer: _footer,
        build: (ctx) => <pw.Widget>[
          _header(logo, t),
          pw.SizedBox(height: 10),
          pw.Container(height: 1.5, color: _brand),
          pw.SizedBox(height: 14),
          _infoTable(t),
          pw.SizedBox(height: 16),
          _itemsTable(t),
          pw.SizedBox(height: 12),
          _totals(t),
          pw.SizedBox(height: 40),
          _signatures(),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _text(
    String s, {
    double size = 12,
    bool bold = false,
    PdfColor? color,
    pw.TextAlign align = pw.TextAlign.right,
    bool ltr = false,
  }) {
    return pw.Text(
      s,
      textDirection: ltr ? pw.TextDirection.ltr : pw.TextDirection.rtl,
      textAlign: align,
      style: pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      ),
    );
  }

  static pw.Widget _header(pw.MemoryImage logo, Transfer t) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: <pw.Widget>[
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: <pw.Widget>[
              _text(AppConstants.appName,
                  size: 26, bold: true, color: _brand),
              pw.SizedBox(height: 2),
              _text(AppConstants.invoiceTitle,
                  size: 20, bold: true, color: _brand),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: <pw.Widget>[
                  _text(t.number,
                      size: 13, bold: true, ltr: true, align: pw.TextAlign.left),
                  pw.SizedBox(width: 6),
                  _text('رقم التحويل:', size: 12, color: PdfColors.grey700),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 18),
        pw.Image(logo, height: 92, fit: pw.BoxFit.contain),
      ],
    );
  }

  static pw.Widget _label(String s) => pw.Container(
        color: _soft,
        padding: _pad,
        child: _text(s, size: 11.5, bold: true, color: _brand),
      );

  static pw.Widget _value(String s, {bool ltr = false}) => pw.Container(
        padding: _pad,
        child: _text(s, size: 12.5, ltr: ltr),
      );

  static pw.TableRow _infoRow(
    String l1,
    String v1,
    String l2,
    String v2, {
    bool ltr1 = false,
    bool ltr2 = false,
  }) {
    // ترتيب العرض من اليسار لليمين: (قيمة٢، عنوان٢، قيمة١، عنوان١)
    return pw.TableRow(children: <pw.Widget>[
      _value(v2, ltr: ltr2),
      _label(l2),
      _value(v1, ltr: ltr1),
      _label(l1),
    ]);
  }

  static pw.Widget _infoTable(Transfer t) {
    return pw.Table(
      border: pw.TableBorder.all(color: _line, width: 0.6),
      columnWidths: <int, pw.TableColumnWidth>{
        0: pw.FlexColumnWidth(2.4),
        1: pw.FlexColumnWidth(1.4),
        2: pw.FlexColumnWidth(2.4),
        3: pw.FlexColumnWidth(1.4),
      },
      children: <pw.TableRow>[
        _infoRow('رقم التحويل', t.number, 'التاريخ', Fmt.date(t.date),
            ltr1: true, ltr2: true),
        _infoRow('من فرع', t.fromBranch, 'إلى فرع', t.toBranch),
        _infoRow('مسؤول التحويل', t.employeeName, 'جوال المسؤول',
            t.employeePhone,
            ltr2: true),
      ],
    );
  }

  static pw.Widget _head(String s) => pw.Container(
        padding: _pad,
        alignment: pw.Alignment.center,
        child: _text(s,
            size: 11.5,
            bold: true,
            color: PdfColors.white,
            align: pw.TextAlign.center),
      );

  static pw.Widget _cell(String s, {bool ltr = false, bool bold = false}) =>
      pw.Container(
        padding: _pad,
        alignment: pw.Alignment.center,
        child: _text(s,
            size: 11.5, ltr: ltr, bold: bold, align: pw.TextAlign.center),
      );

  static pw.Widget _itemsTable(Transfer t) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: pw.BoxDecoration(color: _brand),
        // من اليسار لليمين: (الانتهاء، العدد، الاسم، الباركود، #)
        children: <pw.Widget>[
          _head('تاريخ الانتهاء'),
          _head('العدد'),
          _head('اسم الصنف'),
          _head('الباركود'),
          _head('#'),
        ],
      ),
    ];

    for (var i = 0; i < t.items.length; i++) {
      final it = t.items[i];
      rows.add(
        pw.TableRow(
          decoration:
              pw.BoxDecoration(color: i.isOdd ? _soft : PdfColors.white),
          children: <pw.Widget>[
            _cell(it.displayExpiry, ltr: true),
            _cell('${it.quantity}', bold: true),
            _cell(it.displayName),
            _cell(it.barcode, ltr: true),
            _cell('${i + 1}'),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _line, width: 0.6),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: <int, pw.TableColumnWidth>{
        0: pw.FlexColumnWidth(2.3),
        1: pw.FixedColumnWidth(48),
        2: pw.FlexColumnWidth(3),
        3: pw.FlexColumnWidth(3.3),
        4: pw.FixedColumnWidth(30),
      },
      children: rows,
    );
  }

  static pw.Widget _totals(Transfer t) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: <pw.Widget>[
          _text('إجمالي عدد الأصناف: ${t.items.length}',
              size: 13.5, bold: true),
          pw.SizedBox(height: 3),
          _text('إجمالي الكميات: ${t.totalQuantity}', size: 12.5),
        ],
      ),
    );
  }

  static pw.Widget _signatures() {
    pw.Widget box(String label) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: <pw.Widget>[
            _text(label, size: 12.5, bold: true, align: pw.TextAlign.center),
            pw.SizedBox(height: 32),
            pw.Container(width: 170, height: 0.8, color: PdfColors.grey600),
          ],
        );

    // اليمين: توقيع مسؤول التحويل — اليسار: توقيع المستلم
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        box('توقيع المستلم'),
        box('توقيع مسؤول التحويل'),
      ],
    );
  }

  static pw.Widget _footer(pw.Context ctx) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _line, width: 0.6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          _text('صفحة ${ctx.pageNumber} من ${ctx.pagesCount}',
              size: 10, color: PdfColors.grey700, align: pw.TextAlign.left),
          _text('${AppConstants.appName} — ${AppConstants.invoiceTitle}',
              size: 10, color: PdfColors.grey700),
        ],
      ),
    );
  }
}
