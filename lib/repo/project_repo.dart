import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart'as http;
import 'package:master_code/model/project/project_model.dart';
import 'package:master_code/source/constant/api.dart';

import '../model/customer/customer_attendance_model.dart';
import '../model/user_model.dart';

class ProjectRepository{

  Future<List<UserModel>> getUsers(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(data);
      // print(request.body);
      // print(phpFile);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to users');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to users');
    }
  }

  Future<List> addAttendance(Map<String, String> data,String img) async {
    try{
      var request = http.MultipartRequest("POST", Uri.parse(projectPhpFile));
      request.fields.addAll(data);
      if(img!=""&&img.contains("/")){
        var picture1=await http.MultipartFile.fromPath("img",img);
        request.files.add(picture1);
      }
      var response = await request.send();
      var result=await http.Response.fromStream(response);
      // print('Fields ....${request.fields}');
      // print('Files ....${request.files}');
      // print('RESULT ....${result.body}');
      // print('RESULT ....${result.body}');
      if (result.statusCode == 200) {
        return json.decode(result.body);
      } else {
        return json.decode(result.body);
      }
    }catch (e) {
      log("Error getUser : $e");
      throw Exception(e);
    }

  }
  Future<List<CustomerAttendanceModel>> getAttendances(Map data) async {
    try{
      final request = await http.post(Uri.parse(projectPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print("request.body");
      // print(data);
      // print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => CustomerAttendanceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<Map<String,dynamic>> grpAttendances(Map data) async {
    try{
      final response = await http.post(
        Uri.parse(projectPhpFile),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      // print("request.body");
      // print(data);
      // print(response.body);
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


  Future<List<ProjectModel>> getProjectDetails(Map data) async {
    try{
      final request = await http.post(Uri.parse(projectPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => ProjectModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to users');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to users');
    }
  }
  Future<Map<String,dynamic>> insert(Map data) async {
    try{
      final request = await http.post(Uri.parse(projectPhpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
      // print(request.statusCode);
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


}