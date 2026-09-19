import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/session_provider.dart';
import '../providers/transfers_provider.dart';
import '../widgets/brand_app_bar.dart';
import 'create_transfer_screen.dart';
import 'settings_screen.dart';
import 'transfers_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employee = context.watch<SessionProvider>().employee;
    final count = context.watch<TransfersProvider>().transfers.length;

    return Scaffold(
      appBar: BrandAppBar(
        title: AppConstants.appName,
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(AppConstants.logoFull,
                      height: 150, fit: BoxFit.contain),
                  const SizedBox(height: 14),
                  Text(
                    employee == null ? 'مرحبًا' : 'مرحبًا، ${employee.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brand),
                  ),
                  const SizedBox(height: 26),
                  _ActionCard(
                    primary: true,
                    icon: Icons.local_shipping_outlined,
                    title: 'تحويل بضاعة',
                    subtitle: 'أنشئ فاتورة تحويل جديدة بين الفروع',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const CreateTransferScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'التحويلات السابقة',
                    subtitle: count == 0
                        ? 'لا توجد تحويلات محفوظة بعد'
                        : '$count تحويل محفوظ',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const TransfersListScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? Colors.white : AppTheme.brand;
    final bg = primary ? AppTheme.brand : AppTheme.brandSoft;
    final radius = BorderRadius.circular(20);
    return Material(
      color: bg,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primary ? Colors.white.withAlpha(38) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: fg),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: fg)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(fontSize: 13, color: fg.withAlpha(200))),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios_new, size: 18, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}
