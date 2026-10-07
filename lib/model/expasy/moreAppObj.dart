import 'dart:convert';

List<MoreAppsObj> moreAppsObjFromJson(String str) => List<MoreAppsObj>.from(
    json.decode(str).map((x) => MoreAppsObj.fromJson(x)));

String moreAppsObjToJson(List<MoreAppsObj> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MoreAppsObj {
  MoreAppsObj({
    this.id,
    this.appName,
    this.bundleId,
    this.appUrl,
    this.iconUrl,
    this.category,
    this.isAvailable,
    this.createdAt,
    this.appDesc,
  });

  String? id;
  String? appName;
  String? bundleId;
  String? appUrl;
  String? iconUrl;
  String? category;
  String? isAvailable;
  String? createdAt;
  String? appDesc;

  factory MoreAppsObj.fromJson(Map<String, dynamic> json) => MoreAppsObj(
    id: json["id"],
    appName: json["app_name"],
    bundleId: json["bundle_id"],
    appUrl: json["app_url"],
    iconUrl: json["icon_url"],
    category: json["category"],
    isAvailable: json["is_available"],
    createdAt: json["created_at"],
    appDesc: json["app_desc"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "app_name": appName,
    "bundle_id": bundleId,
    "app_url": appUrl,
    "icon_url": iconUrl,
    "category": category,
    "is_available": isAvailable,
    "created_at": createdAt,
    "app_desc": appDesc,
  };
}