import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart'as http;
import 'package:master_code/model/report/work_report_model.dart';
import 'package:master_code/screens/report_dashboard/report_dashboard.dart';
import 'package:master_code/source/constant/api.dart';

class ReportRepository{

  Future<List> getChangeReport(Map data) async {
    try{
      final request = await http.post(Uri.parse(taskScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("Respond ${data}");
      print("Resp ${request.body}");
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response;
      } else {
        throw Exception('Failed to get role');
      }
    }catch(e){
      throw Exception('Failed to get role');
    }
  }
  Future<List> getReport(Map data) async {
    try{
      final request = await http.post(Uri.parse(taskScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("Respond ${data}");
      print("Resp ${request.body}");
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response;
      } else {
        throw Exception('Failed to get role');
      }
    }catch(e){
      throw Exception('Failed to get role');
    }
  }
  Future<List<MonthReport>> getChartReport(Map data) async {
    try{
      final request = await http.post(Uri.parse(taskScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("Resp ${request.body}");
      print("Respond ${data}");
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => MonthReport.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get role');
      }
    }catch(e){
      throw Exception('Failed to get role');
    }
  }

  Future<List<ReportModel>> getAddReport(Map data) async {
    try{
    final request = await http.post(Uri.parse(projectPhpFile),
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
      return response.map((json) => ReportModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get role');
    }
    }catch(e){
      throw Exception('Failed to get role');
    }
  }

  Future<Map<String,dynamic>> insertWorkReport(Map<String, String> requestData)async{
    try {
      var uri = Uri.parse(projectPhpFile);
      var request = http.MultipartRequest("POST", uri);
      request.fields.addAll(requestData);

      var response = await request.send();
      var result = await http.Response.fromStream(response);
      log('result.body');
      log(requestData.toString());
      log(result.body);
      if (response.statusCode == 200) {
        return json.decode(result.body);
      } else {
        return json.decode(result.body);
      }
    }catch(e){
      throw Exception('Failed to work flow');
    }
  }
  Future<Map<String,dynamic>> insertProjectReport(List<Map<String, String>> documentList,Map<String, String> requestData)async{
    try {
      var uri = Uri.parse(projectPhpFile);
      var request = http.MultipartRequest("POST", uri);
      for (int i = 0; i < documentList.length; i++) {
        var fieldName = 'images_$i';
        var imagePath = documentList[i]["image_$i"]!;
        var file = await http.MultipartFile.fromPath(
          fieldName,
          imagePath,
        );
        request.files.add(file);
      }
      request.fields.addAll(requestData);

      var response = await request.send();
      var result = await http.Response.fromStream(response);
      log('result.body');
      log(requestData.toString());
      log(result.body);
      if (response.statusCode == 200) {
        return json.decode(result.body);
      } else {
        return json.decode(result.body);
      }
    }catch(e){
      throw Exception('Failed to work flow');
    }
  }

}