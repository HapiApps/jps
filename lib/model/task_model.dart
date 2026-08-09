import 'package:flutter/cupertino.dart';

class TaskModel {
  TaskModel({
    this.id,
    this.toFirstname,
    this.toSureName,
    this.frFirstname,
    this.frSurname,
    this.mobileNumber,
    this.emailId,
    this.role,
    this.empIdFr,
    this.empIdTo,
    this.task,
    this.startTs,
    this.endTs,
    this.status,
    this.taskId,
    this.taskType,
    this.taskReason,
  });

  String? id;
  String? toFirstname;
  String? toSureName;
  String? frFirstname;
  String? frSurname;
  String? mobileNumber;
  String? emailId;
  String? role;
  String? empIdFr;
  String? empIdTo;
  String? task;
  String? startTs;
  String? endTs;
  String? status;
  String? taskId;
  String? taskType;
  String? taskReason;

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json["id"],
    toFirstname: json["to_firstname"],
    toSureName: json["to_surename"],
    frFirstname: json["fr_firstname"],
    frSurname: json["fr_surname"],
    mobileNumber: json["mobile_number"],
    emailId: json["email_id"],
    role: json["role"],
    empIdFr: json["emp_id_fr"],
    empIdTo: json["emp_id_to"],
    task: json["task"],
    startTs: json["start_ts"],
    endTs: json["end_ts"],
    status: json["status"],
    taskId: json["task_id"],
    taskType: json["task_type"],
    taskReason: json["task_res"],
  );
}


class AddTaskModel {
  TextEditingController taskCtr = TextEditingController();

  AddTaskModel({
    required this.taskCtr
  });

  factory AddTaskModel.fromJson(Map<String, dynamic> json) => AddTaskModel(
    taskCtr: json["taskCtr"],
  );
}