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
  Future<KycStatus> getKycStatus() async {
    try {
      if (!_api.isInitialized) {
        await _api.initialize();
      }

      final res = await _api.get(UrlContainer.profile);

      final user = res['user'] ?? res['data']?['user'];
      final kyc = user?['kyc'];

      if (kyc == null) return KycStatus.notStarted;

      if (kyc['verified'] == true) {
        return KycStatus.approved;
      }

      if ((kyc['id_photo_path'] ?? '').toString().isNotEmpty ||
          (kyc['selfie_photo_path'] ?? '').toString().isNotEmpty) {
        return KycStatus.underReview;
      }

      return KycStatus.notStarted;
    } catch (_) {
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