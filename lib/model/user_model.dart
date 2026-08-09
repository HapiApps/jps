// class UserModel {
//   String? bbhLimit;
//   String? headRole;
//   String? status;
//   String? userImage;
//   String? lastWorkingDay;
//   String? aadharUrl;
//   String? panUrl;
//   String? chequeUrl;
//   String? licenseUrl;
//   String? voterUrl;
//   String? id;
//   String? empCode;
//   String? prefixes;
//   String? fName;
//   String? mName;
//   String? lName;
//   String? mobileNumber;
//   String? whatsappNumber;
//   String? emailId;
//   String? password;
//   String? role;
//   String? approverLvl;
//   String? roleName;
//   String? dateOfBirth;
//   String? blood;
//   String? dateOfJoining;
//   String? adhaar;
//   String? pan;
//   String? presentAddressId;
//   String? permanentAddressId;
//   String? relation;
//   String? prefixes_2;
//   String? relationName;
//   String? emgName;
//   String? emgNo;
//   String? emgRelation;
//   String? emgAddressId;
//   String? lastOrganization;
//   String? ref1Name;
//   String? ref1No;
//   String? ref2Name;
//   String? ref2No;
//   String? referredBy;
//   String? maritalStatus;
//   String? presentAddressLine1;
//   String? presentAddressLine2;
//   String? presentArea;
//   String? presentCity;
//   String? presentState;
//   String? presentCountry;
//   String? presentPincode;
//   String? presentLat;
//   String? presentLng;
//   String? permanentAddressLine1;
//   String? permanentAddressLine2;
//   String? permanentArea;
//   String? permanentCity;
//   String? permanentState;
//   String? permanentCountry;
//   String? permanentPincode;
//   String? permanentLat;
//   String? permanentLng;
//   String? houseType;
//   String? createdTs;
//   String? bbhBank;
//   String? shState;
//   String? aadharBack;
//   String? token;
//   String? salary;
//   String? shId;
//   String? shName;
//   UserModel({
//     this.headRole,
//     this.blood,
//     this.bbhLimit,
//     this.status,
//     this.lastWorkingDay,
//     this.userImage,
//     this.aadharUrl,
//     this.chequeUrl,
//     this.panUrl,
//     this.licenseUrl,
//     this.voterUrl,
//     this.id,
//     this.empCode,
//     this.prefixes,
//     this.fName,
//     this.mName,
//     this.lName,
//     this.mobileNumber,
//     this.whatsappNumber,
//     this.emailId,
//     this.password,
//     this.role,
//     this.approverLvl,
//     this.roleName,
//     this.dateOfBirth,
//     this.dateOfJoining,
//     this.adhaar,
//     this.pan,
//     this.presentAddressId,
//     this.permanentAddressId,
//     this.relation,
//     this.prefixes_2,
//     this.relationName,
//     this.emgName,
//     this.emgNo,
//     this.emgRelation,
//     this.emgAddressId,
//     this.lastOrganization,
//     this.ref1Name,
//     this.ref1No,
//     this.ref2Name,
//     this.ref2No,
//     this.referredBy,
//     this.maritalStatus,
//     this.presentAddressLine1,
//     this.presentAddressLine2,
//     this.presentArea,
//     this.presentCity,
//     this.presentState,
//     this.presentCountry,
//     this.presentPincode,
//     this.presentLat,
//     this.presentLng,
//     this.permanentAddressLine1,
//     this.permanentAddressLine2,
//     this.permanentArea,
//     this.permanentCity,
//     this.permanentState,
//     this.permanentCountry,
//     this.permanentPincode,
//     this.permanentLat,
//     this.permanentLng,
//     this.houseType,
//     this.createdTs,
//     this.aadharBack,
//     this.shState,
//     this.bbhBank,
//     this.token,
//     this.salary,
//     this.shId,
//     this.shName
//   });
//   factory UserModel.fromJson(Map<String, dynamic> json){
//     return UserModel(
//         blood: json["blood_group"],
//         headRole: json["head_role"],
//         bbhLimit: json["BBH_Limit"],
//         status: json["status"],
//         lastWorkingDay: json["last_working_day"],
//         userImage: json["user_image"],
//         aadharUrl: json["aadhar_url"],
//         panUrl: json["pan_url"],
//         chequeUrl: json["cheque_url"],
//         licenseUrl: json["license_url"],
//         voterUrl: json["voter_url"],
//         id: json["id"],
//         empCode: json["emp_cd"],
//         prefixes: json["prefixes"],
//         fName: json["f_name"],
//         mName: json["m_name"],
//         lName: json["l_name"],
//         mobileNumber: json["mobile_number"],
//         whatsappNumber: json["whatsapp_number"],
//         emailId: json["email_id"],
//         password: json["password"],
//         role: json["role"],
//         approverLvl: json["approver_lvl"],
//         roleName: json["role_name"],
//         dateOfBirth: json["date_of_birth"],
//         dateOfJoining: json["date_of_joining"],
//         adhaar: json["adhaar"],
//         pan: json["pan"],
//         presentAddressId: json["pres_address_id"],
//         permanentAddressId: json["perm_address_id"],
//         relation: json["relation"],
//         prefixes_2: json["prefixes_2"],
//         relationName: json["relation_name"],
//         emgName: json["emg_name"],
//         emgNo: json["emg_no"],
//         emgRelation: json["emg_relation"],
//         emgAddressId: json["emg_address_id"],
//         lastOrganization: json["last_org"],
//         ref1Name: json["ref1_name"],
//         ref1No: json["ref1_no"],
//         ref2Name: json["ref2_name"],
//         ref2No: json["ref2_no"],
//         referredBy: json["referred_by"],
//         maritalStatus: json["marital_status"],
//         presentAddressLine1: json["pres_address_line_1"],
//         presentAddressLine2: json["pres_address_line_2"],
//         presentArea: json["pres_area"],
//         presentCity: json["pres_city"],
//         presentState: json["pres_state"],
//         presentCountry: json["pres_country"],
//         presentPincode: json["pres_pincode"],
//         presentLat: json["pres_lat"],
//         presentLng: json["pres_lng"],
//         permanentAddressLine1: json["perm_address_line_1"],
//         permanentAddressLine2: json["perm_address_line_2"],
//         permanentArea: json["perm_area"],
//         permanentCity: json["perm_city"],
//         permanentState: json["perm_state"],
//         permanentCountry: json["perm_country"],
//         permanentPincode: json["perm_pincode"],
//         permanentLat: json["perm_lat"],
//         permanentLng: json["perm_lng"],
//         createdTs: json["created_ts"],
//         houseType: json["house_type"],
//         aadharBack: json["aadhar_back"],
//         shState: json["SH_state"],
//         bbhBank: json["BBH_bank"],
//         token: json["token"],
//         salary: json["salary"],
//         shId: json["sh_id"],
//         shName: json["sh_name"]
//     );
//   }
// }


// To parse this JSON data, do
//
//     final loginObj = loginObjFromJson(jsonString);

import 'dart:convert';

LoginObj loginObjFromJson(String str) => LoginObj.fromJson(json.decode(str));

String loginObjToJson(LoginObj data) => json.encode(data.toJson());

class LoginObj {
  LoginObj({
    this.userId,
    this.firstname,
    this.surname,
    this.mobileNumber,
    this.emailId,
    this.role,
  });

  String? userId;
  String? firstname;
  String? surname;
  String? mobileNumber;
  String? emailId;
  String? role;

  factory LoginObj.fromJson(Map<String, dynamic> json) => LoginObj(
    userId: json["user_id"],
    firstname: json["firstname"],
    surname: json["surname"],
    mobileNumber: json["mobile_number"],
    emailId: json["email_id"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "firstname": firstname,
    "surname": surname,
    "mobile_number": mobileNumber,
    "email_id": emailId,
    "role": role,
  };
}

class UserModel {
  UserModel({
     this.id,
     this.firstname,
     this.mobileNumber,
     this.surname,
     this.doj,
     this.password,
     this.role,
     this.roleName,
     this.referredBy,
     this.emailId,
     this.department,
     this.active,
     this.createdTs,
     this.selected,
     this.esi,
     this.pf,
     this.salary,
     this.grade,
  });

  String? id;
  String? firstname;
  String? surname;
  String? doj;
  String? mobileNumber;
  String? password;
  String? role;
  String? roleName;
  String? referredBy;
  String? emailId;
  String? department;
  String? active;
  String? createdTs;
  bool? selected;
  String? esi;
  String? pf;
  String? salary;
  String? grade;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    grade: json["grade"],
    pf: json["pf"],
    esi: json["esi"],
    salary: json["salary"],
    id: json["id"],
    active: json["active"],
    firstname: json["firstname"],
    surname: json["surname"],
    referredBy: json["referred_by"],
    mobileNumber: json["mobile_number"],
    password: json["password"],
    role: json["role"],
    roleName: json["rolename"],
    emailId: json["email_id"],
    department: json["department"],
    createdTs: json["created_ts"],
    selected: false,
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "surname": surname,
    "doj": doj,
    "mobile_number": mobileNumber,
    "password": password,
    "role": role,
    "rolename": roleName,
    "referred_by": referredBy,
    "email_id": emailId,
    "department": department,
    "active": active,
    "created_ts": createdTs,
  };

  @override
  String toString() {
    return firstname ?? '';
  }
}

class UserDetail {
  String? id;
  String? image;
  String? firstname;
  String? surname;
  String? mobileNumber;
  String? referredBy;
  String? role;
  String? password;
  String? emailId;
  String? roleName;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? country;
  String? state;
  String? pincode;
  String? addressId;
  String? lastCheckin;
  String? commentCount;
  String? gradeId;
  String? grade;
  String? middleName;

  String? aadharUrl;
  String? panUrl;
  String? chequeUrl;
  String? licenseUrl;
  String? voterUrl;
  String? empCode;
  String? prefixes;
  String? whatsappNumber;
  String? dateOfBirth;
  String? blood;
  String? dateOfJoining;
  String? adhaar;
  String? pan;
  String? relation;
  String? prefixes_2;
  String? relationName;
  String? emgName;
  String? emgNo;
  String? emgRelation;
  String? emgAddressId;
  String? lastOrganization;
  String? ref1Name;
  String? ref1No;
  String? ref2Name;
  String? ref2No;
  String? maritalStatus;
  String? houseType;
  String? salary;
  String? aadharBack;
  String? presentArea;
  String? permanentAddressLine1;
  String? permanentAddressLine2;
  String? permanentArea;
  String? permanentCity;
  String? permanentState;
  String? permanentCountry;
  String? permanentPincode;
  String? lastWorkingDay;
  UserDetail({
    this.aadharBack,
    this.salary,
    this.houseType,
    this.presentArea,
    this.permanentAddressLine1,
    this.permanentAddressLine2,
    this.permanentArea,
    this.permanentCity,
    this.permanentState,
    this.permanentCountry,
    this.permanentPincode,
    this.maritalStatus,
    this.lastOrganization,
    this.ref1Name,
    this.ref1No,
    this.ref2Name,
    this.ref2No,
    this.relation,
    this.prefixes_2,
    this.relationName,
    this.emgName,
    this.emgNo,
    this.emgRelation,
    this.whatsappNumber,
    this.dateOfBirth,
    this.dateOfJoining,
    this.adhaar,
    this.pan,
    this.empCode,
    this.prefixes,
    this.aadharUrl,
    this.chequeUrl,
    this.panUrl,
    this.licenseUrl,
    this.voterUrl,
    this.blood,
    this.id,
    this.image,
    this.firstname,
    this.surname,
    this.mobileNumber,
    this.referredBy,
    this.role,
    this.password,
    this.emailId,
    this.roleName,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.country,
    this.state,
    this.pincode,
    this.addressId,
    this.lastCheckin,
    this.commentCount,
    this.gradeId,
    this.grade,
    this.middleName,
    this.lastWorkingDay,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
    blood: json["blood_group"],
    lastWorkingDay: json["last_working_day"],
    aadharUrl: json["aadhar_url"],
    panUrl: json["pan_url"],
    chequeUrl: json["cheque_url"],
    licenseUrl: json["license_url"],
    voterUrl: json["voter_url"],
    empCode: json["emp_cd"],
    prefixes: json["prefixes"],
    whatsappNumber: json["whatsapp_number"],
    dateOfBirth: json["date_of_birth"],
    dateOfJoining: json["date_of_joining"],
    adhaar: json["adhaar"],
    pan: json["pan"],
    relation: json["relation"],
    prefixes_2: json["prefixes_2"],
    relationName: json["relation_name"],
    emgName: json["emg_name"],
    emgNo: json["emg_no"],
    emgRelation: json["emg_relation"],
    lastOrganization: json["last_org"],
    ref1Name: json["ref1_name"],
    ref1No: json["ref1_no"],
    ref2Name: json["ref2_name"],
    ref2No: json["ref2_no"],
    maritalStatus: json["marital_status"],
    presentArea: json["pres_area"],
    permanentAddressLine1: json["perm_address_line_1"],
    permanentAddressLine2: json["perm_address_line_2"],
    permanentArea: json["perm_area"],
    permanentCity: json["perm_city"],
    permanentState: json["perm_state"],
    permanentCountry: json["perm_country"],
    permanentPincode: json["perm_pincode"],
    houseType: json["house_type"],
    aadharBack: json["aadhar_2_url"],
    salary: json["salary"],
    id: json["id"],
    image: json["image"],
    firstname: json["firstname"],
    middleName: json["m_name"],
    surname: json["surname"],
    mobileNumber: json["mobile_number"],
    referredBy: json["referred_by"],
    role: json["role"],
    password: json["password"],
    emailId: json["email_id"],
    roleName: json["rolename"],
    addressLine1: json["address_line_1"],
    addressLine2: json["address_line_2"],
    city: json["city"],
    country: json["country"],
    state: json["state"],
    pincode: json["pincode"],
    addressId: json["address_id"],
    lastCheckin: json["last_checkin"],
    commentCount: json["comment_count"],
    gradeId: json["grade_id"],
    grade: json["grade"],
  );
}
