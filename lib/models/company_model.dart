class CompanyModel {
  final String id;
  final String name;
  final String code;
  final String ownerName;
  final String email;
  final String phone;
  final String? address;
  final String status;
  final String? plan;
  final DateTime? createdAt;

  const CompanyModel({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerName,
    required this.email,
    required this.phone,
    this.address,
    required this.status,
    this.plan,
    this.createdAt,
  });

  // Schema columns: company_name, company_code, owner_name, email, phone
  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id: json['id']?.toString() ?? '',
        name: json['company_name'] ?? json['name'] ?? '',
        code: json['company_code'] ?? json['code'] ?? '',
        ownerName: json['owner_name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        address: json['address']?.toString(),
        status: json['status'] ?? 'active',
        plan: json['plan'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_name': name,
        'company_code': code,
        'owner_name': ownerName,
        'email': email,
        'phone': phone,
        'address': address,
        'status': status,
        'plan': plan,
      };
}
