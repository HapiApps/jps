import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:master_code/source/constant/api.dart';

class TackRepository{

  Future<List> getTodayTrack(Map data) async {
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