import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/tenant.dart';
import '../core/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  List<Tenant> _tenants = [];
  bool _isLoading = false;
  String? _token;
  bool _isTenantSelected = false;

  User? get user => _user;
  List<Tenant> get tenants => _tenants;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get isTenantSelected => _isTenantSelected;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final token = await _authService.login(email, password);
    if (token != null) {
      _token = token;
      await fetchTenants();
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchTenants() async {
    _tenants = await _authService.getMyTenants();
    notifyListeners();
  }

  Future<bool> selectTenant(String tenantId) async {
    _isLoading = true;
    notifyListeners();
    final token = await _authService.selectTenant(tenantId);
    if (token != null) {
      _token = token;
      _isTenantSelected = true;
    }
    _isLoading = false;
    notifyListeners();
    return token != null;
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _user = null;
    _tenants = [];
    _isTenantSelected = false;
    notifyListeners();
  }
}
