class HolyDaysModel {
  String? id;
  String? levDate;
  String? reason;

  HolyDaysModel({
     this.id,
     this.levDate,
     this.reason,
  });

  factory HolyDaysModel.fromJson(Map<String, dynamic> json) => HolyDaysModel(
    id: json["id"],
    levDate: json["lev_date"],
    reason: json["reason"],
  );
}
