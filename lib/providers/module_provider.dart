import 'package:flutter/material.dart';
import '../models/app_module.dart';
import '../services/module_service.dart';

class ModuleProvider with ChangeNotifier {
  final ModuleService _moduleService = ModuleService();
  List<AppModule> _modules = [];
  bool _isLoading = false;

  List<AppModule> get modules => _modules;
  List<AppModule> get enabledModules =>
      _modules.where((m) => m.enabled).toList();
  bool get isLoading => _isLoading;

  Future<void> loadModules() async {
    _isLoading = true;
    notifyListeners();
    _modules = await _moduleService.getTenantModules();
    _isLoading = false;
    notifyListeners();
  }

  bool isEnabled(String code) {
    return _modules.any((m) => m.code == code && m.enabled);
  }
}
