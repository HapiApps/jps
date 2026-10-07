class UserResponse {
  String? responseCode;
  String? result;
  String? responseMsg;
  UserData? userLogin;


  UserResponse({

    this.responseCode,
    this.result,
    this.responseMsg,
    this.userLogin,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        userLogin: json["UserLogin"] == null
            ? null
            : UserData.fromJson(json["UserLogin"]),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "UserLogin": userLogin?.toJson(),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class UserData {
  String? id;
  String? name;
  String? mobile;
  String? emailId;
  String? password;

  UserData({
    this.id,
    this.name,
    this.mobile,
    this.emailId,
    this.password,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        name: json["user_name"],
        mobile: json["mobile_number"],
        emailId: json["email_id"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_name": name,
        "mobile_number": mobile,
        "email_id": emailId,
        "password": password
      };
}
