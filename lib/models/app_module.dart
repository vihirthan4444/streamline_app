class AppModule {
  final String code;
  final String name;
  final bool enabled;

  AppModule({required this.code, required this.name, required this.enabled});

  factory AppModule.fromJson(Map<String, dynamic> json) {
    return AppModule(
      code: json['code'],
      name: json['name'],
      enabled: json['enabled'],
    );
  }
}
