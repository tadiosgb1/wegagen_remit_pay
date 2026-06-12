import 'package:image_picker/image_picker.dart';
import 'dart:io';

class KycData {
  final String idType;
  final String dob;
  final String address;
  final String city;
  final String country;
  final XFile? idPhoto;
  final XFile? selfie;

  KycData({
    required this.idType,
    required this.dob,
    required this.address,
    required this.city,
    required this.country,
    this.idPhoto,
    this.selfie,
  });

  // Convert to regular form data (without files)
  Map<String, String> toFormData() {
    return {
      'id_type': idType,
      'dob': dob,
      'address': address,
      'city': city,
      'country': country,
    };
  }

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'id_type': idType,
      'dob': dob,
      'address': address,
      'city': city,
      'country': country,
    };
  }

  // Helper method to get files as File objects
  Future<File?> getIdPhotoFile() async {
    if (idPhoto == null) return null;
    return File(idPhoto!.path);
  }

  Future<File?> getSelfieFile() async {
    if (selfie == null) return null;
    return File(selfie!.path);
  }

  // Check if all required fields are filled
  bool get isComplete {
    return idType.isNotEmpty &&
        dob.isNotEmpty &&
        address.isNotEmpty &&
        city.isNotEmpty &&
        country.isNotEmpty &&
        idPhoto != null &&
        selfie != null;
  }

  // Get missing fields for validation
  List<String> get missingFields {
    final missing = <String>[];
    if (idType.isEmpty) missing.add('ID Type');
    if (dob.isEmpty) missing.add('Date of Birth');
    if (address.isEmpty) missing.add('Address');
    if (city.isEmpty) missing.add('City');
    if (country.isEmpty) missing.add('Country');
    if (idPhoto == null) missing.add('ID Photo');
    if (selfie == null) missing.add('Selfie Photo');
    return missing;
  }
}

enum KycStatus {
  notStarted,
  inProgress,
  underReview,
  approved,
  rejected,
}

class KycSubmissionResponse {
  final bool success;
  final String message;
  final KycStatus status;

  KycSubmissionResponse({
    required this.success,
    required this.message,
    required this.status,
  });

  factory KycSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return KycSubmissionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: _parseKycStatus(json['status']),
    );
  }

  static KycStatus _parseKycStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return KycStatus.approved;
      case 'rejected':
        return KycStatus.rejected;
      case 'under_review':
      case 'pending':
        return KycStatus.underReview;
      case 'in_progress':
        return KycStatus.inProgress;
      default:
        return KycStatus.notStarted;
    }
  }
}

enum LivenessAction {
  blinkEyes,
  turnLeft,
  turnRight,
  smile,
  openMouth,
}

class LivenessChallenge {
  final LivenessAction action;
  final String instruction;
  final Duration timeout;

  LivenessChallenge({
    required this.action,
    required this.instruction,
    this.timeout = const Duration(seconds: 5),
  });

  static List<LivenessChallenge> getRandomChallenges() {
    final challenges = [
      LivenessChallenge(
        action: LivenessAction.blinkEyes,
        instruction: 'Please blink your eyes',
      ),
      LivenessChallenge(
        action: LivenessAction.turnLeft,
        instruction: 'Turn your head to the left',
      ),
      LivenessChallenge(
        action: LivenessAction.turnRight,
        instruction: 'Turn your head to the right',
      ),
      LivenessChallenge(
        action: LivenessAction.smile,
        instruction: 'Please smile',
      ),
      LivenessChallenge(
        action: LivenessAction.openMouth,
        instruction: 'Open your mouth',
      ),
    ];

    challenges.shuffle();
    return challenges.take(3).toList(); // Return 3 random challenges
  }
}
