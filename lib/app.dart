import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/session_provider.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/app_footer.dart';

class AlmegdaaApp extends StatelessWidget {
  const AlmegdaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // نقرأ الحالة مرة واحدة؛ التنقل بعد التسجيل يتم صراحةً من شاشة التسجيل.
    final registered = context.read<SessionProvider>().isRegistered;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          AppShell(child: child ?? const SizedBox.shrink()),
      home: registered ? const HomeScreen() : const RegisterScreen(),
    );
  }
}
