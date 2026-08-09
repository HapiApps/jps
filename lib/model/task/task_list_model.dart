class TaskListResponse {
  List<Response>? response;
  String? responseCode;
  String? result;
  String? responseMsg;

  TaskListResponse({
    this.response,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) =>
      TaskListResponse(
        response: List<Response>.from(
            json["Response"].map((x) => Response.fromJson(x))),
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

class Response {
  String? id;
  String? taskTitle;
  String? projectName;
  String? department;
  String? type;
  String? level;
  String? assigned;
  String? status;
  String? createdBy;
  String? updatedBy;
  String? taskDate;
  String? taskTime;
  DateTime? createdTs;
  DateTime? updatedTs;
  String? active;

  Response(
      {this.id,
      this.taskTitle,
      this.department,
      this.type,
      this.level,
      this.assigned,
      this.status,
      this.createdBy,
      this.updatedBy,
      this.createdTs,
      this.updatedTs,
      this.active,
      this.taskDate,
      this.taskTime,
        this.projectName
      });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        id: json["id"],
        taskTitle: json["task_title"],
        projectName: json["project_name"],
        department: json["department"],
        type: json["type"],
        level: json["level"],
        assigned: json["assigned_names"],
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        taskDate: json["task_date"],
        taskTime: json["task_time"],
        createdTs: DateTime.parse(json["created_ts"]),
        updatedTs: DateTime.parse(json["updated_ts"]),
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "task_title": taskTitle,
        "department": department,
        "type": type,
        "level": level,
        "assigned_names": assigned,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_ts": createdTs,
        "updated_ts": updatedTs,
        "active": active,
        "task_time": taskTime,
        "task_date": taskDate,
        "project_name":projectName
      };
}
