class TrackModel {
  String? empId;
  String? unitId;
  String? lat;
  String? lng;
  String? createdTs;
  String? status;
  String? shift;
  String? unitName;
  String? image;

  TrackModel({
     this.empId,
     this.unitId,
     this.lat,
     this.lng,
     this.createdTs,
     this.status,
     this.shift,
     this.unitName,
     this.image,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) => TrackModel(
    empId: json["emp_id"],
    unitId: json["unit_id"],
    unitName: json["unit_name"],
    lat: json["lat"],
    lng: json["lng"],
    createdTs: json["created_ts"],
    status: json["status"],
    shift: json["shift"],
    image: json["image"],
  );
}


class TrackingModel {
  String? unitId;
  String? unitName;
  DateTime date;
  String firstStatus;
  String lastStatus;
  String firstLat;
  String lastLat;
  String firstLng;
  String lastLng;
  DateTime firstCreatedTs;
  DateTime lastCreatedTs;
  String firstImage;
  String lastImage;

  TrackingModel({
    this.unitId,
    this.unitName,
    required this.date,
    required this.firstStatus,
    required this.lastStatus,
    required this.firstLat,
    required this.lastLat,
    required this.firstLng,
    required this.lastLng,
    required this.firstCreatedTs,
    required this.lastCreatedTs,
    required this.firstImage,
    required this.lastImage,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) => TrackingModel(
    unitId: json["unit_id"],
    unitName: json["unit_name"],
    date: DateTime.parse(json["date"]),
    firstStatus: json["first_status"],
    lastStatus: json["last_status"],
    firstLat: json["first_lat"],
    lastLat: json["last_lat"],
    firstLng: json["first_lng"],
    lastLng: json["last_lng"],
    firstCreatedTs: DateTime.parse(json["first_created_ts"]),
    lastCreatedTs: DateTime.parse(json["last_created_ts"]),
    firstImage: json["first_image"],
    lastImage: json["last_image"],
  );
}
