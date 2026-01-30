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
  String? _role;
  Map<String, dynamic>? _subscription;

  User? get user => _user;
  List<Tenant> get tenants => _tenants;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get isTenantSelected => _isTenantSelected;
  String? get tenantId => _tenantId;
  String? get userId => _user?.id;
  String? get role => _role;
  Map<String, dynamic>? get subscription => _subscription;

  bool hasRole(List<String> allowedRoles) {
    return _role != null && allowedRoles.contains(_role);
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.login(email, password);
      if (token != null) {
        _token = token;
        await fetchTenants();
        await fetchMe();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("AuthProvider Login Error: $e");
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.register(email, password);
      if (token != null) {
        _token = token;
        await fetchMe();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("AuthProvider Register Error: $e");
      _isLoading = false;
      notifyListeners();
      rethrow;
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
    final data = await _authService.selectTenant(tenantId);
    if (data != null) {
      _token = data['token'];
      _role = data['role'];
      _isTenantSelected = true;
      _tenantId = tenantId;
      await fetchMe();
      await fetchSubscription();
    }
    _isLoading = false;
    notifyListeners();
    return data != null;
  }

  Future<void> fetchSubscription() async {
    _subscription = await _authService.getMySubscription();
    notifyListeners();
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
