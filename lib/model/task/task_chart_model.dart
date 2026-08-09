class DepartmentListResponse {
  List<DepResponse>? response;
  String? responseCode;
  String? result;
  String? responseMsg;

  DepartmentListResponse({
    this.response,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory DepartmentListResponse.fromJson(Map<String, dynamic> json) =>
      DepartmentListResponse(
        response: List<DepResponse>.from(
            json["Response"].map((x) => DepResponse.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
    "Response": List<dynamic>.from(response!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class DepResponse {
  String? department;
  String? taskCount;

  DepResponse(
      {this.department,this.taskCount});

  factory DepResponse.fromJson(Map<String, dynamic> json) => DepResponse(
    department: json["department"],
    taskCount: json["task_count"],
  );

  Map<String, dynamic> toJson() => {
    "department": department,
    "task_count": taskCount,

  };
}
