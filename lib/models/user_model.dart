class UserModel {
  final String id;
  final String companyId;
  final String name;
  final String phone;
  final String role;
  final String status;
  final String? email;
  final String? street;
  final String? city;
  final String? state;
  final String? pincode;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.phone,
    required this.role,
    required this.status,
    this.email,
    this.street,
    this.city,
    this.state,
    this.pincode,
    this.createdAt,
  });

  bool get isActive => status == 'active';

  // Schema columns: full_name, phone_number, address (JSON), role, status
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // address may be a nested JSON object from DB
    final address = json['address'];
    Map<String, dynamic>? addr;
    if (address is Map<String, dynamic>) {
      addr = address;
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      phone: json['phone_number'] ?? json['phone'] ?? '',
      role: json['role'] ?? 'member',
      status: json['status'] ?? 'active',
      email: json['email'],
      street: addr?['street'] ?? json['street'],
      city: addr?['city'] ?? json['city'],
      state: addr?['state'] ?? json['state'],
      pincode: addr?['pincode'] ?? json['pincode'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  // Schema expects: full_name, phone_number, address as JSON object
  Map<String, dynamic> toJson() => {
        'company_id': companyId,
        'full_name': name,
        'phone_number': phone,
        'role': role,
        'status': status,
        if (street != null || city != null || state != null || pincode != null)
          'address': {
            if (street != null) 'street': street,
            if (city != null) 'city': city,
            if (state != null) 'state': state,
            if (pincode != null) 'pincode': pincode,
          },
      };
}
