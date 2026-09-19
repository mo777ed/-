import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/transfer_item.dart';

enum _ItemAction { edit, delete }

/// جدول الأصناف: # | الباركود | اسم الصنف | العدد | تاريخ الانتهاء
/// عند تمرير onEdit/onDelete يظهر عمود خيارات (تعديل/حذف).
class ItemsTable extends StatelessWidget {
  const ItemsTable({
    super.key,
    required this.items,
    this.onEdit,
    this.onDelete,
  });

  final List<TransferItem> items;
  final void Function(int index)? onEdit;
  final void Function(int index)? onDelete;

  bool get _editable => onEdit != null || onDelete != null;

  Widget _cell(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Center(child: child),
      );

  Widget _head(String s) => _cell(Text(
        s,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      ));

  @override
  Widget build(BuildContext context) {
    final widths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(30),
      1: const FlexColumnWidth(3.4),
      2: const FlexColumnWidth(2.6),
      3: const FixedColumnWidth(46),
      4: const FlexColumnWidth(2.6),
    };
    if (_editable) widths[5] = const FixedColumnWidth(40);

    final rows = <TableRow>[
      TableRow(
        decoration: const BoxDecoration(color: AppTheme.brand),
        children: [
          _head('#'),
          _head('الباركود'),
          _head('اسم الصنف'),
          _head('العدد'),
          _head('تاريخ الانتهاء'),
          if (_editable) const SizedBox.shrink(),
        ],
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      rows.add(
        TableRow(
          decoration: BoxDecoration(
            color: i.isOdd ? AppTheme.brandSoft : Colors.white,
          ),
          children: [
            _cell(Text('${i + 1}', style: const TextStyle(fontSize: 12))),
            _cell(FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.barcode,
                textDirection: TextDirection.ltr,
                style:
                    const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
              ),
            )),
            _cell(Text(
              item.displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            )),
            _cell(Text(
              '${item.quantity}',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            )),
            _cell(FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.displayExpiry,
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontSize: 12),
              ),
            )),
            if (_editable) _actions(i),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Table(
        columnWidths: widths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(color: AppTheme.line, width: 0.8),
        children: rows,
      ),
    );
  }

  Widget _actions(int index) {
    return PopupMenuButton<_ItemAction>(
      tooltip: 'خيارات',
      padding: EdgeInsets.zero,
      iconSize: 20,
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        if (action == _ItemAction.edit) {
          onEdit?.call(index);
        } else {
          onDelete?.call(index);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _ItemAction.edit,
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 20),
            SizedBox(width: 10),
            Text('تعديل'),
          ]),
        ),
        PopupMenuItem(
          value: _ItemAction.delete,
          child: Row(children: [
            Icon(Icons.delete_outline, size: 20, color: AppTheme.danger),
            SizedBox(width: 10),
            Text('حذف', style: TextStyle(color: AppTheme.danger)),
          ]),
        ),
      ],
    );
  }
}
