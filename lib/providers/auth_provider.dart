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
  String? _tenantId;

  User? get user => _user;
  List<Tenant> get tenants => _tenants;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get isTenantSelected => _isTenantSelected;
  String? get tenantId => _tenantId;
  String? get userId => _user?.id;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final token = await _authService.login(email, password);
    if (token != null) {
      _token = token;
      await fetchTenants();
      await fetchMe();
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

  Future<void> fetchMe() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> selectTenant(String tenantId) async {
    _isLoading = true;
    notifyListeners();
    final token = await _authService.selectTenant(tenantId);
    if (token != null) {
      _token = token;
      _isTenantSelected = true;
      _tenantId = tenantId;
      // Refresh user/scope if needed, though usually user ID is same.
      await fetchMe();
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
    _tenantId = null;
    notifyListeners();
  }
}
