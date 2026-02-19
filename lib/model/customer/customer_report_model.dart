class CustomerReportModel {
  String? comments;
  String? companyName;
  String? type;
  String? date;
  DateTime? createdTs;
  String? name;
  String? phoneNo;
  String? firstname;
  String? discussionPoints;
  String? actionTaken;
  String? lead;
  String? callVisitType;
  String? id;
  String? commentsList;
  String? commentsTs;
  String? typeNo;
  String? documents;
  String? createdBy;
  String? role;

  CustomerReportModel({
    this.comments,
    this.companyName,
    this.type,
    this.date,
    this.createdTs,
    this.name,
    this.phoneNo,
    this.firstname,
    this.discussionPoints,
    this.actionTaken,
    this.lead,
    this.callVisitType,
    this.id,
    this.commentsList,
    this.commentsTs,
    this.typeNo,
    this.documents,
    this.createdBy,
    this.role,
  });

  factory CustomerReportModel.fromJson(Map<String, dynamic> json) => CustomerReportModel(
    documents: json["documents"],
    type: json["type"],
    companyName: json["company_name"],
    comments: json["comments"],
    date: json["date"],
    createdTs: DateTime.parse(json["created_ts"]),
    name: json["name"],
    phoneNo: json["phone_no"],
    firstname: json["firstname"],
    discussionPoints: json["discussion_points"],
    actionTaken: json["action_taken"],
    lead: json["lead"],
    callVisitType: json["call_visit_type"],
    id: json["id"],
    commentsList: json["commentsList"],
    commentsTs: json["commentsTs"],
    typeNo: json["typeNo"],
    createdBy: json["created_by"],
    role: json["role"],
  );
}
