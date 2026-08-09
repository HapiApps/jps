import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart'as http;
import 'package:master_code/source/constant/api.dart';

import '../model/setting/features_model.dart';

class HomeRepository{

  Future<List<FeaturesModel>> getFeatures(Map data) async {
    try{
      final request = await http.post(Uri.parse(settingPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      log(data.toString());
      log(request.body.toString());
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => FeaturesModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to users');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to users');
    }
  }
  Future<List> getRole(Map data) async {
    // try{
    final request = await http.post(Uri.parse(settingPhpFile),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"));
    print("Respond ${data}");
    print("Respond ${request.body}");
    List response = json.decode(request.body);
    if (request.statusCode == 200){
      return response;
    } else {
      throw Exception('Failed to get role');
    }
    // }catch(e){
    //   throw Exception('Failed to get role');
    // }
  }
  Future<List<ValuesModel>> getData(Map data) async {
    // try{
    final request = await http.post(Uri.parse(settingPhpFile),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"));
    print("Respond ${data}");
    print("Respond ${request.body}");
    if (request.statusCode == 200){
      List response = json.decode(request.body);
      return response.map((json) => ValuesModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get role');
    }
    // }catch(e){
    //   throw Exception('Failed to get role');
    // }
  }
  Future<List> settingList(Map data) async {
    try{
      // print(data);
      final request = await http.post(Uri.parse(settingPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(settingPhpFile);
      // print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        // print("response");
        return response;
      } else {
        throw Exception('Failed to get version');
      }
    }catch(e){
      print(e);
      throw Exception('Failed to get version');
    }
  }

  Future<Map<String,dynamic>> manageSetting(Map data) async {
    try{
      final response = await http.post(
        Uri.parse(settingPhpFile),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      print("request.body");
      print(data);
      print(response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }

  Future<List> getDashboardReport(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
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
  Future<Map<String, dynamic>> getFullDashboard(Map data) async {
    try {
      final request = await http.post(
        Uri.parse(phpFile),   // your php URL
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (request.statusCode == 200) {
        return json.decode(request.body);
      } else {
        throw Exception("Server Error");
      }

    } catch (e) {
      throw Exception("API Error");
    }
  }
}