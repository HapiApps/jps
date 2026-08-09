
import 'dart:convert';


AddDocumentModel addDocumentModelFromJson(String str) => AddDocumentModel.fromJson(json.decode(str));

String addDocumentModelToJson(AddDocumentModel data) => json.encode(data.toJson());

class AddDocumentModel {
  String imagePath = "assets/images/doc.jpg";

  AddDocumentModel({
    this.imagePath = "assets/images/doc.jpg",
  });

  factory AddDocumentModel.fromJson(Map<String, dynamic> json) => AddDocumentModel(
    imagePath: json["imagePath"],
  );

  Map<String, dynamic> toJson() => {
    "imagePath": imagePath,
  };
}
