import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../services/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  AppTheme? _currentTheme;
  ThemeData _themeData = ThemeData.light(); // Default

  AppTheme? get currentTheme => _currentTheme;
  ThemeData get themeData => _themeData;

  Future<void> loadTheme() async {
    final theme = await _themeService.getTenantTheme();
    if (theme != null) {
      _currentTheme = theme;
      _themeData = _buildThemeData(theme);
      notifyListeners();
    }
  }

  ThemeData _buildThemeData(AppTheme theme) {
    return ThemeData(
      primaryColor: _hexToColor(theme.primaryColor),
      colorScheme: ColorScheme.fromSeed(
        seedColor: _hexToColor(theme.primaryColor),
      ),
      useMaterial3: true,
      fontFamily:
          'Roboto', // For now, assume default or bundled font. Loading GoogleFonts specific might need more work.
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
