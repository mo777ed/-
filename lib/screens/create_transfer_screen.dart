import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/fmt.dart';
import '../core/utils/ui.dart';
import '../models/transfer.dart';
import '../models/transfer_item.dart';
import '../providers/branch_provider.dart';
import '../providers/session_provider.dart';
import '../providers/transfers_provider.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/items_table.dart';
import 'invoice_screen.dart';
import 'item_form_sheet.dart';
import 'scanner_screen.dart';

class CreateTransferScreen extends StatefulWidget {
  const CreateTransferScreen({super.key});

  @override
  State<CreateTransferScreen> createState() => _CreateTransferScreenState();
}

class _CreateTransferScreenState extends State<CreateTransferScreen> {
  String? _from;
  String? _to;
  DateTime _date = Fmt.today();
  final List<TransferItem> _items = <TransferItem>[];

  bool _submitted = false;
  bool _saving = false;
  bool _saved = false;

  bool get _dirty =>
      !_saved && (_items.isNotEmpty || _from != null || _to != null);

  String? get _fromError =>
      (_from == null && _submitted) ? 'اختر الفرع المصدر' : null;

  String? get _toError {
    if (_to == null) return _submitted ? 'اختر الفرع المستلم' : null;
    if (_from != null && _from == _to) {
      return 'الفرع المستلم يجب أن يختلف عن الفرع المصدر';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  /// مسح باركود ثم فتح نموذج الصنف.
  Future<void> _addItem() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const ScannerScreen()),
    );
    if (code == null || !mounted) return;
    final item = await showItemFormSheet(context, barcode: code);
    if (item != null && mounted) setState(() => _items.add(item));
  }

  Future<void> _editItem(int index) async {
    final item = await showItemFormSheet(context, existing: _items[index]);
    if (item != null && mounted) setState(() => _items[index] = item);
  }

  Future<void> _deleteItem(int index) async {
    final ok = await confirmDialog(
      context,
      title: 'حذف الصنف',
      message: 'هل تريد حذف هذا الصنف من التحويل؟',
      confirmText: 'حذف',
      danger: true,
    );
    if (ok && mounted) setState(() => _items.removeAt(index));
  }

  String? _validate() {
    final employee = context.read<SessionProvider>().employee;
    if (employee == null || employee.name.trim().isEmpty) {
      return 'بيانات الموظف (الاسم) غير موجودة';
    }
    if (employee.phone.trim().isEmpty) return 'رقم جوال الموظف غير موجود';
    if (_from == null) return 'اختر الفرع المصدر';
    if (_to == null) return 'اختر الفرع المستلم';
    if (_from == _to) return 'لا يمكن التحويل إلى نفس الفرع';
    if (_items.isEmpty) return 'أضف صنفًا واحدًا على الأقل قبل الحفظ';
    for (final item in _items) {
      if (item.barcode.trim().isEmpty) return 'يوجد صنف بدون باركود';
      if (item.quantity < 1) return 'يوجد صنف عدده أقل من 1';
    }
    return null;
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final error = _validate();
    if (error != null) {
      showAppSnack(context, error, error: true);
      return;
    }

    final employee = context.read<SessionProvider>().employee!;
    final transfers = context.read<TransfersProvider>();
    setState(() => _saving = true);
    try {
      final id = await transfers.save(
        Transfer(
          fromBranch: _from!,
          toBranch: _to!,
          date: _date,
          employeeName: employee.name,
          employeePhone: employee.phone,
          createdAt: DateTime.now(),
          items: List<TransferItem>.of(_items),
        ),
      );
      if (!mounted) return;
      _saved = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => InvoiceScreen(transferId: id, justSaved: true),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnack(context, 'تعذّر حفظ التحويل، حاول مرة أخرى', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final names = context.watch<BranchProvider>().names;
    final employee = context.watch<SessionProvider>().employee;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await confirmDialog(
          context,
          title: 'إلغاء التحويل؟',
          message: 'لم يتم حفظ التحويل، وسيتم فقدان البيانات المُدخلة.',
          confirmText: 'خروج',
          cancelText: 'البقاء',
          danger: true,
        );
        if (leave && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: const BrandAppBar(title: 'تحويل بضاعة'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'بيانات التحويل',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownMenu<String>(
                    expandedInsets: EdgeInsets.zero,
                    label: const Text('من فرع'),
                    leadingIcon: const Icon(Icons.store_outlined),
                    initialSelection: _from,
                    errorText: _fromError,
                    enableSearch: false,
                    requestFocusOnTap: false,
                    dropdownMenuEntries: names
                        .map((n) => DropdownMenuEntry<String>(value: n, label: n))
                        .toList(),
                    onSelected: (v) => setState(() => _from = v),
                  ),
                  const SizedBox(height: 14),
                  DropdownMenu<String>(
                    expandedInsets: EdgeInsets.zero,
                    label: const Text('إلى فرع'),
                    leadingIcon: const Icon(Icons.storefront_outlined),
                    initialSelection: _to,
                    errorText: _toError,
                    enableSearch: false,
                    requestFocusOnTap: false,
                    dropdownMenuEntries: names
                        .map((n) => DropdownMenuEntry<String>(value: n, label: n))
                        .toList(),
                    onSelected: (v) => setState(() => _to = v),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: AppTheme.input('التاريخ',
                          icon: Icons.calendar_today_outlined),
                      child: Text(Fmt.date(_date)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  InputDecorator(
                    decoration: AppTheme.input('مسؤول التحويل',
                        icon: Icons.badge_outlined, filled: true),
                    child: Text(employee?.name ?? '—'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: _items.isEmpty ? 'الأصناف' : 'الأصناف (${_items.length})',
              child: _items.isEmpty ? _emptyItems() : _itemsBlock(),
            ),
            const SizedBox(height: 8),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.line, width: 0.8)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              textStyle:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('حفظ التحويل'),
          ),
        ),
      ),
    );
  }

  Widget _emptyItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        const Icon(Icons.qr_code_scanner, size: 44, color: AppTheme.brand),
        const SizedBox(height: 8),
        const Text(
          'لم تُضف أي أصناف بعد',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'اضغط على الزر وامسح باركود الصنف بالكاميرا',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: (_submitted && _items.isEmpty)
                ? AppTheme.danger
                : const Color(0xFF6D6A80),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          onPressed: _addItem,
          icon: const Icon(Icons.add),
          label: const Text('إضافة صنف'),
        ),
      ],
    );
  }

  Widget _itemsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemsTable(items: _items, onEdit: _editItem, onDelete: _deleteItem),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppTheme.brand,
          ),
          onPressed: _addItem,
          icon: const Icon(Icons.add),
          label: const Text('إضافة صنف آخر'),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.brand),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
