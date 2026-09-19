import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/digits.dart';
import '../core/utils/fmt.dart';
import '../models/transfer_item.dart';
import 'scanner_screen.dart';

/// نافذة إضافة/تعديل صنف. تعيد TransferItem أو null عند الإلغاء.
Future<TransferItem?> showItemFormSheet(
  BuildContext context, {
  String? barcode,
  TransferItem? existing,
}) {
  return showModalBottomSheet<TransferItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: ItemFormSheet(initialBarcode: barcode, existing: existing),
    ),
  );
}

class ItemFormSheet extends StatefulWidget {
  const ItemFormSheet({super.key, this.initialBarcode, this.existing});

  final String? initialBarcode;
  final TransferItem? existing;

  @override
  State<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _barcode;
  late final TextEditingController _name;
  late final TextEditingController _qty;
  DateTime? _expiry;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _barcode = TextEditingController(text: e?.barcode ?? widget.initialBarcode ?? '');
    _name = TextEditingController(text: e?.name ?? '');
    _qty = TextEditingController(text: e == null ? '' : '${e.quantity}');
    _expiry = e?.expiryDate;
  }

  @override
  void dispose() {
    _barcode.dispose();
    _name.dispose();
    _qty.dispose();
    super.dispose();
  }

  Future<void> _rescan() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const ScannerScreen()),
    );
    if (code != null && mounted) setState(() => _barcode.text = code);
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _expiry = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _name.text.trim();
    Navigator.of(context).pop(
      TransferItem(
        barcode: normalizeDigits(_barcode.text.trim()),
        name: name.isEmpty ? null : name,
        quantity: int.parse(normalizeDigits(_qty.text.trim())),
        expiryDate: _expiry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEdit ? 'تعديل الصنف' : 'إضافة صنف',
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brand),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _barcode,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: AppTheme.input(
                'رقم الباركود',
                icon: Icons.qr_code_2,
                suffix: IconButton(
                  tooltip: 'مسح الباركود',
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _rescan,
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'رقم الباركود مطلوب'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: AppTheme.input('اسم الصنف (اختياري)',
                  icon: Icons.inventory_2_outlined),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qty,
              autofocus: !_isEdit && widget.initialBarcode != null,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [DigitsOnlyFormatter()],
              decoration:
                  AppTheme.input('العدد', icon: Icons.pin_outlined),
              validator: (v) {
                final n = int.tryParse(normalizeDigits((v ?? '').trim()));
                if (n == null || n < 1) return 'العدد مطلوب ويجب أن يكون 1 أو أكثر';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickExpiry,
              child: InputDecorator(
                decoration: AppTheme.input(
                  'تاريخ الانتهاء (اختياري)',
                  icon: Icons.event_outlined,
                  suffix: _expiry == null
                      ? null
                      : IconButton(
                          tooltip: 'مسح التاريخ',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _expiry = null),
                        ),
                ),
                child: Text(
                  _expiry == null ? 'اضغط لاختيار التاريخ' : Fmt.date(_expiry!),
                  style: TextStyle(
                    color: _expiry == null ? const Color(0xFF8C89A0) : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              onPressed: _submit,
              child: Text(_isEdit ? 'حفظ التعديل' : 'إضافة'),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }
}
