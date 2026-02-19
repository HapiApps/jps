import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/customer/customer_attendance_model.dart';
import '../model/task/task_data_model.dart';
import '../model/task/task_details_model.dart';
import '../model/task/task_list_model.dart';
import '../model/task/task_chart_model.dart';
import '../model/user_model.dart';
import '../source/constant/api.dart';
import '../source/constant/local_data.dart';

class TaskRepo {
  Future<List<DTaskModel>> downloadReport(Map data) async {
    try{
      final request = await http.post(Uri.parse(taskScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("Respond ${data}");
      log("Resp ${request.body}");
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => DTaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get role');
      }
    }catch(e){
      throw Exception('Failed to get role');
    }
  }

  Future<Map<String,dynamic>> addType(Map data) async {
    try{
      final request = await http.post(Uri.parse(taskScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(data);
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
  Future<List<CustomerAttendanceModel>> getAttendances1(Map data) async {
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
      // print(data);
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

  Future<String> addTask(Map<String,String> data,List list) async {
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
      print(request.body);
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
  Future<List> getTasks(Map data) async {
    try{
      final request = await http.post(Uri.parse(taskScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      // print(phpFile);
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

  Future<String> updateTask(Map<String,String> data) async {
    try{
      var uri = Uri.parse(taskScript);
      var request = http.MultipartRequest("POST", uri);
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
  Future<List<TaskData>> getReport(Map data) async {
    try{
      final request = await http.post(Uri.parse(taskScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print("Respond ${data}");
      // print("Resp ${request.body}");
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => TaskData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get role');
      }
    }catch(e){
      throw Exception('Failed to get role');
    }
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

  Future<List> getListDatas(Map data) async {
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
        return response;
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }

  Future<TaskListResponse> getTaskList() async {
    try {
      final response = await http.post(Uri.parse(taskScript),
          body: jsonEncode({
            'search_type': "all_tasks",
            'action': "get_data",
            'role': localData.storage.read("role"),
            'userId': localData.storage.read("id"),
            'cos_id': localData.storage.read("cos_id")
          }));
      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);

        return TaskListResponse.fromJson(dataMap);
      } else {
        throw Exception('Failed to load getUser');
      }
    } catch (e) {
      log("Error getTask : $e");
      throw Exception(e);
    }
  }

  Future<TaskListResponse> getTaskDepartmentList(String projectName, String department) async {
    try {
      final response = await http.post(Uri.parse(taskScript),
          body: jsonEncode({
            'search_type': "department_tasks",
            'action': "get_data",
            'role': localData.storage.read("role"),
            'userId': localData.storage.read("id"),
            'cos_id': localData.storage.read("cos_id"),
            'project_name':projectName,
            'department':department
          }));
      if (kDebugMode) {
        print("fetch de ${
          {
            'search_type': "department_tasks",
            'action': "get_data",
            'role': localData.storage.read("role"),
            'userId': localData.storage.read("id"),
            'cos_id': localData.storage.read("cos_id"),
            'project_name':projectName,
            'department':department
          }
      }");
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);

        return TaskListResponse.fromJson(dataMap);
      } else {
        throw Exception('Failed to load getUser');
      }
    } catch (e) {
      log("Error getTask : $e");
      throw Exception(e);
    }
  }

  Future<DepartmentListResponse> getDepartmentList(String projectName) async {
    try {
      final response = await http.post(Uri.parse(taskScript),
          body: jsonEncode({
            'search_type': "all_departments",
            'action': "get_data",
            'cos_id': localData.storage.read("cos_id"),
            'project_name':projectName
          }));
      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);
        return DepartmentListResponse.fromJson(dataMap);
      } else {
        throw Exception('Failed to load getUser');
      }
    } catch (e) {
      log("Error get department : $e");
      throw Exception(e);
    }
  }

  Future<DepartmentListResponse> getDepartmentCountList(String projectName) async {
    try {
      final response = await http.post(Uri.parse(taskScript),
          body: jsonEncode({
            'search_type': "departments_count",
            'action': "get_data",
            'cos_id': localData.storage.read("cos_id"),
            'project_name':projectName
          }));
      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);
        return DepartmentListResponse.fromJson(dataMap);
      } else {
        throw Exception('Failed to load getUser');
      }
    } catch (e) {
      log("Error get department : $e");
      throw Exception(e);
    }
  }

  Future<TaskDetailsResponse> getTaskDetails(String taskId) async {
    try {
      final response = await http.post(Uri.parse(taskScript),
          body: jsonEncode({
            "search_type": "task_details",
            "action": "get_data",
            "taskId": taskId,
          }));
      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);

        return TaskDetailsResponse.fromJson(dataMap);
      } else {
        throw Exception('Failed to load getUser');
      }
    } catch (e) {
      log("Error getTaskDetails : $e");
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> updateTaskStatusApi(
      {required String taskId, required String status}) async {
    try {
      final response = await http.post(Uri.parse(taskScript),
          body: jsonEncode({
            "user_id": localData.storage.read("id"),
            "action": "update_status",
            "t_status": "1",
            "task_id": taskId,
            "status": status,
            "mobile": localData.storage.read("mobile_number"),
            'cos_id': localData.storage.read("cos_id")
          }));
      print(taskScript);
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);
        return dataMap;
      } else {
        throw Exception('Failed to load getUser');
      }
    } catch (e) {
      log("Error getTaskDetails : $e");
      throw Exception(e);
    }
  }
  Future<List> addAttendance(Map<String, String> data,String img) async {
    try{
      var request = http.MultipartRequest("POST", Uri.parse(phpFile));
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
      // print(request.body);
      // print(request.statusCode);
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

  Future<Map<String, dynamic>> getUserNames() async {
    try {
      final response = await http.post(Uri.parse(taskScript),
          body: jsonEncode({
            'search_type': "all_mobiles",
            'action': "get_data",
            'cos_id': localData.storage.read("cos_id")
          }));

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);
        return dataMap;
      } else {
        throw Exception('Failed to load getUser');
      }
    } catch (e) {
      log("Error getUser : $e");
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> getDashboardCount() async {
    try {
      final response = await http.post(Uri.parse(taskScript),
          body: jsonEncode({
            'search_type': "task_count",
            'action': "get_data",
            'role': localData.storage.read("role"),
            'userId': localData.storage.read("id"),
            'cos_id': localData.storage.read("cos_id")
          }));

      // print("user id ${localData.storage.read("id")}");
      // print("user id ${localData.storage.read("role")}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);
        return dataMap;
      } else {
        throw Exception('Failed to load task count');
      }
    } catch (e) {
      log("Error task count : $e");
      throw Exception(e);
    }
  }
}
