import 'package:flutter/material.dart';

class Constants {
  // Backend URL for RELEASE APK on same network:
  // 1. Replace with your PC's IP (run "ipconfig" and use IPv4, e.g. 192.168.1.7 or 10.102.81.233)
  // 2. Run Laravel: php artisan serve --host=0.0.0.0 --port=8000
  // 3. Allow port 8000 in Windows Firewall if needed
  // For ngrok (works from any network): use https://your-subdomain.ngrok-free.dev
  static const dommain = 'http://192.168.1.7:8000';
  static const baseUrl = '$dommain/api/development/';

  /// Must match the backend and the value used in Postman (e.g. x-api-key header).
  static const apiKey = '1234';
  static const scheme = 'academyapp';

  /// Default currency when API doesn't provide one (e.g. INR for Rs).
  static const String defaultCurrency = 'INR';
  /// Set to a currency code (e.g. 'INR') to always use it; set to null to use API/config currency.
  static const String? forceCurrencyCode = 'INR';
  
  static final RouteObserver<ModalRoute<void>> singleCourseRouteObserver = RouteObserver<ModalRoute<void>>();
  static final RouteObserver<ModalRoute<void>> contentRouteObserver = RouteObserver<ModalRoute<void>>();

}
