import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

import '../config/url_container.dart';
import '../models/kyc_data.dart';
import 'api_service.dart';

class KycService {
  static final KycService _instance = KycService._internal();
  factory KycService() => _instance;
  KycService._internal();

  final ApiService _api = ApiService();

  /// SUBMIT KYC
  Future<KycSubmissionResponse> submitKyc(KycData data) async {
    try {
      if (!data.isComplete) {
        return KycSubmissionResponse(
          success: false,
          message: 'Missing fields: ${data.missingFields.join(", ")}',
          status: KycStatus.notStarted,
        );
      }

      if (!_api.isInitialized) {
        await _api.initialize();
      }

      final formData = FormData();

      /// TEXT FIELDS
      data.toFormData().forEach((k, v) {
        formData.fields.add(MapEntry(k, v.toString()));
      });

      /// FILES
      final idFile = await data.getIdPhotoFile();
      final selfieFile = await data.getSelfieFile();

      if (idFile != null && await idFile.exists()) {
        formData.files.add(
          MapEntry(
            'id_photo',
            await MultipartFile.fromFile(
              idFile.path,
              filename: 'id.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      if (selfieFile != null && await selfieFile.exists()) {
        formData.files.add(
          MapEntry(
            'selfie',
            await MultipartFile.fromFile(
              selfieFile.path,
              filename: 'selfie.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      if (kDebugMode) {
        print('📤 KYC submit → ${formData.files.length} files');
      }

      final res = await _api.postFormData(
        UrlContainer.submitKyc,
        formData,
      );

      return KycSubmissionResponse.fromJson(res);
    } catch (e) {
      return KycSubmissionResponse(
        success: false,
        message: _message(e),
        status: KycStatus.notStarted,
      );
    }
  }

  /// STATUS CHECK
  Future<KycStatus> getKycStatus({bool forceRefresh = true}) async {
    try {
      if (!_api.isInitialized) {
        await _api.initialize();
      }

      // Add a 'no-cache' header to ensure we get the latest DB status
      final options = Options(
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );

      // Get fresh user data from /users/me endpoint
      final res = await _api.dio.get(
        UrlContainer.profile, // This calls /users/me
        options: forceRefresh ? options : null,
      );

      final userData = res.data;
      
      if (kDebugMode) {
        print('🔍 KYC Service - Raw response: $userData');
      }

      // The response has structure: {status: "success", data: {user data}}
      final actualUserData = userData['data'] ?? userData;
      final kyc = actualUserData['kyc'];

      if (kDebugMode) {
        print('🔍 KYC Service - Actual user data: $actualUserData');
        print('🔍 KYC Service - KYC data: $kyc');
      }

      if (kyc == null) return KycStatus.notStarted;
      
      // Check verified status first
      if (kyc['verified'] == true) {
        if (kDebugMode) {
          print('✅ KYC Service - Status: APPROVED (verified=true)');
        }
        return KycStatus.approved;
      }

      // Check for pending/under review - if documents uploaded but not verified
      if ((kyc['id_photo_path'] ?? '').toString().isNotEmpty ||
          (kyc['selfie_photo_path'] ?? '').toString().isNotEmpty) {
        if (kDebugMode) {
          print('⏳ KYC Service - Status: UNDER_REVIEW (documents uploaded)');
        }
        return KycStatus.underReview;
      }

      if (kDebugMode) {
        print('❌ KYC Service - Status: NOT_STARTED');
      }
      return KycStatus.notStarted;
    } catch (e) {
      if (kDebugMode) {
        print('❌ KYC Status check error: $e');
      }
      return KycStatus.notStarted;
    }
  }

  /// SINGLE FILE UPLOAD
  Future<Map<String, dynamic>> uploadDocument(
    File file,
    String type,
  ) async {
    return _api.uploadFile(
      UrlContainer.kycDocuments,
      file,
      fieldName: type,
      additionalFields: {'document_type': type},
    );
  }

  /// ERROR HANDLING
  String _message(dynamic e) {
    if (e is ApiException) return e.message;
    if (e is DioException) {
      return e.response?.data?['message'] ?? e.message ?? 'Network error';
    }
    return 'KYC submission failed';
  }
}
