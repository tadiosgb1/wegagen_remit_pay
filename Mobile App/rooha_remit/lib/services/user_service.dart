import '../services/api_service.dart';
import '../config/url_container.dart';

class UserService {
  final ApiService _apiService = ApiService();

  /// Get current user profile information from /users/me
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.get(UrlContainer.profile);

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response['message'] ?? 'Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  /// Update user profile information using PATCH /users/me
  Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? dateOfBirth,
  }) async {
    try {
      // Build update data - only include fields that are provided
      final updateData = <String, dynamic>{};
      
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (city != null) updateData['city'] = city;
      if (country != null) updateData['country'] = country;
      if (dateOfBirth != null) updateData['dateOfBirth'] = dateOfBirth;

      final response = await _apiService.patch(
        UrlContainer.profile, // Use /users/me endpoint
        updateData,
      );

      if (response['status'] == 'success') {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Change user password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.patch(
        UrlContainer.changePassword,
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response['status'] == 'success') {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}