class TemplateModel {
  final String id;
  final String cosId;
  final String? templateName;
  final String? subject;
  final String? message;
  final String? active;
  final String? updatedBy;
  final String? createdBy;
  final String? createdTs;
  final String? updatedTs;

  TemplateModel({
    required this.id,
    required this.cosId,
    this.updatedBy,
    this.createdBy,
    this.createdTs,
    this.templateName,
    this.subject,
    this.message,
    this.active,
    this.updatedTs,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] ?? '',
      cosId: json['cos_id'] ?? '',
      templateName: json['template_name'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      active: json['active'] ?? '',
      updatedBy: json['updated_by'],
      createdBy: json['created_by'] ?? '',
      createdTs: json['created_ts'] ?? '',
      updatedTs: json['updated_ts'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cos_id': cosId,
      'template_name': templateName,
      'subject': subject,
      'message': message,
      'active': active,
      'updated_by': updatedBy,
      'created_by': createdBy,
      'created_ts': createdTs,
      'updated_ts': updatedTs,
    };
  }
}
