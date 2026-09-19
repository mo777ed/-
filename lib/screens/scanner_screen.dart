import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/digits.dart';
import '../widgets/brand_app_bar.dart';

/// شاشة مسح الباركود. تُغلق تلقائيًا بعد أول قراءة وتعيد رقم الباركود (String).
/// يمكن أيضًا إدخال الباركود يدويًا إذا لم تعمل الكاميرا.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

  bool _handled = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        _handled = true;
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop(value);
        return;
      }
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      if (mounted) setState(() => _torchOn = !_torchOn);
    } catch (_) {
      // الجهاز لا يدعم الفلاش.
    }
  }

  Future<void> _manualEntry() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ManualBarcodeDialog(),
    );
    if (code != null && code.isNotEmpty && mounted) {
      _handled = true;
      Navigator.of(context).pop(code);
    }
  }

  String _errorMessage(MobileScannerException error) {
    String detail = error.errorCode.name;
    try {
      final message = (error as dynamic).errorDetails?.message;
      if (message != null) detail = '$detail: $message';
    } catch (_) {}

    final base = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? 'لم يتم السماح للتطبيق باستخدام الكاميرا. فعّل صلاحية الكاميرا من إعدادات الجهاز، أو أدخل الباركود يدويًا.'
        : 'تعذّر تشغيل الكاميرا على هذا الجهاز. تأكد من صلاحية الكاميرا في إعدادات التطبيق، أو أدخل الباركود يدويًا.';
    return '$base\n\n($detail)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: BrandAppBar(
        title: 'مسح الباركود',
        actions: [
          IconButton(
            tooltip: 'الفلاش',
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleTorch,
          ),
          IconButton(
            tooltip: 'تبديل الكاميرا',
            icon: const Icon(Icons.cameraswitch_outlined),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, [child]) => _CameraError(
                message: _errorMessage(error),
                onManual: _manualEntry,
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 290,
                height: 170,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2.5),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withAlpha(150),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'وجّه الكاميرا نحو الباركود داخل الإطار',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'إذا لم يُقرأ الباركود، قرّب الكاميرا أو أضئ الفلاش أو أدخله يدويًا',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      minimumSize: const Size.fromHeight(46),
                    ),
                    onPressed: _manualEntry,
                    icon: const Icon(Icons.keyboard_outlined),
                    label: const Text('إدخال الباركود يدويًا'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.message, required this.onManual});

  final String message;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF14121F),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_photography_outlined,
              size: 56, color: Colors.white70),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, height: 1.6),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: AppTheme.brand),
            onPressed: onManual,
            icon: const Icon(Icons.keyboard_outlined),
            label: const Text('إدخال الباركود يدويًا'),
          ),
        ],
      ),
    );
  }
}

class _ManualBarcodeDialog extends StatefulWidget {
  const _ManualBarcodeDialog();

  @override
  State<_ManualBarcodeDialog> createState() => _ManualBarcodeDialogState();
}

class _ManualBarcodeDialogState extends State<_ManualBarcodeDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = normalizeDigits(_controller.text.trim());
    if (value.isEmpty) {
      setState(() => _error = 'أدخل رقم الباركود');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إدخال الباركود يدويًا'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textDirection: TextDirection.ltr,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: AppTheme.input('رقم الباركود', errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _submit, child: const Text('تأكيد')),
      ],
    );
  }
}
