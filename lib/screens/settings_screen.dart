import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/branch_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/brand_app_bar.dart';
import 'branches_screen.dart';
import 'register_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employee = context.watch<SessionProvider>().employee;
    final branchCount = context.watch<BranchProvider>().branches.length;

    return Scaffold(
      appBar: const BrandAppBar(title: 'الإعدادات'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            icon: Icons.person_outline,
            title: 'بيانات الموظف',
            subtitle: employee == null
                ? null
                : '${employee.name} • ${employee.phone}',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => const RegisterScreen(isEdit: true)),
            ),
          ),
          const SizedBox(height: 10),
          _tile(
            icon: Icons.store_outlined,
            title: 'إدارة الفروع',
            subtitle: '$branchCount فروع',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BranchesScreen()),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Image.asset(AppConstants.logoMark, height: 64),
                const SizedBox(height: 8),
                const Text(AppConstants.appName,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Text('الإصدار 1.0.0',
                    style: TextStyle(color: Color(0xFF6D6A80), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.brandSoft,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: AppTheme.brand),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
        onTap: onTap,
      ),
    );
  }
}
