class AppTheme {
  final String id;
  final String name;
  final String primaryColor;
  final String secondaryColor;
  final String fontFamily;
  final String logoUrl;

  AppTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fontFamily,
    required this.logoUrl,
  });

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] ?? {};
    return AppTheme(
      id: json['id'],
      name: json['name'],
      primaryColor: props['primaryColor'] ?? '#2196F3',
      secondaryColor: props['secondaryColor'] ?? '#BBDEFB',
      fontFamily: props['fontFamily'] ?? 'Roboto',
      logoUrl: props['logoUrl'] ?? '',
    );
  }
}
