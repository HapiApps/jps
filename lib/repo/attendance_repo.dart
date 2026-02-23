import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart'as http;
import 'package:master_code/source/constant/api.dart';
import '../model/attendance_model.dart';

class AttendanceRepository{

  Future<List> getAttendance(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
    if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response;
      } else {
        throw Exception('Failed to get version');
      }
    }catch(e){
      // print("e.toString()");
      // print(e.toString());
      throw Exception('Failed to get version');
    }
  }
  Future<List<AttendanceModel>> getReport(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(data.toString());
      // print(request.body.toString());
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => AttendanceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get attendance');
      }
    }catch(e){
      // print("Printtt $e");
      throw Exception('Failed to get attendance');
    }
  }
  Future<Map<String,dynamic>> addAttendance(Map<String, String> data,String img) async {
    try{
      var request = http.MultipartRequest("POST", Uri.parse(phpFile));
      request.fields.addAll(data);
      if(img!=""&&img.contains("/")){
        var picture1=await http.MultipartFile.fromPath("img",img);
        request.files.add(picture1);
      }
      var response = await request.send();
      var result=await http.Response.fromStream(response);
      log('Fields ....${request.fields}');
      log('Files ....${request.files}');
      log('RESULT ....${result.body}');
      log('RESULT ....${result.body}');
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

}