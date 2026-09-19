import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/ui.dart';
import '../models/branch.dart';
import '../providers/branch_provider.dart';
import '../widgets/brand_app_bar.dart';

/// إضافة وتعديل وحذف الفروع.
class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NameDialog(title: 'إضافة فرع'),
    );
    if (name == null || !context.mounted) return;
    final ok = await context.read<BranchProvider>().add(name);
    if (!context.mounted) return;
    if (!ok) showAppSnack(context, 'اسم الفرع مكرر أو غير صالح', error: true);
  }

  Future<void> _rename(BuildContext context, Branch branch) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          _NameDialog(title: 'تعديل اسم الفرع', initial: branch.name),
    );
    if (name == null || !context.mounted) return;
    final ok = await context.read<BranchProvider>().rename(branch.id!, name);
    if (!context.mounted) return;
    if (!ok) showAppSnack(context, 'اسم الفرع مكرر أو غير صالح', error: true);
  }

  Future<void> _delete(BuildContext context, Branch branch, int count) async {
    if (count <= 2) {
      showAppSnack(context, 'يجب أن يبقى فرعان على الأقل لإجراء التحويلات',
          error: true);
      return;
    }
    final ok = await confirmDialog(
      context,
      title: 'حذف الفرع',
      message:
          'هل تريد حذف "${branch.name}"؟ التحويلات السابقة لن تتأثر.',
      confirmText: 'حذف',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    await context.read<BranchProvider>().remove(branch.id!);
  }

  @override
  Widget build(BuildContext context) {
    final branches = context.watch<BranchProvider>().branches;

    return Scaffold(
      appBar: const BrandAppBar(title: 'إدارة الفروع'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.brand,
        foregroundColor: Colors.white,
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة فرع'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: branches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final b = branches[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.line),
            ),
            child: ListTile(
              leading: const Icon(Icons.store_outlined, color: AppTheme.brand),
              title: Text(b.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'تعديل',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _rename(context, b),
                  ),
                  IconButton(
                    tooltip: 'حذف',
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.danger),
                    onPressed: () => _delete(context, b, branches.length),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, this.initial});

  final String title;
  final String? initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial ?? '');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'اسم الفرع مطلوب');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: AppTheme.input('اسم الفرع', errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _submit, child: const Text('حفظ')),
      ],
    );
  }
}
