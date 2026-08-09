class DTaskModel {
  String? id;
  String? taskTitle;
  String? taskDate;
  String? companyName;
  String? creator;
  String? status;
  String? type;
  String? commentsFull;
  String? assignedNames;

  DTaskModel({
    this.id,
    this.taskTitle,
    this.taskDate,
    this.companyName,
    this.creator,
    this.status,
    this.type,
    this.commentsFull,
    this.assignedNames,
  });

  factory DTaskModel.fromJson(Map<String, dynamic> json) {
    return DTaskModel(
      id: json["id"]?.toString(),
      taskTitle: json["task_title"]?.toString(),
      taskDate: json["task_date"]?.toString(),
      companyName: json["company_name"]?.toString(),
      creator: json["creator"]?.toString(),
      status: json["statval"]?.toString(),
      type: json["type"]?.toString(),
      commentsFull: json["comments_full"]?.toString(),
      assignedNames: json["assigned_names"]?.toString(),
    );
  }
}