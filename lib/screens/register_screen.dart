import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/digits.dart';
import '../core/utils/ui.dart';
import '../providers/session_provider.dart';
import '../widgets/brand_app_bar.dart';
import 'home_screen.dart';

/// إنشاء الحساب (الاسم + رقم الجوال) — أو تعديل البيانات من الإعدادات.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = context.read<SessionProvider>().employee;
    _name = TextEditingController(text: widget.isEdit ? e?.name ?? '' : '');
    _phone = TextEditingController(text: widget.isEdit ? e?.phone ?? '' : '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final session = context.read<SessionProvider>();
    await session.save(_name.text.trim(), _phone.text.trim());
    if (!mounted) return;
    if (widget.isEdit) {
      showAppSnack(context, 'تم حفظ بيانات الموظف');
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEdit ? const BrandAppBar(title: 'بيانات الموظف') : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.isEdit) ...[
                      Image.asset(AppConstants.logoFull,
                          height: 150, fit: BoxFit.contain),
                      const SizedBox(height: 16),
                      const Text(
                        'مرحبًا بك في المقداع',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.brand),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'أنشئ حسابك بالاسم ورقم الجوال للبدء',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6D6A80)),
                      ),
                      const SizedBox(height: 26),
                    ],
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration:
                          AppTheme.input('الاسم', icon: Icons.person_outline),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'الاسم مطلوب'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        DigitsOnlyFormatter(),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: AppTheme.input('رقم الجوال',
                          icon: Icons.phone_outlined, hint: '05xxxxxxxx'),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'رقم الجوال مطلوب';
                        if (value.length < 9) return 'رقم الجوال غير صحيح';
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        textStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      onPressed: _saving ? null : _submit,
                      child: Text(widget.isEdit ? 'حفظ' : 'إنشاء الحساب'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
