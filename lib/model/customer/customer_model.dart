class CustomerModel {
  String? userId;
  String? customerId;
  String? addressId;
  String? shopName;
  String? firstName;
  String? emergencyName;
  String? mobileNumber;
  String? phoneNumber;
  String? emergencyNumber;
  String? emailId;
  String? doorNo;
  String? landmark;
  String? city;
  String? country;
  String? state;
  String? pincode;
  String? img1;
  String? img2;
  String? area;
  String? type;
  String? lat;
  String? lng;
  String? referredBy;
  String? productDiscussion;
  String? discussionPoint;
  String? points;
  String? companyName;
  String? quotationStatus;
  String? quotationRequired;
  String? visitType;
  String? status;
  String? leadStatus;
  String? leadId;
  String? visitId;
  String? roles;
  String? mainPerson;
  String? department;
  String? designation;
  String? isChecked;
  String? addedBy;
  String? role;
  String? createdTs;
  String? creator;
  String? visitCount;
  String? startDate;
  String? endDate;

  CustomerModel({
    this.userId,
    this.customerId,
    this.addressId,
    this.leadId,
    this.visitId,
    this.shopName,
    this.firstName,
    this.emergencyName,
    this.mobileNumber,
    this.phoneNumber,
    this.emergencyNumber,
    this.emailId,
    this.doorNo,
    this.landmark,
    this.img1,
    this.img2,
    this.pincode,
    this.city,
    this.state,
    this.area,
    this.country,
    this.type,
    this.lat,
    this.lng,
    this.referredBy,
    this.productDiscussion,
    this.discussionPoint,
    this.points,
    this.companyName,
    this.visitType,
    this.status,
    this.quotationStatus,
    this.quotationRequired,
    this.leadStatus,
    // this.check="0",
    this.mainPerson,
    this.department,
    this.designation,
    this.isChecked,
    this.addedBy,
    this.role,
    this.createdTs,
    this.creator,
    this.visitCount,
    this.roles,
    this.startDate,
    this.endDate,
  });

  factory CustomerModel.fromJson(Map<String,dynamic> json) => CustomerModel(
    startDate: json["start_date"],
    endDate: json["end_date"],
    addressId: json["address_id"],
    customerId: json["customer_id"],
    leadId: json["lead_id"],
    visitId: json["visit_id"],
    userId: json["user_id"],
    shopName: json["shop_name"],
    firstName: json["firstname"],
    emergencyName: json["emergency_name"],
    mobileNumber: json["mobile_number"],
    phoneNumber: json["phone"],
    emailId: json["email_id"],
    emergencyNumber: json["emergency_number"],
    doorNo: json["door_no"],
    landmark: json["landmark_1"],
    img1: json["img1"],
    img2: json["img2"],
    pincode: json["pincode"],
    city: json["city"],
    state: json["state"],
    area: json["area"],
    country: json["country"],
    type: json["shop_type"],
    lat: json["lat"],
    lng: json["lng"],
    referredBy: json["referred_by"],
    productDiscussion: json["product_discussion"],
    discussionPoint: json["discussion_point"],
    points: json["points"],
    companyName: json["company_name"],
    leadStatus: json["lead_status"],
    status: json["status"],
    visitType: json["visit_type"],
    quotationStatus: json["quotation_status"],
    quotationRequired: json["quotation_required"],
    // check: json["check"],
    designation: json["designation"],
    department: json["department"],
    mainPerson: json["main_person"],
    isChecked: json["is_checked_out"],
    addedBy: json["addedBy"],
    role: json["role"],
    createdTs: json["created_ts"].toString(),
    creator: json["creator"],
    visitCount: json["value_typecount"].toString(),
    roles: json["roles"],
  );


}


