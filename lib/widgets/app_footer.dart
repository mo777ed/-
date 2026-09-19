import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

/// الشريط الصغير أسفل جميع الصفحات: م / محمد الجلال
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.line, width: 0.8)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                AppConstants.developerCredit,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7A7690),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// يغلّف كل صفحات التطبيق ويضيف الشريط السفلي.
/// يُخفى الشريط أثناء ظهور لوحة المفاتيح، وبنية الشجرة ثابتة كي لا تضيع الحالة.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Column(
      children: [
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
        if (!keyboardOpen) const AppFooter(),
      ],
    );
  }
}
