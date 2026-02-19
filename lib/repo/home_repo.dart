import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:master_code/source/constant/api.dart';

class HomeRepository{
  Future<List> getDashboardReport(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data.toString());
      print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response;
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }

  /// Check Version
  Future<List> selectDataList(Map data) async {
    try{
      // print(data);
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        // print("response");
        // print(response);
        return response;
      } else {
        throw Exception('Failed to get version');
      }
    }catch(e){
      // print(e);
      throw Exception('Failed to get version');
    }
  }
  /// login
  Future<Map<String, dynamic>> loginApi(Map data) async {
    // try{
    final request = await http.post(Uri.parse(phpFile),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"));
    // print("request.body");
    // print(request.body);
    if (request.statusCode==200) {
      Map<String, dynamic> response = json.decode(request.body);
      return response;
    } else {
      throw Exception('Failed to login');
    }
    // }catch(e){
    //   // print("e $e");
    //   throw Exception('Failed to login');
    // }
  }
  Future<Map<String, dynamic>> forgotPwd(Map data) async {
    try{
    final request = await http.post(Uri.parse(phpFile),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"));
    // print(data.toString());
    // print(request.body);
    if (request.statusCode == 200) {
      Map<String, dynamic> response = json.decode(request.body);
      return response;
    } else {
      throw Exception('Failed to login');
    }
    }catch(e){
      // print("e $e");
      throw Exception('Failed to login');
    }
  }

}