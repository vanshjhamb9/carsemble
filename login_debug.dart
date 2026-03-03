// Run from Source: dart run login_debug.dart
import 'dart:convert';
import 'dart:io';

void main() async {
  const baseUrl = 'http://192.168.1.7:8000/api/development/';
  const apiKey = '1234';
  const number = '1648664852';
  const password = '123456';

  final url = baseUrl + 'login';
  final body = {'number': number, 'password': password};
  final headers = {
    'x-api-key': apiKey,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  print('POST $url');
  print('Body: $body');
  print('---');

  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse(url));
    headers.forEach((k, v) => request.headers.set(k, v));
    request.write(jsonEncode(body));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    client.close();

    print('Status: ${response.statusCode}');
    print('Response: $responseBody');
  } catch (e, st) {
    print('Error: $e');
    print(st);
  }
}
