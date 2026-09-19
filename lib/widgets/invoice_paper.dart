import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/fmt.dart';
import '../models/transfer.dart';
import 'items_table.dart';

/// عرض الفاتورة داخل التطبيق (نفس محتوى ملف PDF).
class InvoicePaper extends StatelessWidget {
  const InvoicePaper({super.key, required this.transfer});

  final Transfer transfer;

  @override
  Widget build(BuildContext context) {
    final t = transfer;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(t),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.brand, thickness: 1.5, height: 1),
          const SizedBox(height: 12),
          _infoRow(
            _InfoCell(label: 'رقم التحويل', value: t.number, ltr: true),
            _InfoCell(label: 'التاريخ', value: Fmt.date(t.date), ltr: true),
          ),
          const SizedBox(height: 8),
          _infoRow(
            _InfoCell(label: 'من فرع', value: t.fromBranch),
            _InfoCell(label: 'إلى فرع', value: t.toBranch),
          ),
          const SizedBox(height: 8),
          _infoRow(
            _InfoCell(label: 'مسؤول التحويل', value: t.employeeName),
            _InfoCell(
                label: 'جوال المسؤول', value: t.employeePhone, ltr: true),
          ),
          const SizedBox(height: 14),
          ItemsTable(items: t.items),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي عدد الأصناف: ${t.items.length}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'إجمالي الكميات: ${t.totalQuantity}',
                  style: const TextStyle(fontSize: 13.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(child: _signature('توقيع مسؤول التحويل')),
              const SizedBox(width: 18),
              Expanded(child: _signature('توقيع المستلم')),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _header(Transfer t) {
    return Row(
      children: [
        Image.asset(
          AppConstants.logoFull,
          height: 92,
          fit: BoxFit.contain,
          semanticLabel: AppConstants.appName,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.appName,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brand),
              ),
              const Text(
                AppConstants.invoiceTitle,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brand),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('رقم التحويل: ',
                      style: TextStyle(color: Color(0xFF6D6A80), fontSize: 13)),
                  Text(
                    t.number,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(Widget a, Widget b) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 8),
          Expanded(child: b),
        ],
      );

  Widget _signature(String label) => Column(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 30),
          Container(height: 1, color: const Color(0xFF9A96AD)),
        ],
      );
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.brandSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF6D6A80))),
          const SizedBox(height: 2),
          Text(
            value,
            textDirection: ltr ? TextDirection.ltr : null,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
