import 'package:get_storage/get_storage.dart';

final LocalData localData = LocalData._();
class LocalData{

  LocalData._();
  var storage = GetStorage();
  // String cosId='202501';
  String versionNumber = "0.0.23";
}