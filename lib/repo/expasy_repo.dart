import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../model/expasy/expense_fetch.dart';
import '../model/expasy/fetch_details.dart';
import '../model/expasy/income_obj.dart';
import '../source/constant/api.dart';
import '../source/constant/local_data.dart';
import 'ex_api_services.dart';

ExpenseService expenseService = ExpenseService();

class ExpenseService {

  Future<Map<String, dynamic>> simpleInsertExpense({
    required String userAccount,
    required String mobile,
    required String city,
    required String shop,
    required String expenseHead,
    required String paymentType,
    required String particulars,
    required String gst,
    required String amount,
    required String date,
    required String userId,
    required List<Map<String, dynamic>> expenseList,
  }) async {
    Map<String, dynamic> data = {
      "action": "insert_expense",
      "user_account": userAccount.trim(),
      "mobile": mobile.trim(),
      "city": city.trim(),
      "shop_name": shop.trim(),
      "expense_head": expenseHead.trim(),
      "payment_type": paymentType.trim(),
      "particulars": particulars.trim(),
      "gst": gst.trim(),
      "amount": amount.trim(),
      "date": date.trim(),
      "user_id": userId.trim(),
      "expenseList": expenseList,
    };

    print("Sending Insert Expense: $data");

    final response = await http.post(
      Uri.parse(expasyPhpFile),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");
    final output = jsonDecode(response.body);
    if (response.statusCode == 200 && output["message"] == "ok") {
      print("Expense inserted successfully.");
      return output;
    } else {
      throw Exception("Insert failed: ${output["message"] ?? "Unknown error"}");
    }
  }

  Future<Map<String, dynamic>> insertExpense({
    required String userAccount,
    required String mobile,
    required String city,
    required String shop,
    required String expenseHead,
    required String paymentType,
    required String particulars,
    required String gst,
    required String amount,
    required String date,
    required String userId,
    required List<Map<String, dynamic>> expenseList,
  }) async {
    Map<String, dynamic> data = {
      "action": "insert_expense",
      "user_account": userAccount.trim(),
      "mobile": mobile.trim(),
      "city": city.trim(),
      "shop_name": shop.trim(),
      "expense_head": expenseHead.trim(),
      "payment_type": paymentType.trim(),
      "particulars": particulars.trim(),
      "gst": gst.trim(),
      "amount": amount.trim(),
      "date": date.trim(),
      "user_id": userId.trim(),
      "expenseList": expenseList,
    };

    print("Sending Insert Expense: $data");

    final response = await http.post(
      Uri.parse(expasyPhpFile),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
    // print("Response Status: ${response.statusCode}");
    // print("expasyPhpFile: ${expasyPhpFile}");
    print("Response Body: ${response.body}");
    final output = jsonDecode(response.body);
    if (response.statusCode == 200 && output["ResponseMsg"] == "Expense successfully recorded.") {
      print("Expense inserted successfully.");
      return output;
    } else {
      throw Exception("Insert failed: ${output["message"] ?? "Unknown error"}");
    }
  }

  static Future<ExpensesModel> getExpensesList() async {
    final Map<String, dynamic> requestBody = {
      // Your request body goes here, for example:
      'action':'get_data',
      "search_type": "all_expense",
      "user_id": localData.storage.read("id")
    };
    log("Expenses.....requestBody..........$requestBody");

    return await apiService.postRequest1(
      expasyPhpFile,  // API endpoint
      requestBody,  // Request body (if needed)
      ExpensesModel.fromJson,  // Parsing function for ProductsResponse
    );
  }
  static Future<List<ExpenseDetailsObj>> getExpenses() async {
    final Map<String, dynamic> requestBody = {
      // Your request body goes here, for example:
      'action':'get_expense',
      "search_type": "all_expense_data",
      "user_id": localData.storage.read("id")
    };
    log("Expenses.....requestBody..........$requestBody");

    return await apiService.postRequest(
      expasyPhpFile,
      requestBody,
          (json) => (json as List)
          .map((e) => ExpenseDetailsObj.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<List<ExpenseDetailsObj>> getExpenseById(String expenseId) async {
    final Map<String, dynamic> requestBody = {
      'action': 'get_expense',
      'search_type':"single_expense",
      "expense_id": expenseId,
    };
    log("Expenses..Id...requestBody..........$requestBody");
    return await apiService.postRequest(
      expasyPhpFile,
      requestBody,
          (json) => (json as List)
          .map((e) => ExpenseDetailsObj.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Map<String, dynamic>> updateExpense({
    required String expenseId,
    required String userAccount,
    required String mobile,
    required String city,
    required String shop,
    required String expenseHead,
    required String paymentType,
    required String particulars,
    required String gst,
    required String amount,
    required String date,
    required String userId,
    required List<Map<String, String>> expenseList,
  }) async {
    final data = {
      "action": "update_expense",
      "expense_id": expenseId,
      "user_account": userAccount.trim(),
      "mobile": mobile.trim(),
      "city": city.trim(),
      "shop_name": shop.trim(),
      "expense_head": expenseHead.trim(),
      "payment_type": paymentType.trim(),
      "particulars": particulars.trim(),
      "gst": gst.trim(),
      "amount": amount.trim(),
      "date": date.trim(),
      "user_id": userId.trim(),
      "expense_list": expenseList.map((e) => {
        "item_id": e["item_id"],
        "item_name": e["item_name"],
        "qty": e["qty"],
        "price": e["price"],
      }).toList(),
    };

    print("🚀 Sending Update Expense JSON: ${jsonEncode(data)}");

    final response = await http.post(
      Uri.parse(expasyPhpFile),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final output = jsonDecode(response.body);
    if (response.statusCode == 200 && output["message"] == "ok") {
      print("✅ Expense updated successfully.");
      return output;
    } else {
      throw Exception("Update failed: ${output["message"] ?? "Unknown error"}");
    }
  }


  // Future<Map<String, dynamic>> updateExpense({
  //   required String expenseId,
  //   required String userAccount,
  //   required String mobile,
  //   required String city,
  //   required String shop,
  //   required String expenseHead,
  //   required String paymentType,
  //   required String particulars,
  //   required String gst,
  //   required String amount,
  //   required String date,
  //   required String userId,
  //   required List<Map<String, String>> expenseList,
  // }) async {
  //   Map<String, dynamic> data = {
  //     "action": "update_expense",
  //     "expense_id": expenseId,
  //     "user_account": userAccount.trim(),
  //     "mobile": mobile.trim(),
  //     "city": city.trim(),
  //     "shop_name": shop.trim(),
  //     "expense_head": expenseHead.trim(),
  //     "payment_type": paymentType.trim(),
  //     "particulars": particulars.trim(),
  //     "gst": gst.trim(),
  //     "amount": amount.trim(),
  //     "date": date.trim(),
  //     "user_id": userId.trim(),
  //     "expense_list": expenseList.map((e) => {
  //       "item_id": e["item_id"],
  //       "item_name": e["item_name"],
  //       "qty": e["qty"],
  //       "price": e["price"],
  //     }).toList(),
  //   };
  //
  //   print("🚀 Sending Update Expense JSON: ${jsonEncode(data)}");
  //
  //
  //   final response = await http.post(
  //     Uri.parse(expasyPhpFile),
  //     headers: {
  //       "Accept": "application/json",
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode(data),
  //   );
  //
  //   print("Response Status: ${response.statusCode}");
  //   print("Response Body: ${response.body}");
  //
  //   final output = jsonDecode(response.body);
  //   if (response.statusCode == 200 && output["message"] == "ok") {
  //     print("✅ Expense updated successfully.");
  //     return output;
  //   } else {
  //     throw Exception("Update failed: ${output["message"] ?? "Unknown error"}");
  //   }
  // }

  Future<Map<String, dynamic>> deleteExpense({
    required String expenseId
  }) async {
    Map<String, dynamic> data = {
      "action": "delete_expense",
      "expense_id": expenseId,
    };

    final response = await http.post(
      Uri.parse(expasyPhpFile), // Replace with your actual endpoint
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );


    final output = jsonDecode(response.body);
    print(output["status_code"] );
    if (response.statusCode == 200 && output["status_code"] == 200) {
      print("Expense deleted successfully.");
      return output;
    } else {
      throw Exception("Delete failed: ${output["message"] ?? "Unknown error"}");
    }
  }
  Future<Map<String, dynamic>> insertIncome({
    required String income,
    required String date,
    required String userId,
    String? reason, //  optional now
  }) async {
    Map<String, dynamic> data = {
      "action": "insert_expense_income",
      "search_type":"insert_income",
      "income": income.trim(),
      "date": date.trim(),
      "user_id": userId.trim(),
      "mobile": localData.storage.read("mobile_number"),
      "reason": reason?.trim() ?? "", //  send empty if null
      "created_by":  userId.trim(),               //  make optional
      "updated_by": "",
    };

    print("Sending Insert income: $data");

    final response = await http.post(
      Uri.parse(expasyPhpFile),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final output = jsonDecode(response.body);

      //  Success check based on your PHP response
      if (output["ResponseCode"] == "200" && output["Result"] == "true") {
        print("Income inserted successfully.");
        return output;
      } else {
        throw Exception("Insert failed: ${output["ResponseMsg"] ?? "Unknown error"}");
      }
    } else {
      throw Exception("Insert failed: HTTP ${response.statusCode}");
    }
  }
  static Future<IncomeObj> getExpensesIncome() async {
    final Map<String, dynamic> requestBody = {
      // Your request body goes here, for example:
      'action':'insert_expense_income',
      "search_type": "get_income",
      "user_id": localData.storage.read("id")
    };
    log("Expenses.....requestBody..........$requestBody");

    return await apiService.postRequest1(
      expasyPhpFile,  // API endpoint
      requestBody,  // Request body (if needed)
      IncomeObj.fromJson,  // Parsing function for ProductsResponse
    );
  }
  static Future<Map<String, dynamic>> updateIncome({
    required String id,
    required String income,
    required String date,
    required String userId,
    String? reason,
  }) async {
    Map<String, dynamic> data = {
      "action": "insert_expense_income",
      "search_type": "update_expense_income",
      "id": id,
      "income": income.trim(),
      "date": date.trim(),
      "user_id": userId.trim(),
      "reason": reason?.trim() ?? "",
      "created_by": userId.trim(),
      "updated_by": userId.trim(),
      "mobile": localData.storage.read("mobile_number"),
    };

    print("Sending Update income: $data");

    final response = await http.post(
      Uri.parse(expasyPhpFile),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final output = jsonDecode(response.body);

      if (output["ResponseCode"] == "200" && output["Result"] == "true") {
        print("Income updated successfully.");
        return output;
      } else {
        throw Exception("Update failed: ${output["ResponseMsg"] ?? "Unknown error"}");
      }
    } else {
      throw Exception("Update failed: HTTP ${response.statusCode}");
    }
  }
  static Future<Map<String, dynamic>> deleteIncome({
    required String id,
    required String userId,
  }) async {
    Map<String, dynamic> data = {
      "action": "insert_expense_income",
      "search_type": "delete_income",
      "id": id,
      "user_id": userId,
    };

    print("Sending Delete income: $data");

    final response = await http.post(
      Uri.parse(expasyPhpFile),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final output = jsonDecode(response.body);

      // 👉 Adjusted check for delete
      if ((output["ResponseCode"] == "200" && output["Result"] == "true") ||
          (output["status_code"] == 200 && output["message"].toLowerCase() == "ok")) {
        print("Income deleted successfully.");
        return output;
      } else {
        throw Exception("Delete failed: ${output["ResponseMsg"] ?? output["message"] ?? "Unknown error"}");
      }
    } else {
      throw Exception("Delete failed: HTTP ${response.statusCode}");
    }
  }

}
