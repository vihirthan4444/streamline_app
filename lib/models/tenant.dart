class Tenant {
  final String id;
  final String name;
  final String businessType;

  Tenant({required this.id, required this.name, required this.businessType});

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      businessType: json['business_type'],
    );
  }
}
