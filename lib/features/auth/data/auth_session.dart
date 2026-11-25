import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelay_health/features/auth/data/mappers/employee_mapper.dart';
import 'package:timelay_health/features/auth/data/models/employee_model.dart';
import 'package:timelay_health/features/auth/domain/entities/employee.dart';

class AuthSession {
  AuthSession._();

  static const _employeeKey = 'auth_employee';
  static const _fcmTokenKey = 'auth_fcm_token';
  static const _performanceShownKey = 'performance_popup_employee';
  static const _campActivatedKey = 'auth_camp_activated';
  static Employee? currentEmployee;
  static bool campActivated = false;

  static Future<void> save(Employee employee) async {
    currentEmployee = employee;
    final prefs = await SharedPreferences.getInstance();
    final model = EmployeeMapper.toModel(employee);
    await prefs.setString(_employeeKey, jsonEncode(model.toJson()));
  }

  static Future<void> saveCampActivated(bool value) async {
    campActivated = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_campActivatedKey, value);
  }

  static Future<Employee?> load() async {
    final prefs = await SharedPreferences.getInstance();
    campActivated = prefs.getBool(_campActivatedKey) ?? false;
    final raw = prefs.getString(_employeeKey);
    if (raw == null || raw.isEmpty) {
      currentEmployee = null;
      return null;
    }
    try {
      final model = EmployeeModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      final employee = EmployeeMapper.toEntity(model);
      currentEmployee = employee;
      return employee;
    } catch (_) {
      currentEmployee = null;
      return null;
    }
  }

  static Future<void> saveFcmToken(String token) async {
    final value = token.trim();
    final prefs = await SharedPreferences.getInstance();
    if (value.isEmpty) {
      await prefs.remove(_fcmTokenKey);
      return;
    }
    await prefs.setString(_fcmTokenKey, value);
  }

  static Future<String> loadFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey)?.trim() ?? '';
  }

  static Future<void> clear() async {
    currentEmployee = null;
    campActivated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_employeeKey);
    await prefs.remove(_fcmTokenKey);
    await prefs.remove(_performanceShownKey);
    await prefs.remove(_campActivatedKey);
  }

  static Future<bool> wasPerformancePopupShown(String employeeCode) async {
    if (employeeCode.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_performanceShownKey) == employeeCode;
  }

  static Future<void> markPerformancePopupShown(String employeeCode) async {
    if (employeeCode.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_performanceShownKey, employeeCode);
  }

  static bool get isLoggedIn => currentEmployee != null;
}
