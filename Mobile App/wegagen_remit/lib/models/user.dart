import 'dart:convert';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final bool isVerified;
  final DateTime createdAt;
  final KycData? kyc;
  final List<String>? roles;
  final List<String>? permissions;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.isVerified = false,
    required this.createdAt,
    this.kyc,
    this.roles,
    this.permissions,
  });

  // Check if user needs KYC verification
  bool get needsKycVerification {
    return kyc == null || (kyc != null && !kyc!.verified);
  }

  // Factory constructor from JSON string
  factory User.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return User.fromMap(json);
  }

  // Factory constructor from Map
  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      kyc: json['kyc'] != null ? KycData.fromMap(json['kyc']) : null,
      roles: json['roles'] != null 
          ? (json['roles'] as List).map((role) => role['name']?.toString() ?? '').toList()
          : null,
      permissions: json['permissions'] != null
          ? (json['permissions'] as List).map((perm) => perm.toString()).toList()
          : null,
    );
  }

  // Convert to JSON string
  String toJson() {
    return jsonEncode(toMap());
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      if (kyc != null) 'kyc': kyc!.toMap(),
      if (roles != null) 'roles': roles!.map((role) => {'name': role}).toList(),
      if (permissions != null) 'permissions': permissions,
    };
  }

  // Get full name
  String get fullName => '$firstName $lastName';

  // Copy with method
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    bool? isVerified,
    DateTime? createdAt,
    KycData? kyc,
    List<String>? roles,
    List<String>? permissions,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      kyc: kyc ?? this.kyc,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email, kycVerified: ${kyc?.verified ?? false})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class KycData {
  final int id;
  final int userId;
  final String idType;
  final String dob;
  final String address;
  final String city;
  final String country;
  final String? idPhotoPath;
  final String? selfiePhotoPath;
  final bool verified;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  KycData({
    required this.id,
    required this.userId,
    required this.idType,
    required this.dob,
    required this.address,
    required this.city,
    required this.country,
    this.idPhotoPath,
    this.selfiePhotoPath,
    required this.verified,
    this.verifiedAt,
    required this.createdAt,
  });

  factory KycData.fromMap(Map<String, dynamic> json) {
    return KycData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      idType: json['id_type'] ?? '',
      dob: json['dob'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      idPhotoPath: json['id_photo_path'],
      selfiePhotoPath: json['selfie_photo_path'],
      verified: json['verified'] ?? false,
      verifiedAt: json['verified_at'] != null ? DateTime.parse(json['verified_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'id_type': idType,
      'dob': dob,
      'address': address,
      'city': city,
      'country': country,
      'id_photo_path': idPhotoPath,
      'selfie_photo_path': selfiePhotoPath,
      'verified': verified,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}