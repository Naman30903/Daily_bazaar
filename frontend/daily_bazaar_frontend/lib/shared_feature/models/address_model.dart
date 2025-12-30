class UserAddress {
  const UserAddress({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.pincode,
    this.label,
    this.isDefault = false,
    this.addressLine2,
    this.landmark,
    this.district,
    this.countryCode = 'IN',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String? label;
  final bool isDefault;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String? district;
  final String state;
  final String pincode;
  final String countryCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      label: json['label']?.toString(),
      isDefault: json['is_default'] == true,
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      addressLine1: json['address_line1']?.toString() ?? '',
      addressLine2: json['address_line2']?.toString(),
      landmark: json['landmark']?.toString(),
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString(),
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? 'IN',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    if (label != null) 'label': label,
    'is_default': isDefault,
    'full_name': fullName,
    'phone': phone,
    'address_line1': addressLine1,
    if (addressLine2 != null) 'address_line2': addressLine2,
    if (landmark != null) 'landmark': landmark,
    'city': city,
    if (district != null) 'district': district,
    'state': state,
    'pincode': pincode,
    'country_code': countryCode,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2?.isNotEmpty ?? false) addressLine2,
      if (landmark?.isNotEmpty ?? false) landmark,
      city,
      if (district?.isNotEmpty ?? false) district,
      state,
      pincode,
    ];
    return parts.join(', ');
  }
}

class CreateAddressRequest {
  const CreateAddressRequest({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.pincode,
    this.label,
    this.isDefault = false,
    this.addressLine2,
    this.landmark,
    this.district,
  });

  final String? label;
  final bool isDefault;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String? district;
  final String state;
  final String pincode;

  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    'is_default': isDefault,
    'full_name': fullName,
    'phone': phone,
    'address_line1': addressLine1,
    if (addressLine2 != null) 'address_line2': addressLine2,
    if (landmark != null) 'landmark': landmark,
    'city': city,
    if (district != null) 'district': district,
    'state': state,
    'pincode': pincode,
  };
}
