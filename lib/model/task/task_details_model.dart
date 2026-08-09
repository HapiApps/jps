class TaskDetailsResponse {
  List<TaskResponse>? taskResponse;
  String? responseCode;
  String? result;
  String? responseMsg;

  TaskDetailsResponse({
    this.taskResponse,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory TaskDetailsResponse.fromJson(Map<String, dynamic> json) =>
      TaskDetailsResponse(
        taskResponse: List<TaskResponse>.from(
            json["Response"].map((x) => TaskResponse.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "Response": taskResponse == null
            ? []
            : List<dynamic>.from(taskResponse!.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class TaskResponse {
  String? id;
  String? taskTitle;
  String? department;
  String? type;
  String? level;
  String? taskDate;
  String? taskTime;
  String? assigned;
  String? status;
  String? createdBy;
  String? ownerName;
  String? ownerImage;
  String? updatedBy;
  DateTime? createdTs;
  DateTime? updatedTs;
  String? active;
  String? files;
  String? audio;
  String? assignedNames;
  String? assignedImages;
  String? projectName;

  TaskResponse(
      {this.id,
      this.taskTitle,
      this.department,
      this.type,
      this.level,
      this.taskDate,
      this.taskTime,
      this.assigned,
      this.status,
      this.createdBy,
      this.ownerName,
      this.ownerImage,
      this.updatedBy,
      this.createdTs,
      this.updatedTs,
      this.active,
      this.assignedNames,
      this.assignedImages,
      this.files,
      this.audio,
        this.projectName
      });

  factory TaskResponse.fromJson(Map<String, dynamic> json) => TaskResponse(
        id: json["id"],
        taskTitle: json["task_title"],
        department: json["department"],
        type: json["type"],
        level: json["level"],
        taskDate: json["task_date"],
        taskTime: json["task_time"],
        assigned: json["assigned"],
        status: json["status"],
        createdBy: json["created_by"],
        ownerName: json["ownername"],
        ownerImage: json["ownerimage"],
        updatedBy: json["updated_by"],
        createdTs: DateTime.parse(json["created_ts"]),
        updatedTs: DateTime.parse(json["updated_ts"]),
        active: json["active"],
        assignedNames: json["assigned_names"],
        assignedImages: json["assigned_images"],
        files: json["files"],
        audio: json["audio"],
    projectName: json["project_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "task_title": taskTitle,
        "department": department,
        "type": type,
        "level": level,
        "task_date": taskDate,
        "task_time": taskTime,
        "assigned": assigned,
        "status": status,
        "created_by": createdBy,
        "ownername": ownerName,
        "ownerimage": ownerImage,
        "updated_by": updatedBy,
        "created_ts": createdTs.toString(),
        "updated_ts": updatedTs.toString(),
        "active": active,
        "assigned_names": assignedNames,
        "assigned_images": assignedImages,
        "files": files,
        "audio": audio,
        "project_name": projectName,
      };
}
