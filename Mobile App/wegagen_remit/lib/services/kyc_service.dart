import 'dart:io';
import '../config/url_container.dart';
import '../models/kyc_data.dart';
import 'api_service.dart';

class KycService {
  static final KycService _instance = KycService._internal();
  factory KycService() => _instance;
  KycService._internal();

  final ApiService _apiService = ApiService();

  // Submit KYC data
  Future<KycSubmissionResponse> submitKyc(KycData kycData) async {
    try {
      // Prepare form data
      final formData = kycData.toFormData();

      // Upload ID photo
      if (kycData.idPhoto != null) {
        final idPhotoResponse = await _apiService.uploadFile(
          UrlContainer.kycDocuments,
          kycData.idPhoto!,
          fieldName: 'id_photo',
          additionalFields: formData,
        );

        // If ID photo upload successful, upload selfie
        if (kycData.selfie != null) {
          await _apiService.uploadFile(
            UrlContainer.kycDocuments,
            kycData.selfie!,
            fieldName: 'selfie',
            additionalFields: {'document_id': idPhotoResponse['id'].toString()},
          );
        }
      } else {
        // Submit without files (if allowed by backend)
        await _apiService.post(UrlContainer.submitKyc, formData);
      }

      return KycSubmissionResponse(
        success: true,
        message:
            'KYC submitted successfully. We will review your documents within 24-48 hours.',
        status: KycStatus.underReview,
      );
    } catch (e) {
      return KycSubmissionResponse(
        success: false,
        message: _getErrorMessage(e),
        status: KycStatus.notStarted,
      );
    }
  }

  // Get KYC status
  Future<KycStatus> getKycStatus() async {
    try {
      final response = await _apiService.get(UrlContainer.kycStatus);
      return _parseKycStatus(response['status']);
    } catch (e) {
      return KycStatus.notStarted;
    }
  }

  // Parse KYC status from string
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

  // Upload document
  Future<Map<String, dynamic>> uploadDocument(
    File file,
    String documentType,
  ) async {
    try {
      return await _apiService.uploadFile(
        UrlContainer.kycDocuments,
        file,
        fieldName: documentType,
        additionalFields: {'document_type': documentType},
      );
    } catch (e) {
      throw KycException(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to submit KYC. Please try again.';
  }
}

class KycException implements Exception {
  final String message;

  KycException(this.message);

  @override
  String toString() => 'KycException: $message';
}
