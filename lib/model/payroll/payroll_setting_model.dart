class PayrollSettingModel {
  String? id;
  String? esi;
  String? pf;
  String? basicDa;
  String? hra;
  String? conv;
  String? wa;
  String? otRate;
  String? addedBy;
  String? createdTs;
  String? updatedTs;
  String? active;

  PayrollSettingModel({
    this.id,
    this.esi,
    this.pf,
    this.basicDa,
    this.hra,
    this.conv,
    this.wa,
    this.otRate,
    this.addedBy,
    this.createdTs,
    this.updatedTs,
    this.active,
  });

  factory PayrollSettingModel.fromJson(Map<String?, dynamic> json) => PayrollSettingModel(
    id: json["id"],
    esi: json["ESI"],
    pf: json["PF"],
    basicDa: json["Basic_DA"],
    hra: json["HRA"],
    conv: json["CONV"],
    wa: json["WA"],
    otRate: json["OT_Rate"],
    addedBy: json["added_by"],
    createdTs: json["created_ts"],
    updatedTs: json["updated_ts"],
    active: json["active"],
  );

}
