import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

ApiService apiService = ApiService._();
class ApiService {
  ApiService._();
  // Generic GET Request
   Future<dynamic> getRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }

  // Generic POST Request
   Future<T> postRequest1<T>(
      String url, Map<String, dynamic> body, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return fromJson(jsonData);  // Parse the response to the desired type
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }
  //  Future<T> postRequest<T>(
  //     String url,
  //     Map<String, dynamic> body,
  //     T Function(dynamic json) fromJson, // accept dynamic instead of Map<String, dynamic>
  //     ) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: jsonEncode(body),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final dynamic jsonData = jsonDecode(response.body);
  //       return fromJson(jsonData); // Now supports Map or List
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     throw Exception('API Error: $e');
  //   }
  // }
  Future<T> postRequest<T>(
      String url,
      Map<String, dynamic> body,
      T Function(dynamic json) fromJson, // accept dynamic instead of Map<String, dynamic>
      ) async {
    try {
      debugPrint("POST Request: $url");
      debugPrint(" Request Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint(" Raw Response Body: '${response.body}'");
      debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception("Empty response from server");
        }

        try {
          final dynamic jsonData = jsonDecode(response.body);
          debugPrint("Decoded JSON: $jsonData");
          return fromJson(jsonData); // works with Map or List
        } catch (e) {
          debugPrint(" JSON decode error: $e");
          throw Exception("Invalid JSON: ${response.body}");
        }
      } else {
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(" postRequest Error: $e");
      throw Exception('API Error: $e');
    }
  }



  Future<Map<String, dynamic>> sendPostRequest({
    required String apiUrl,
    required Map<String, dynamic> data,
  }) async {

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final  jsonData = jsonDecode(response.body);
      return jsonData; // Now supports Map or List
    } else {
      throw Exception('Failed to load data');
    }
  }
}




