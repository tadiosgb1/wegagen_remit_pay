import '../services/api_service.dart';
import '../config/url_container.dart';

class PinService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    try {
      final response = await _apiService.patch(
        UrlContainer.changePin,
        {
          'oldPin': oldPin,
          'newPin': newPin,
        },
      );

      if (response['status'] == 'success') {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to change PIN');
      }
    } catch (e) {
      throw Exception('Failed to change PIN: $e');
    }
  }
}