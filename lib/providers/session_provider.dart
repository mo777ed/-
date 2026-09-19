import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/employee.dart';

/// بيانات الموظف المسجّل (تُحفظ محليًا).
class SessionProvider extends ChangeNotifier {
  static const String _kName = 'employee_name';
  static const String _kPhone = 'employee_phone';

  Employee? _employee;
  Employee? get employee => _employee;
  bool get isRegistered => _employee != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kName);
    final phone = prefs.getString(_kPhone);
    if (name != null && name.isNotEmpty && phone != null && phone.isNotEmpty) {
      _employee = Employee(name: name, phone: phone);
    }
    notifyListeners();
  }

  Future<void> save(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, name);
    await prefs.setString(_kPhone, phone);
    _employee = Employee(name: name, phone: phone);
    notifyListeners();
  }
}
