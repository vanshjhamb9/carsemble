// Run from Source: dart run tool/login_debug.dart
import 'dart:convert';
import 'dart:io';

void main() async {
  const baseUrl = 'http://192.168.1.7:8000/api/development/';
  const apiKey = '1234';
  const number = '1648664852';
  const password = '123456';

  final body = jsonEncode({'number': number, 'password': password});
  print('POST ${baseUrl}login');
  print('Body: $body');
  print('Headers: Content-Type=application/json, x-api-key=$apiKey');
  print('---');

  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse(baseUrl + 'login'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('x-api-key', apiKey);
    request.write(body);
    final response = await request.close().timeout(const Duration(seconds: 15));
    final responseBody = await response.transform(utf8.decoder).join();
    print('Status: ${response.statusCode}');
    print('Response: $responseBody');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close(force: true);
  }
}
