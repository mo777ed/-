import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/fmt.dart';
import '../models/transfer.dart';
import '../providers/transfers_provider.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/empty_state.dart';
import 'invoice_screen.dart';

class TransfersListScreen extends StatelessWidget {
  const TransfersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransfersProvider>();
    final transfers = provider.transfers;

    Widget body;
    if (provider.loading && transfers.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (transfers.isEmpty) {
      body = const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'لا توجد تحويلات بعد',
        message: 'ستظهر هنا جميع التحويلات التي تقوم بحفظها.',
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: transfers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _TransferCard(transfer: transfers[i]),
      );
    }

    return Scaffold(
      appBar: const BrandAppBar(title: 'التحويلات'),
      body: body,
    );
  }
}

class _TransferCard extends StatelessWidget {
  const _TransferCard({required this.transfer});

  final Transfer transfer;

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InvoiceScreen(transferId: transfer.id!),
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text('$label: ',
                style:
                    const TextStyle(color: Color(0xFF6D6A80), fontSize: 13.5)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14.5)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = transfer;
    final radius = BorderRadius.circular(16);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => _open(context),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppTheme.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.brandSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.number,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brand),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _line('تحويل من', t.fromBranch),
              _line('إلى', t.toBranch),
              _line('التاريخ', Fmt.date(t.date)),
              _line('مسؤول التحويل', t.employeeName),
              _line('عدد الأصناف', '${t.itemsCount}'),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () => _open(context),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('عرض التفاصيل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
