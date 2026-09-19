import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/ui.dart';
import '../models/transfer.dart';
import '../providers/transfers_provider.dart';
import '../services/docx_service.dart';
import '../services/file_export_service.dart';
import '../services/pdf_service.dart';
import '../services/print_service.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/invoice_paper.dart';

/// عرض الفاتورة + (طباعة / تحميل PDF / مشاركة / تصدير Word).
class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({
    super.key,
    required this.transferId,
    this.justSaved = false,
  });

  final int transferId;
  final bool justSaved;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  Transfer? _transfer;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<TransfersProvider>();
    try {
      final t = await provider.getById(widget.transferId);
      if (!mounted) return;
      setState(() {
        _transfer = t;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _fileName(String ext) => 'Transfer_${_transfer!.number}.$ext';

  Future<void> _run(Future<void> Function() task) async {
    if (_busy || _transfer == null) return;
    setState(() => _busy = true);
    try {
      await task();
    } catch (e) {
      debugPrint('Export error: $e');
      if (mounted) {
        showAppSnack(context, 'حدث خطأ أثناء تنفيذ العملية، حاول مرة أخرى',
            error: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _print() => _run(() async {
        final bytes = await PdfService.buildTransferPdf(_transfer!);
        await PrintService.printPdf(bytes, _fileName('pdf'));
      });

  Future<void> _sharePdf() => _run(() async {
        final bytes = await PdfService.buildTransferPdf(_transfer!);
        await PrintService.sharePdf(bytes, _fileName('pdf'));
      });

  Future<void> _downloadPdf() => _run(() async {
        final bytes = await PdfService.buildTransferPdf(_transfer!);
        final ok = await FileExportService.save(
            bytes: bytes, fileName: _fileName('pdf'), extension: 'pdf');
        if (ok && mounted) showAppSnack(context, 'تم حفظ ملف PDF');
      });

  Future<void> _exportWord() => _run(() async {
        final bytes = await DocxService.buildTransferDocx(_transfer!);
        final ok = await FileExportService.save(
            bytes: bytes, fileName: _fileName('docx'), extension: 'docx');
        if (ok && mounted) showAppSnack(context, 'تم حفظ ملف Word');
      });

  @override
  Widget build(BuildContext context) {
    final t = _transfer;

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (t == null) {
      body = const EmptyState(
        icon: Icons.error_outline,
        title: 'تعذّر العثور على التحويل',
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (widget.justSaved) _SavedBanner(number: t.number),
          InvoicePaper(transfer: t),
        ],
      );
    }

    return Scaffold(
      appBar: const BrandAppBar(title: 'فاتورة التحويل'),
      body: body,
      bottomNavigationBar: t == null ? null : _actions(),
    );
  }

  Widget _actions() {
    final tall = FilledButton.styleFrom(minimumSize: const Size.fromHeight(46));
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.line, width: 0.8)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_busy) ...[
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: tall,
                  onPressed: _busy ? null : _print,
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('طباعة'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: tall,
                  onPressed: _busy ? null : _downloadPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('تحميل PDF'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46)),
                  onPressed: _busy ? null : _sharePdf,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('مشاركة PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46)),
                  onPressed: _busy ? null : _exportWord,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('تصدير Word'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedBanner extends StatelessWidget {
  const _SavedBanner({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB5E2CA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.success),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تم حفظ التحويل بنجاح',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: AppTheme.success)),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('رقم التحويل: '),
                    Text(number,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
