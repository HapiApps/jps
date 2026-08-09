import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:master_code/model/payroll/payroll_setting_model.dart';
import 'package:master_code/model/user_model.dart';
import '../model/payroll/payroll_details_model.dart';
import '../source/constant/api.dart';
class PayrollARepository{

  Future<List> getCategory(Map data) async {
    try{
    final request = await http.post(Uri.parse(payrollPhpFile),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"));
    List response = json.decode(request.body);
    if (request.statusCode == 200){
      return response;
    } else {
      throw Exception('Failed to get role');
    }
    }catch(e){
      throw Exception('Failed to get role');
    }
  }
  Future<List<PayrollSettingModel>> getSettings(Map data) async {
    try{
      final request = await http.post(Uri.parse(payrollPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => PayrollSettingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<Map<String,dynamic>> addPayrollSetting(Map data) async {
    try{
      final request = await http.post(Uri.parse(payrollPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(request.body);
      if (request.statusCode == 200) {
        return json.decode(request.body);
      } else {
        return json.decode(request.body);
      }
    }catch(e){
      // print(e);
      throw Exception('Failed to work flow');
    }
  }
  Future<List<PayrollDetailsModel>> getPayrollUserDetails(Map data) async {
    try{
      final request = await http.post(Uri.parse(payrollPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(data);
      // log(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => PayrollDetailsModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<List<PayrollDetailsModel>> getOurPayrollDetails(Map data) async {
    try{
      final request = await http.post(Uri.parse(payrollPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => PayrollDetailsModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<List<UserModel>> getPayrollUsers(Map data) async {
    try{
      final request = await http.post(Uri.parse(payrollPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<Map<String,dynamic>> insertSalaryDetails(Map data) async {
    try {
      final request = await http.post(
        Uri.parse(payrollPhpFile),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      // print(request.body);
      // print(data);
      if (request.statusCode == 200) {
        return json.decode(request.body);
      } else {
        return json.decode(request.body);
      }
    } catch (e) {
      throw Exception('Failed to work flow');
    }
  }

}