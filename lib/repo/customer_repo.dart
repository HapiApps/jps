import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart'as http;
import 'package:master_code/model/customer/customer_attendance_model.dart';
import 'package:master_code/model/customer/customer_model.dart';
import 'package:master_code/source/constant/api.dart';
import '../model/customer/customer_report_model.dart';
import '../model/track/track_model.dart';

class CustomerRepository{

  Future<String> taskComments(Map<String,String> data,List list) async {
    try{
      var uri = Uri.parse(taskScript);
      var request = http.MultipartRequest("POST", uri);
      for (int i = 0; i < list.length; i++) {
        var fieldName = 'images_$i';
        var imagePath = list[i]["image_$i"];
        // print(list);
        // print("imagePath");
        // print(imagePath);
        var file = await http.MultipartFile.fromPath(
          fieldName,
          imagePath,
        );
        request.files.add(file);
      }
      request.fields.addAll(data);

      var response = await request.send();
      var result=await http.Response.fromStream(response);
      print("Response : ${result.body}");
      if (result.statusCode == 200) {
        return result.body;
      }else{
        return result.body;
      }
    }catch(e){
      // print(e);
      throw Exception('Failed to work flow');
    }
  }

  /// Add Employee
  Future<List> addAttendance(Map data) async {
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
      List response = json.decode(request.body);
      if (request.statusCode == 200) {
        return response;
      }else{
        return response;
      }
    }catch(e){
      // print(e);
      throw Exception('Failed to work flow');
    }
  }
  Future<Map<String,dynamic>> addVisit(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      // print(request.statusCode);
      Map<String,dynamic> response = json.decode(request.body);
      if (request.statusCode == 200) {
        return response;
      }else{
        return response;
      }
    }catch(e){
      // print(e);
      throw Exception('Failed to work flow');
    }
  }
  Future<String> addComments(Map<String,String> data,List list) async {
    try{
      var uri = Uri.parse(phpFile);
      var request = http.MultipartRequest("POST", uri);
      for (int i = 0; i < list.length; i++) {
        var fieldName = 'images_$i';
        var imagePath = list[i]["image_$i"];
        // print(list);
        // print("imagePath");
        // print(imagePath);
        var file = await http.MultipartFile.fromPath(
          fieldName,
          imagePath,
        );
        request.files.add(file);
      }
      request.fields.addAll(data);

      var response = await request.send();
      var result=await http.Response.fromStream(response);
      // print("Response : ${result.body}");
      if (result.statusCode == 200) {
        return result.body;
      }else{
        return result.body;
      }
    }catch(e){
      // print(e);
      throw Exception('Failed to work flow');
    }
  }


  Future<String> addCustomer(Map<String, dynamic> data,String img,String img2,List<int> imgList1,List<int> imgList2,String imgName1,String imgName2) async {
    try {
      final uri = Uri.parse(phpFile);
      var request = http.MultipartRequest("POST", uri);
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      if(img!=""){
        if (kIsWeb) {
          var picture1= http.MultipartFile.fromBytes("img1",imgList1,filename:imgName1);
          request.files.add(picture1);
        }else{
          var picture1=await http.MultipartFile.fromPath("img1",img);
          request.files.add(picture1);
        }
      }if(img2!=""){
        if (kIsWeb) {
          var picture1= http.MultipartFile.fromBytes("img2",imgList2,filename:imgName2);
          request.files.add(picture1);
        }else {
          var picture1 = await http.MultipartFile.fromPath("img2", img2);
          request.files.add(picture1);
        }
      }
      var response = await request.send();
      var result = await http.Response.fromStream(response);
      print("Response: ${result.body}");
      if (result.statusCode == 200) {
        return result.body;
      }else if(response.toString().contains("already exits")){
        return result.body;
      } else {
        return result.body;
      }
    } catch (e) {
      // print("Error: $e");
      throw Exception("Failed to post attendance");
    }
  }
  Future<String> editCustomer(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse(phpFile);
      var request = http.MultipartRequest("POST", uri);
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      var response = await request.send();
      var result = await http.Response.fromStream(response);
      // print("Response: ${result.body}");
      if (result.statusCode == 200) {
        return result.body;
      } else {
        return result.body;
      }
    } catch (e) {
      // print("Error: $e");
      throw Exception("Failed to post attendance");
    }
  }

  Future<Map<String,dynamic>> deleteCustomer(Map data) async {
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

  /// Delete Employee
  Future<Map<String,dynamic>> addData(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(request.body);
      print(request.statusCode);
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

  Future<List<CustomerModel>> getCustomers(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print("CCccCCCCCCCCCCCCC");
      print(request.body);
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => CustomerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<List<CustomerReportModel>> getComments(Map data) async {
    // try{
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
        return response.map((json) => CustomerReportModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    // }catch(e){
    //   // print(e.toString());
    //   throw Exception('Failed to work flow');
    // }
  }
  Future<List<CustomerAttendanceModel>> getAttendances(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print("request.body");
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
  Future<List> getCustomerAttendance(Map data) async {
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
  Future<Map<String, dynamic>> insertTracking(Map data) async {
    // try{
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
    // }catch(e){
    //   print("e $e");
    //   throw Exception('Failed to login');
    // }
  }
  Future<Map<String, dynamic>> manageTracking(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
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
  Future<List<TrackingModel>> trackList(Map data) async {
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
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => TrackingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<List> liveTrack(Map data) async {
    try{
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
        return response;
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
}