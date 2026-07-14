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

  // Empty constructor for temporary responses
  factory User.empty() {
    return User(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
      phoneNumber: '',
      isVerified: false,
      createdAt: DateTime.now(),
    );
  }

  // Check if user needs KYC verification
  bool get needsKycVerification {
    // If no KYC data exists, verification is needed
    if (kyc == null) return true;

    // If KYC data exists but is not verified, verification is needed
    return !kyc!.verified;
  }

  // Convenience getter for KYC verified status
  bool get kycVerified => kyc?.verified ?? false;

  // Factory constructor from JSON string
  factory User.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return User.fromMap(json);
  }

  // Factory constructor from Map
  factory User.fromMap(Map<String, dynamic> json) {
    print('DEBUG: User.fromMap - Input JSON: $json');

    // Handle both integer and string IDs from API
    final id = json['id']?.toString() ?? '';
    final firstName = json['first_name'] ?? json['firstName'] ?? '';
    final lastName = json['last_name'] ?? json['lastName'] ?? '';
    final email = json['email'] ?? '';
    final phoneNumber = json['phone_number'] ?? json['phoneNumber'] ?? '';
    final isVerified = json['is_verified'] ?? json['isVerified'] ?? false;

    print(
        'DEBUG: User.fromMap - Parsed fields: id=$id, firstName=$firstName, lastName=$lastName, email=$email');

    DateTime createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at']);
    } else if (json['createdAt'] != null) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    KycData? kyc;
    if (json['kyc'] != null) {
      try {
        print('DEBUG: User.fromMap - Found KYC data: ${json['kyc']}');
        kyc = KycData.fromMap(json['kyc']);
        print('DEBUG: User.fromMap - Parsed KYC: verified=${kyc.verified}');
      } catch (e) {
        print('DEBUG: User.fromMap - KYC parsing failed: $e');
        kyc = null;
      }
    }

    List<String>? roles;
    if (json['roles'] != null) {
      try {
        roles = (json['roles'] as List).map((role) {
          // Handle both string roles and object roles safely
          if (role is String) {
            return role;
          } else if (role is Map) {
            return (role['name'] ?? role.toString()).toString();
          } else {
            return role.toString();
          }
        }).toList();
        print('DEBUG: User.fromMap - Parsed roles: $roles');
      } catch (e) {
        print('DEBUG: User.fromMap - Roles parsing failed: $e');
        roles = null;
      }
    }

    List<String>? permissions;
    if (json['permissions'] != null) {
      try {
        permissions = (json['permissions'] as List).map((perm) {
          // Handle both string permissions and object permissions safely
          if (perm is String) {
            return perm;
          } else if (perm is Map) {
            return (perm['name'] ?? perm.toString()).toString();
          } else {
            return perm.toString();
          }
        }).toList();
        print('DEBUG: User.fromMap - Parsed permissions: $permissions');
      } catch (e) {
        print('DEBUG: User.fromMap - Permissions parsing failed: $e');
        permissions = null;
      }
    }

    final user = User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      isVerified: isVerified,
      createdAt: createdAt,
      kyc: kyc,
      roles: roles,
      permissions: permissions,
    );

    print('DEBUG: User.fromMap - Final user: $user');
    return user;
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
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email, kycVerified: $kycVerified)';
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
    try {
      print('DEBUG: KycData.fromMap - Starting with JSON: $json');

      final id = int.tryParse(json['id'].toString()) ?? 0;
      print('DEBUG: KycData.fromMap - Parsed id: $id');

      final userId = int.tryParse(json['user_id'].toString()) ?? 0;
      print('DEBUG: KycData.fromMap - Parsed userId: $userId');

      final idType = json['id_type'] ?? '';
      final dob = json['dob'] ?? '';
      final address = json['address'] ?? '';
      final city = json['city'] ?? '';
      final country = json['country'] ?? '';
      final idPhotoPath = json['id_photo_path'];
      final selfiePhotoPath = json['selfie_photo_path'];
      final verified = json['verified'] ?? false;

      print('DEBUG: KycData.fromMap - Basic fields parsed successfully');

      DateTime? verifiedAt;
      try {
        verifiedAt = json['verified_at'] != null
            ? DateTime.parse(json['verified_at'])
            : null;
        print('DEBUG: KycData.fromMap - Parsed verifiedAt: $verifiedAt');
      } catch (e) {
        print('DEBUG: KycData.fromMap - verifiedAt parsing failed: $e');
        verifiedAt = null;
      }

      DateTime createdAt;
      try {
        createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now();
        print('DEBUG: KycData.fromMap - Parsed createdAt: $createdAt');
      } catch (e) {
        print('DEBUG: KycData.fromMap - createdAt parsing failed: $e');
        createdAt = DateTime.now();
      }

      final kycData = KycData(
        id: id,
        userId: userId,
        idType: idType,
        dob: dob,
        address: address,
        city: city,
        country: country,
        idPhotoPath: idPhotoPath,
        selfiePhotoPath: selfiePhotoPath,
        verified: verified,
        verifiedAt: verifiedAt,
        createdAt: createdAt,
      );

      print('DEBUG: KycData.fromMap - KycData creation successful: $kycData');
      return kycData;
    } catch (e, stackTrace) {
      print('DEBUG: KycData.fromMap - FAILED with error: $e');
      print('DEBUG: KycData.fromMap - Stack trace: $stackTrace');
      rethrow;
    }
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
