import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/common/utils/http_handler.dart';
import 'package:http/http.dart';

class AuthenticationService{

  static Future google(String email,String token, String name)async{
    try{
      String url = '${Constants.baseUrl}google/callback';

      Response res = await httpPost(
        url, 
        {
          'email': email,
          'name': name,
          'id': token,
        }
      );


      if(res.statusCode == 200){
        await AppData.saveAccessToken(jsonDecode(res.body)['data']['token']);
        return true;
      }else{

        return false;
      }

    }catch(e){
      return false;
    }
  }

  static Future facebook(String email, String token, String name)async{
    try{
      String url = '${Constants.baseUrl}facebook/callback';

      Response res = await httpPost(
        url, 
        {
          'id': token,
          'name': name,
          'email': email
        }
      );

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        await AppData.saveAccessToken(jsonDecode(res.body)['data']['token']);
        return true;
      }else{
        
        return false;
      }

    }catch(e){
      return false;
    }
  }

  /// Login: header x-api-key from Constants.apiKey (dart-define); body = username + password.
  static Future login({
    String? email,
    String? countryCode,
    String? mobile,
    String? username,
    required String password,
  }) async {
    Response res;
    try {
      String url = '${Constants.baseUrl}login';

      Map<String, dynamic> body = {'password': password.toString().trim()};
      
      // API expects 'username' field (can be email or full phone number)
      if (email != null && email.trim().isNotEmpty) {
        body['username'] = email.trim();
      } else if (countryCode != null && mobile != null && mobile.trim().isNotEmpty) {
        final fullNumber = '${countryCode.replaceAll('+', '').trim()}${mobile.trim()}';
        body['username'] = fullNumber;
      } else if (username != null && username.trim().isNotEmpty) {
        body['username'] = username.trim();
      }

      final bodyForLog = Map<String, dynamic>.from(body)..['password'] = '***';
      log('Login request: POST $url');
      log('Login body (password hidden): $bodyForLog');

      // Use HttpClient so Content-Type is sent exactly as backend expects (avoids invalid_content_type)
      final client = HttpClient();
      try {
        final request = await client.postUrl(Uri.parse(url));
        request.headers.set('Content-Type', 'application/json');
        request.headers.set('Accept', 'application/json');
        request.headers.set('x-api-key', Constants.apiKey);
        request.write(jsonEncode(body));
        final response = await request.close().timeout(const Duration(seconds: 30));
        final responseBody = await response.transform(utf8.decoder).join();
        res = Response(responseBody, response.statusCode);
      } finally {
        client.close(force: true);
      }
    } catch (e, st) {
      log('Login request failed', error: e, stackTrace: st);
      String msg = 'Connection failed. ';
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        msg += 'Device cannot reach ${Constants.dommain}. Use same Wi‑Fi as the server and ensure Laravel is running (php artisan serve --host=0.0.0.0 --port=8000).';
      } else if (e.toString().contains('Timeout') || e.toString().contains('timed out')) {
        msg += 'Request timed out. Check server and network.';
      } else {
        msg += e.toString();
      }
      ErrorHandler().showError(ErrorEnum.error, {'message': msg}, readMessage: true);
      return false;
    }

    log(res.body.toString());

    if (res.statusCode != 200) {
      _showLoginErrorFromResponse(res);
      return false;
    }

    try {
      var jsonResponse = jsonDecode(res.body) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName('');
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }
    } catch (e, st) {
      log('Login response parse failed', error: e, stackTrace: st);
      _showLoginErrorFromResponse(res);
      return false;
    }
  }

  static void _showLoginErrorFromResponse(Response res) {
    if (res.body.trim().isEmpty) {
      ErrorHandler().showError(ErrorEnum.error, {
        'message': 'Server returned empty response (${res.statusCode}). Check that the login API is available at ${Constants.baseUrl}login',
      }, readMessage: true);
      return;
    }
    try {
      var json = jsonDecode(res.body) as Map<String, dynamic>;
      // Show validation details if present (e.g. Laravel "errors" or "data.errors")
      String? validationDetail;
      final errors = json['errors'] ?? json['data']?['errors'];
      if (errors is Map) {
        final first = errors.values.isNotEmpty ? errors.values.first : null;
        if (first is List && first.isNotEmpty) validationDetail = first.first.toString();
        else if (first != null) validationDetail = first.toString();
      }
      final message = validationDetail ?? json['message']?.toString() ?? 'Request failed';
      ErrorHandler().showError(ErrorEnum.error, {'message': message}, readMessage: true);
    } catch (_) {
      ErrorHandler().showError(ErrorEnum.error, {
        'message': 'Server returned an invalid response (${res.statusCode}). The login endpoint may be wrong or the server had an error. Expected JSON from ${Constants.baseUrl}login',
      }, readMessage: true);
    }
  }

  static Future<Map?> registerWithEmail(String registerMethod,String email, String password,String repeatPassword, String? accountType, List<Fields>? fields)async{
    try{
      String url = '${Constants.baseUrl}register/step/1';

      Map body = {
        "register_method": registerMethod,
        "country_code": null,
        'email': email,
        'password': password,
        'password_confirmation': repeatPassword
      };
      
      if(fields != null){
        Map bodyFields = {};
        for (var i = 0; i < fields.length; i++) {
          if(fields[i].type != 'upload'){
            bodyFields.addEntries(
              {
                fields[i].id: (fields[i].type == 'toggle') 
                  ? fields[i].userSelectedData == null ? 0 : 1
                  : fields[i].userSelectedData
              }.entries
            );
          }
        }

        body.addEntries({'fields': bodyFields.toString()}.entries);        
      }
      Response res = await httpPost(
        url, 
        body
      );


      var jsonResponse = jsonDecode(res.body);
      print(jsonResponse);

      if( jsonResponse['success'] || jsonResponse['status'] == 'go_step_2' || jsonResponse['status'] == 'go_step_3' ){
        
        return {
          'user_id': jsonResponse['data']['user_id'],
          'step': jsonResponse['status']
        };
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }

    }catch(e){
      return null;
    }
  }

  static Future<Map?> registerWithPhone(String registerMethod,String countryCode, String mobile, String password,String repeatPassword, String? accountType, List<Fields>? fields)async{
    try{
      String url = '${Constants.baseUrl}register/step/1';

      Map body = {
        "register_method": registerMethod,
        "country_code": countryCode,
        'mobile': mobile,
        'password': password,
        'password_confirmation': repeatPassword,
      };
      if(fields != null){
        Map bodyFields = {};
        for (var i = 0; i < fields.length; i++) {
          if(fields[i].type != 'upload'){
            bodyFields.addEntries(
              {
                fields[i].id: (fields[i].type == 'toggle') 
                  ? fields[i].userSelectedData == null ? 0 : 1
                  : fields[i].userSelectedData
              }.entries
            );
          }
        }

        body.addEntries({'fields': bodyFields.toString()}.entries);        
      }

      Response res = await httpPost(
        url, 
        body
      );
      var jsonResponse = jsonDecode(res.body);
       if( jsonResponse['success'] || jsonResponse['status'] == 'go_step_2' || jsonResponse['status'] == 'go_step_3' ){ // || stored
        
        return {
          'user_id': jsonResponse['data']['user_id'],
          'step': jsonResponse['status']
        };
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }

    }catch(e){
      return null;
    }
  }
  
  static Future<bool> forgetPassword(String? countryCode,String data)async{
    try{
      String url = '${Constants.baseUrl}forget-password';
      
      Response res = await httpPost(
        url, 
        { 
          'type' : countryCode == null ? 'email' : 'mobile',
          if(countryCode == null)...{
            "email": data
          }else...{
            "country_code": countryCode,
            "mobile": data,
          }
        }
      );

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        
        ErrorHandler().showError(ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      return false;
    }
  }
  
  static Future<bool> verifyCode(int userId,String code)async{
    try{
      String url = '${Constants.baseUrl}register/step/2';

      Response res = await httpPost(
        url, 
        {
          "user_id": userId.toString(),
          "code": code,
        }
      );

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      return false;
    }
  }
  
  static Future<bool> registerStep3(int userId, String name, String referralCode)async{
    try{
      String url = '${Constants.baseUrl}register/step/3';

      Response res = await httpPost(
        url, 
        {
          "user_id": userId.toString(),
          "full_name": name,
          "referral_code": referralCode
        }
      );


      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName(name);
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      return false;
    }
  }

  
}