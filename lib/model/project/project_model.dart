class ProjectModel {
  String? id;
  String? name;
  String? startDate;
  String? endDate;
  String? addressLine1;
  String? addressLine2;
  String? area;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? lat;
  String? lng;
  String? betweenMtr;
  String? createdTs;
  String? isChecked;
  String? metre;

  ProjectModel({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.addressLine1,
    this.addressLine2,
    this.area,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.lat,
    this.lng,
    this.betweenMtr,
    this.createdTs,
    this.isChecked,
    this.metre
  });

  factory ProjectModel.fromJson(Map<String?, dynamic> json) => ProjectModel(
    id: json["id"],
    name: json["company_name"],
    startDate: json["start_date"],
    endDate: json["end_date"],
    addressLine1: json["address_line_1"],
    addressLine2: json["address_line_2"],
    area: json["area"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    pincode: json["pincode"],
    lat: json["lat"],
    lng: json["lng"],
    betweenMtr: json["metre"],
    createdTs: json["created_ts"],
    isChecked: json["is_checked_out"],
    metre: json["metre"]
  );
}
