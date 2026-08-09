class RulesModel {
  String? typeId;
  String? type;
  String? days;

  RulesModel({
     this.typeId,
     this.type,
     this.days,
  });

  factory RulesModel.fromJson(Map<String, dynamic> json) => RulesModel(
    typeId: json["type_id"],
    type: json["type"],
    days: json["days"],
  );
}
