import 'package:image_picker/image_picker.dart';

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

  Map<String, String> toFormData() {
    return {
      'id_type': idType,
      'dob': dob,
      'address': address,
      'city': city,
      'country': country,
    };
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