import 'dart:convert';

import 'package:http/http.dart';

import '../../../common/enums/error_enum.dart';
import '../../../common/utils/constants.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/utils/http_handler.dart';

class PurchaseService{
  
  
  static Future<bool> bundlesFree(int courseId)async{
    
    try{
      String url = '${Constants.baseUrl}panel/bundles/$courseId/free';

      Response res = await httpPostWithToken(
        url, 
        {}
      );


      var jsonResponse = jsonDecode(res.body);


      if(jsonResponse['success']){
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }

    }catch(e){
      return false;
    }
  }
  
  static Future<bool> courseFree(int courseId)async{
    
    try{
      String url = '${Constants.baseUrl}panel/webinars/$courseId/free';


      Response res = await httpPostWithToken(
        url, 
        {}
      );


      var jsonResponse = jsonDecode(res.body);

      if(jsonResponse['success']){
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }

    }catch(e){
      return false;
    }
  }
  

  static Future<bool> addToCart(int courseId,String itemName,{String? specifications,int? quantity})async{
    
    try{
      // Use the correct cart endpoint instead of bundles/free
      String url = '${Constants.baseUrl}panel/cart';

      Response res = await httpPostWithToken(
        url, 
        {
          "item_id" : courseId.toString(),
          "item_name" : itemName,
          if(specifications != null)...{
            "specifications" : specifications,
          },
          "quantity" : quantity?.toString() ?? "1"
        }
      );


      var jsonResponse = jsonDecode(res.body);

      print(jsonResponse);

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

}