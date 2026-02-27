import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart'as http;
import 'package:master_code/source/constant/api.dart';

import '../model/user_model.dart';

class EmployeeRepository{

  /// Get Role
  Future<List> getRole(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      List response = json.decode(request.body);
      // print("Respond ${data}");
      // print("Respond ${request.body}");
      if (request.statusCode == 200){
        return response;
      } else {
        throw Exception('Failed to get role');
      }
    }catch(e){
      throw Exception('Failed to get role');
    }
  }

  Future<Map<String, dynamic>> notification(Map<String, dynamic> data) async {
    try {

      final response = await http.post(
        Uri.parse(phpFile),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      print("Request JSON: ${jsonEncode(data)}");
      print("Raw Response: ${response.body}");

      if (response.statusCode == 200) {

        if (response.body.isEmpty) {
          throw Exception("Empty server response");
        }

        return json.decode(response.body);

      } else {
        throw Exception('Server Error ${response.statusCode}');
      }

    } catch (e) {
      print("Notification API Error: $e");
      throw Exception('Admin notification failed');
    }
  }

  /// Add Employee
  Future<Map<String,dynamic>> addEmployee(Map<String, String> data,
      String img,List<int> imgList,String imgName,
      String img2,List<int> imgList2,String imgName2,
      String img3,List<int> imgList3,String imgName3,
      String img4,List<int> imgList4,String imgName4,
      String img5,List<int> imgList5,String imgName5,
      String img6,List<int> imgList6,String imgName6,
      String img7,List<int> imgList7,String imgName7,
      ) async {
    try{
    // print("img");
    // print(img);
    // print(img2);
    // print(img3);
    // print(img4);
    // print(img5);
    // print(img6);
    // print(img7);
      var request = http.MultipartRequest("POST", Uri.parse(phpFile));
      request.fields.addAll(data);
      if(img!="") {
        if (kIsWeb) {
          var picture1= http.MultipartFile.fromBytes("image",imgList,filename:imgName);
          request.files.add(picture1);
        } else {
          var picture1 = await http.MultipartFile.fromPath("image", img);
          request.files.add(picture1);
        }
      }
      if(img2!="") {
        if (kIsWeb) {
          var picture1= http.MultipartFile.fromBytes("aadhar_url",imgList2,filename:imgName2);
          request.files.add(picture1);
        } else {
          var picture1 = await http.MultipartFile.fromPath("aadhar_url", img2);
          request.files.add(picture1);
        }
      }
      if(img3!="") {
        if (kIsWeb) {
          var picture1= http.MultipartFile.fromBytes("aadhar_2_url",imgList3,filename:imgName3);
          request.files.add(picture1);
        } else {
          var picture1 = await http.MultipartFile.fromPath("aadhar_2_url", img3);
          request.files.add(picture1);
        }
      }
      if(img4!="") {
        if (kIsWeb) {
          var picture1= http.MultipartFile.fromBytes("pan_url",imgList4,filename:imgName4);
          request.files.add(picture1);
        } else {
          var picture1 = await http.MultipartFile.fromPath("pan_url", img4);
          request.files.add(picture1);
        }
      }
      if(img5!="") {
        if (kIsWeb) {
          var picture1= http.MultipartFile.fromBytes("cheque_url",imgList5,filename:imgName5);
          request.files.add(picture1);
        } else {
          var picture1 = await http.MultipartFile.fromPath("cheque_url", img5);
          request.files.add(picture1);
        }
      }
      if(img6!="") {
        if (kIsWeb) {
          var picture1= http.MultipartFile.fromBytes("license_url",imgList6,filename:imgName6);
          request.files.add(picture1);
        } else {
          var picture1 = await http.MultipartFile.fromPath("license_url", img6);
          request.files.add(picture1);
        }
      }
      if(img7!="") {
        if (kIsWeb) {
          var picture1= http.MultipartFile.fromBytes("voter_url",imgList7,filename:imgName7);
          request.files.add(picture1);
        } else {
          var picture1 = await http.MultipartFile.fromPath("voter_url", img7);
          request.files.add(picture1);
        }
      }
      var response = await request.send();
      var result=await http.Response.fromStream(response);
      // print('Files ....${request.files}');
      // print('RESULT ....${result.body}');
      if (result.statusCode == 200) {
        return json.decode(result.body);
      } else {
        return json.decode(result.body);
      }
    }catch(e){
      // print(e);
      throw Exception('Failed to work flow');
    }
  }
  /// Update Employee
  // Future<Map<String,dynamic>> updatedEmployee(Map<String, String> data,String img,List<int> imgList,String imgName) async {
  //   try{
  //     var request = http.MultipartRequest("POST", Uri.parse(phpFile));
  //     request.fields.addAll(data);
  //     if(img!=""){
  //       if (kIsWeb) {
  //         var picture1= http.MultipartFile.fromBytes("image",imgList,filename:imgName);
  //         request.files.add(picture1);
  //       }else{
  //         var picture1=await http.MultipartFile.fromPath("image",img);
  //         request.files.add(picture1);
  //       }
  //     }
  //     var response = await request.send();
  //     var result=await http.Response.fromStream(response);
  //     log('Fields ....${request.fields}');
  //     log('Files ....${request.files}');
  //     log('RESULT ....${result.body}');
  //     if (result.statusCode == 200) {
  //       return json.decode(result.body);
  //     } else {
  //       return json.decode(result.body);
  //     }
  //   }catch(e){
  //     // print("e $e");
  //     throw Exception('Failed to work flow');
  //   }
  // }
  Future<Map<String,dynamic>> insertGradleDetails(Map data) async {
    try {
      final request = await http.post(
        Uri.parse(phpFile),
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

  /// Delete Employee
  Future<Map<String,dynamic>> deleteEmployee(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
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
  Future<Map<String,dynamic>> activityEmployee(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
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
  /// View Work Flow
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
  Future<List> getUserLogs(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
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
        return response;
      } else {
        throw Exception('Failed to users');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to users');
    }
  }
  Future<List<UserDetail>> getUserDetails(Map data) async {
    // try{
      final request = await http.post(Uri.parse(phpFile),
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
        return response.map((json) => UserDetail.fromJson(json)).toList();
      } else {
        throw Exception('Failed to users');
      }
    // }catch(e){
    //   // print(e.toString());
    //   throw Exception('Failed to users');
    // }
  }
}