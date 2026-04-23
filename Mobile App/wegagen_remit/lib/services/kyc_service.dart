import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
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
      // Use multipart form data for the single KYC endpoint
      final uri = Uri.parse(UrlContainer.submitKyc);
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers (get auth headers from API service)
      final headers = await _getAuthHeaders(isMultipart: true);
      request.headers.addAll(headers);
      
      // Add form fields
      final formData = kycData.toFormData();
      request.fields.addAll(formData);
      
      print('Adding form fields: ${request.fields}');
      
      // Debug: Print file information before adding
      if (kycData.idPhoto != null) {
        print('ID Photo - Name: ${kycData.idPhoto!.name}, Path: ${kycData.idPhoto!.path}');
      }
      if (kycData.selfie != null) {
        print('Selfie - Name: ${kycData.selfie!.name}, Path: ${kycData.selfie!.path}');
      }
      
      // Add ID photo if available
      if (kycData.idPhoto != null) {
        try {
          // Use XFile.readAsBytes() which works on both web and mobile
          final bytes = await kycData.idPhoto!.readAsBytes();
          if (bytes.isNotEmpty) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'id_photo',
                bytes,
                filename: 'id_document.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            );
            print('Added ID photo as bytes (${bytes.length} bytes) with filename: id_document.jpg');
          }
        } catch (e) {
          print('Error adding ID photo: $e');
          // Continue without the file rather than failing completely
        }
      }
      
      // Add selfie if available
      if (kycData.selfie != null) {
        try {
          // Use XFile.readAsBytes() which works on both web and mobile
          final bytes = await kycData.selfie!.readAsBytes();
          if (bytes.isNotEmpty) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'selfie',
                bytes,
                filename: 'selfie_photo.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            );
            print('Added selfie as bytes (${bytes.length} bytes) with filename: selfie_photo.jpg');
          }
        } catch (e) {
          print('Error adding selfie: $e');
          // Continue without the file rather than failing completely
        }
      }

      print('Total files to upload: ${request.files.length}');
      
      // Debug: Print all request details
      print('Request URL: ${request.url}');
      print('Request headers: ${request.headers}');
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.map((f) => '${f.field}: ${f.filename} (${f.length} bytes)').join(', ')}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return KycSubmissionResponse(
          success: true,
          message: 'KYC submitted successfully. We will review your documents within 24-48 hours.',
          status: KycStatus.underReview,
        );
      } else {
        String errorMessage = 'Failed to submit KYC';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use default message
        }
        
        return KycSubmissionResponse(
          success: false,
          message: errorMessage,
          status: KycStatus.notStarted,
        );
      }
    } catch (e) {
      print('KYC submission error: $e');
      return KycSubmissionResponse(
        success: false,
        message: _getErrorMessage(e),
        status: KycStatus.notStarted,
      );
    }
  }

  // Get auth headers for multipart requests
  Future<Map<String, String>> _getAuthHeaders({bool isMultipart = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    // Don't set Content-Type for multipart requests - let http package handle it
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
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
