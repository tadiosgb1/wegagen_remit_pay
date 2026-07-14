import '../services/api_service.dart';
import '../config/url_container.dart';
import '../models/transfer.dart';

class TransactionsService {
  final ApiService _apiService = ApiService();

  Future<List<Transfer>> getUserTransactions({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (status != null && status != 'All') {
        queryParams['status'] = status.toLowerCase();
      }
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }
      if (offset != null) {
        queryParams['offset'] = offset.toString();
      }

      final response = await _apiService.get(
        UrlContainer.getUserTransactions,
        queryParams: queryParams,
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final transactionsData = response['data'] as List<dynamic>;
        return transactionsData
            .map((json) => Transfer.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<Transfer> getTransactionById(String id) async {
    try {
      final response = await _apiService.get(UrlContainer.getTransferById(id));

      if (response['status'] == 'success' && response['data'] != null) {
        return Transfer.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response['message'] ?? 'Failed to load transaction');
      }
    } catch (e) {
      throw Exception('Failed to load transaction: $e');
    }
  }
}