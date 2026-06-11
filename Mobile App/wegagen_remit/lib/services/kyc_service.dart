import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../config/environment.dart';
import '../config/url_container.dart';
import '../models/kyc_data.dart';
import 'api_service.dart';

class KycService {
  static final KycService _instance = KycService._internal();
  factory KycService() => _instance;
  KycService._internal();

  final ApiService _apiService = ApiService();

  // Submit KYC data using Dio
  Future<KycSubmissionResponse> submitKyc(KycData kycData) async {
    try {
      // Create FormData for multipart upload
      final formData = FormData();
      
      // Add form fields
      final fields = kycData.toFormData();
      for (final entry in fields.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value));
      }
      
      if (kDebugMode) print('Adding form fields: $fields');
      
      // Debug: Print file information before adding
      if (kycData.idPhoto != null) {
        if (kDebugMode) print('ID Photo - Path: ${kycData.idPhoto!.path}');
      }
      if (kycData.selfie != null) {
        if (kDebugMode) print('Selfie - Path: ${kycData.selfie!.path}');
      }
      
      // Add ID photo if available
      if (kycData.idPhoto != null) {
        try {
          final bytes = await kycData.idPhoto!.readAsBytes();
          if (bytes.isNotEmpty) {
            formData.files.add(MapEntry(
              'id_photo',
              MultipartFile.fromBytes(
                bytes,
                filename: 'id_document.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            ));
            if (kDebugMode) print('Added ID photo as bytes (${bytes.length} bytes) with filename: id_document.jpg');
          }
        } catch (e) {
          if (kDebugMode) print('Error adding ID photo: $e');
        }
      }
      
      // Add selfie if available
      if (kycData.selfie != null) {
        try {
          final bytes = await kycData.selfie!.readAsBytes();
          if (bytes.isNotEmpty) {
            formData.files.add(MapEntry(
              'selfie',
              MultipartFile.fromBytes(
                bytes,
                filename: 'selfie_photo.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            ));
            if (kDebugMode) print('Added selfie as bytes (${bytes.length} bytes) with filename: selfie_photo.jpg');
          }
        } catch (e) {
          if (kDebugMode) print('Error adding selfie: $e');
        }
      }

      if (kDebugMode) print('Total files to upload: ${formData.files.length}');
      
      // Use ApiService to submit
      final response = await _apiService.post(UrlContainer.submitKyc, formData.fields.asMap().map((key, value) => MapEntry(value.key, value.value)));
      
      if (kDebugMode) {
        print('Response: $response');
      }
      
      return KycSubmissionResponse(
        success: true,
        message: 'KYC submitted successfully. We will review your documents within 24-48 hours.',
        status: KycStatus.underReview,
      );
    } catch (e) {
      if (kDebugMode) print('KYC submission error: $e');
      return KycSubmissionResponse(
        success: false,
        message: _getErrorMessage(e),
        status: KycStatus.notStarted,
      );
    }
  }

  // Get auth headers for multipart requests (not needed with new implementation)
  Future<Map<String, String>> _getAuthHeaders({bool isMultipart = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  // Get KYC status from user profile
  Future<KycStatus> getKycStatus() async {
    try {
      // Ensure ApiService is initialized
      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }
      
      // Get user profile which includes KYC data
      final response = await _apiService.get(UrlContainer.profile);
      
      if (kDebugMode) print('KYC Status Check - Profile response: $response');
      
      // Check if user has KYC data
      final userData = response['user'] ?? response['data']?['user'];
      if (userData != null && userData['kyc'] != null) {
        final kycData = userData['kyc'];
        
        if (kDebugMode) print('KYC Data found: $kycData');
        
        // Check if KYC is verified
        if (kycData['verified'] == true) {
          if (kDebugMode) print('✅ KYC is VERIFIED');
          return KycStatus.approved;
        } else if (kycData['id_photo_path'] != null || kycData['selfie_photo_path'] != null) {
          // Has uploaded documents but not verified yet
          if (kDebugMode) print('📋 KYC documents uploaded, under review');
          return KycStatus.underReview;
        } else {
          // No documents uploaded
          if (kDebugMode) print('📝 KYC not started - no documents');
          return KycStatus.notStarted;
        }
      } else {
        // No KYC data at all
        if (kDebugMode) print('❌ No KYC data found in user profile');
        return KycStatus.notStarted;
      }
    } catch (e) {
      if (kDebugMode) print('Error getting KYC status: $e');
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
