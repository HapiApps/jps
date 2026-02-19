import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:master_code/model/leave/rules_model.dart';
import 'package:master_code/source/constant/api.dart';

import '../model/leave/holiday.dart';
import '../model/leave/leave_model.dart';

class LeaveRepository{

  Future<List> getList(Map data) async {
    // try{
      final request = await http.post(Uri.parse(leavePhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      List response = json.decode(request.body);
      // print(data);
      // print(response);
      if (request.statusCode == 200){
        return response;
      } else {
        throw Exception('Failed to get role');
      }
    // }catch(e){
    //   throw Exception('Failed to get role');
    // }
  }

  Future<Map<String,dynamic>> addEmployee(Map data) async {
    try{
      final request = await http.post(Uri.parse(leavePhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(request.body);
      print(data);
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
  Future<List<RulesModel>> getRules(Map data) async {
    try{
      final request = await http.post(Uri.parse(leavePhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => RulesModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<List<LeaveModel>> getLeave(Map data) async {
    try{
      final request = await http.post(Uri.parse(leavePhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => LeaveModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<List<Holiday>> getHolyDays(Map data) async {
    try{
      final request = await http.post(Uri.parse(leavePhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => Holiday.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }

}