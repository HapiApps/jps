import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:master_code/source/constant/api.dart';
import '../model/expense_model.dart';
import '../screens/expense/expense_dashboard.dart';

class ExpenseRepository{
  Future<List<ExpenseModel>> userExpense(Map data) async {
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
      if (request.statusCode == 200){
        List response = json.decode(request.body);
        return response.map((json) => ExpenseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }

  /// Get Expense
  Future<List<ExpenseModel>> trackList(Map data) async {
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
        return response.map((json) => ExpenseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to work flow');
      }
    }catch(e){
      // print(e.toString());
      throw Exception('Failed to work flow');
    }
  }
  Future<List> getReport(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
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
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print("_report3 ${data}");
      // print(request.body);
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

  Future<Map<String,dynamic>> manageExpense(Map data) async {
    try{
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(request.body);
      // print(data);
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