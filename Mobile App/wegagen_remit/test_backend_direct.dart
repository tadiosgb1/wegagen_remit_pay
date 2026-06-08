import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:convert';

void main() async {
  print('🧪 Testing direct backend connection...');
  
  // Create HTTP client that accepts self-signed certificates
  final httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  final client = IOClient(httpClient);
  
  final baseUrl = 'https://10.195.49.18:3001';
  
  try {
    // Test 1: Health check
    print('\n1. Testing health endpoint...');
    try {
      final healthResponse = await client.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      print('✅ Health check - Status: ${healthResponse.statusCode}');
      print('   Response: ${healthResponse.body}');
    } catch (e) {
      print('❌ Health check failed: $e');
    }
    
    // Test 2: Generate capture context
    print('\n2. Testing capture context endpoint...');
    try {
      final captureResponse = await client.post(
        Uri.parse('$baseUrl/payments/generate-capture-context'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({}),
      ).timeout(Duration(seconds: 15));
      
      print('✅ Capture context - Status: ${captureResponse.statusCode}');
      
      if (captureResponse.statusCode == 200 || captureResponse.statusCode == 201) {
        final data = json.decode(captureResponse.body);
        print('   Response keys: ${data.keys.toList()}');
        
        if (data['captureContext'] != null) {
          final captureContext = data['captureContext'] as String;
          print('✅ Capture context received: ${captureContext.substring(0, 50)}...');
        } else {
          print('⚠️  No captureContext field in response');
          print('   Full response: $data');
        }
      } else {
        print('❌ Error response: ${captureResponse.body}');
      }
    } catch (e) {
      print('❌ Capture context failed: $e');
    }
    
    // Test 3: Check if backend is accessible from mobile network
    print('\n3. Testing network connectivity...');
    try {
      final result = await Process.run('ping', ['-c', '3', '10.195.49.18']);
      print('Ping result: ${result.stdout}');
    } catch (e) {
      print('Ping test failed: $e');
    }
    
  } finally {
    client.close();
  }
  
  print('\n🏁 Test completed!');
}