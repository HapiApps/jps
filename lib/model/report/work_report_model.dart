class ReportModel {
  String? id;
  String? projectId;
  String? engineerId;
  String? date;
  String? planWork;
  String? finishedWork;
  String? pendingWork;
  String? createdBy;
  DateTime? createdTs;
  dynamic users;
  dynamic inTimes;
  dynamic outTimes;
  String? fName;
  String? engineerName;
  String? projectName;
  String? documents;
  String? comment;

  ReportModel({
    this.id,
    this.projectId,
    this.engineerId,
    this.date,
    this.planWork,
    this.finishedWork,
    this.pendingWork,
    this.createdBy,
    this.createdTs,
    this.users,
    this.inTimes,
    this.outTimes,
    this.fName,
    this.engineerName,
    this.projectName,
    this.documents,
    this.comment,
  });

  factory ReportModel.fromJson(Map<String?, dynamic> json) => ReportModel(
    id: json["id"],
    projectId: json["project_id"],
    engineerId: json["engineer_id"],
    date: json["date"],
    planWork: json["plan_work"],
    finishedWork: json["finished_work"],
    pendingWork: json["pending_work"],
    createdBy: json["created_by"],
    createdTs: DateTime.parse(json["created_ts"]),
    users: json["users"],
    inTimes: json["intimes"],
    outTimes: json["outtimes"],
    fName: json["f_name"],
    engineerName: json["engineerName"],
    projectName: json["projectName"],
    documents: json["documents"],
    comment: json["comment"],
  );
}
