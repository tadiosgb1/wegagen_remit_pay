import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // Test backend connection
  await testBackendConnection();
}

Future<void> testBackendConnection() async {
  final baseUrl = 'https://10.195.49.18:3001';
  
  print('Testing backend connection to: $baseUrl');
  
  // Create HTTP client that accepts self-signed certificates
  final httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  final client = http.IOClient(httpClient);
  
  try {
    // Test 1: Basic health check
    print('\n1. Testing basic connection...');
    final healthResponse = await client.get(
      Uri.parse('$baseUrl/health'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 10));
    
    print('Health check status: ${healthResponse.statusCode}');
    print('Health check response: ${healthResponse.body}');
    
    // Test 2: Generate capture context endpoint
    print('\n2. Testing capture context endpoint...');
    final captureResponse = await client.post(
      Uri.parse('$baseUrl/payments/generate-capture-context'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(Duration(seconds: 15));
    
    print('Capture context status: ${captureResponse.statusCode}');
    print('Capture context response: ${captureResponse.body}');
    
    if (captureResponse.statusCode == 200) {
      final data = json.decode(captureResponse.body);
      print('✅ Backend is responding correctly!');
      
      // Check if capture context is valid
      if (data is Map && data.containsKey('captureContext')) {
        final captureContext = data['captureContext'] as String;
        print('✅ Capture context received: ${captureContext.substring(0, 50)}...');
      } else if (data is String && data.contains('eyJ')) {
        print('✅ Capture context received as string: ${data.substring(0, 50)}...');
      } else {
        print('⚠️ Unexpected response format: $data');
      }
    } else {
      print('❌ Backend returned error: ${captureResponse.statusCode}');
      print('Error body: ${captureResponse.body}');
    }
    
  } catch (e) {
    print('❌ Connection failed: $e');
    
    if (e.toString().contains('SocketException')) {
      print('💡 Possible issues:');
      print('   - Backend server is not running');
      print('   - Wrong IP address or port');
      print('   - Firewall blocking connection');
      print('   - Network connectivity issues');
    } else if (e.toString().contains('TimeoutException')) {
      print('💡 Connection timeout - server might be slow or unreachable');
    } else if (e.toString().contains('HandshakeException')) {
      print('💡 SSL/TLS handshake failed - certificate issues');
    }
  } finally {
    client.close();
  }
}