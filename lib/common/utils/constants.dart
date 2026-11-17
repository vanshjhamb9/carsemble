import 'package:flutter/material.dart';

class Constants {
  // Public dump only — not FKM-App source of truth. Defaults intentionally inert.
  // Canonical app: https://github.com/vanshjhamb9/FKM-App
  static const dommain = 'https://app.fitkarnatakamission.com';
  static const baseUrl = '$dommain/api/development/';

  /// Do not ship real keys in this public dump. Use FKM-App + dart-define.
  static const apiKey = String.fromEnvironment('FKM_API_KEY');
  static const scheme = 'academyapp';

  /// Default currency when API doesn't provide one (e.g. INR for Rs).
  static const String defaultCurrency = 'INR';
  /// Set to a currency code (e.g. 'INR') to always use it; set to null to use API/config currency.
  static const String? forceCurrencyCode = 'INR';
  
  static final RouteObserver<ModalRoute<void>> singleCourseRouteObserver = RouteObserver<ModalRoute<void>>();
  static final RouteObserver<ModalRoute<void>> contentRouteObserver = RouteObserver<ModalRoute<void>>();

}
