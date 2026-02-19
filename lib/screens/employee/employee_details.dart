import 'package:master_code/screens/employee/update_employee.dart';
import 'package:master_code/screens/employee/view_all_employees.dart';
import 'package:master_code/screens/employee/view_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/screens/common/fullscreen_photo.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:provider/provider.dart';
import '../../component/app_custom_data_text.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_network_image.dart';
import '../../component/custom_text.dart';
import '../../component/dotted_border.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../view_model/employee_provider.dart';
import '../attendance/user_attendance_report.dart';
import '../common/dashboard.dart';
import '../customer/employee_comments.dart';


class EmployeeDetails extends StatefulWidget {
  final String id;
  final String active;
  final String role;
  const EmployeeDetails({super.key, required this.id, required this.active, required this.role});

  @override
  State<EmployeeDetails> createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      Provider.of<EmployeeProvider>(context, listen: false).getUserDetails(id: widget.id);
    });
    super.initState();
  }
  String buildAddress() {
    List<String> parts = [
      Provider.of<EmployeeProvider>(context, listen: false).doorNo.text,
      Provider.of<EmployeeProvider>(context, listen: false).streetName.text,
      Provider.of<EmployeeProvider>(context, listen: false).comArea.text,
      Provider.of<EmployeeProvider>(context, listen: false).city.text,
      Provider.of<EmployeeProvider>(context, listen: false).state.toString(),
      Provider.of<EmployeeProvider>(context, listen: false).country.text,
      Provider.of<EmployeeProvider>(context, listen: false).pinCode.text,
    ];

    // Remove null or empty parts
    parts.removeWhere((part) => part == "null" || part.trim().isEmpty);

    // Join the remaining parts with a comma
    return parts.join(', ');
  }
  String buildAddress2() {
    List<String> parts = [
      Provider.of<EmployeeProvider>(context, listen: false).permanentDoNo.text,
      Provider.of<EmployeeProvider>(context, listen: false).permanentStreet.text,
      Provider.of<EmployeeProvider>(context, listen: false).permanentArea.text,
      Provider.of<EmployeeProvider>(context, listen: false).permanentCity.text,
      Provider.of<EmployeeProvider>(context, listen: false).permanentState.toString(),
      Provider.of<EmployeeProvider>(context, listen: false).permanentCountry.text,
      Provider.of<EmployeeProvider>(context, listen: false).permanentPin.text,
    ];

    // Remove null or empty parts
    parts.removeWhere((part) => part == "null" || part.trim().isEmpty);

    // Join the remaining parts with a comma
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<EmployeeProvider>(builder: (context,empProvider,_){
      return SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: Size(300, 50),
            child: CustomAppbar(text: "Employee Details",
              callback: (){
                utils.navigatePage(context, ()=>const DashBoard(child: ViewEmployees()));
              },),
          ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (!didPop) {
              utils.navigatePage(context, ()=>const DashBoard(child: ViewEmployees()));
            }
          },
          child: empProvider.refresh==false?
          const Loading()
          :Center(
            child: SizedBox(
              width: kIsWeb?webWidth:phoneWidth,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: (){
                            utils.navigatePage(context, ()=>FullScreen(image: empProvider.oldImage, isNetwork: true));
                          },
                          child: Container(
                              width: 50,height: 50,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.transparent,radius: 80,borderColor: colorsConst.primary
                              ),
                              child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey.shade200,
                                  child: empProvider.oldImage.toString().contains("uUsSrR")?
                                  NetworkImg(image: empProvider.oldImage, width: 50,):
                                  SvgPicture.asset(assets.profile)
                              )
                          ),
                        ),
                        InkWell(
                            onTap: (){
                              if(widget.id==localData.storage.read("id")){
                                utils.customDialog(
                                    context: context,
                                    title: "Editing an Admin account,proceed\n        with caution. After editing\n          Re-login will be required.",
                                    title2:"Do you want to continue?",
                                    callback: (){
                                      Navigator.pop(context);
                                      utils.navigatePage(context, ()=> DashBoard(child: UpdatedEmployee(id: widget.id.toString(), isDetailView: true,)));
                                    },
                                    isLoading: false,roundedLoadingButtonController: empProvider.signCtr);
                              }else {
                                utils.navigatePage(context, ()=> DashBoard(child: UpdatedEmployee(id: widget.id.toString(), isDetailView: true)));
                              }
                            },
                            child: Container(
                              width: 30,height: 30,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.grey.shade300,radius: 5
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SvgPicture.asset(assets.edit,width: 15,height: 15,),
                              ),
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(text: "${empProvider.signFirstName.text} ${empProvider.signMiddleName.text} ${empProvider.signLastName.text}",isBold: true,size: 15,colors: colorsConst.primary,),5.height,
                            CustomText(text: widget.role,colors: colorsConst.greyClr,isItalic: true,),5.height,
                          ],
                        ),
                        InkWell(
                            onTap: (){
                              if(widget.id==localData.storage.read("id")){
                                utils.customDialog(
                                    context: context,
                                    title: "Editing an Admin account,proceed\n        with caution. After editing\n          Re-login will be required.",
                                    title2:"Do you want to continue?",
                                    callback: (){
                                      Navigator.pop(context);
                                      empProvider.deleteReason.clear();
                                      utils.editDialog(
                                          context: context,
                                          name: empProvider.signFirstName.text,
                                          role: widget.role,
                                          reason: widget.active.toString()=="1"?"Deactivation":"Activate",
                                          title: 'Do you want to',
                                          title2: '${widget.active.toString()=="1"?"Deactivate":"Activate"} this employee?',
                                          roundedLoadingButtonController: empProvider.signCtr,
                                          textEditCtr: empProvider.deleteReason,
                                          callback: () {
                                            if(empProvider.deleteReason.text.trim().isEmpty){
                                              utils.toastBox(context: context, text: "Type a reason");
                                              empProvider.signCtr.reset();
                                            }else{
                                              empProvider.empActive(context,userId: widget.id.toString(), active: widget.active.toString()=="1"?'2':'1');
                                            }
                                          }
                                      );
                                    },
                                    isLoading: false,roundedLoadingButtonController: empProvider.signCtr);
                              }
                              else {
                                empProvider.deleteReason.clear();
                                utils.editDialog(
                                    context: context,
                                    name: empProvider.signFirstName.text,
                                    role: widget.role,
                                    reason: widget.active.toString()=="1"?"Deactivation":"Activate",
                                    title: 'Do you want to',
                                    title2: '${widget.active.toString()=="1"?"Deactivate":"Activate"} this employee?',
                                    roundedLoadingButtonController: empProvider.signCtr,
                                    textEditCtr: empProvider.deleteReason,
                                    callback: () {
                                      if(empProvider.deleteReason.text.trim().isEmpty){
                                        utils.toastBox(context: context, text: "Type a reason");
                                        empProvider.signCtr.reset();
                                      }else{
                                        empProvider.empActive(context,userId: widget.id.toString(), active: widget.active.toString()=="1"?'2':'1');
                                      }
                                    }
                                );
                              }
                            },
                            child: Container(
                              width: 30,height: 30,
                              decoration: customDecoration.baseBackgroundDecoration(
                                color: Colors.grey.shade300,radius: 5
                              ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: SvgPicture.asset(assets.inactive2,width: 15,height: 15,),
                                )))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(text: "Employment Status",colors: colorsConst.greyClr.withOpacity(0.5),),8.height,
                            CustomText(text: "Grade",colors: colorsConst.greyClr.withOpacity(0.5),),8.height,
                            CustomText(text: "Last Check-In",colors: colorsConst.greyClr.withOpacity(0.5),),8.height,
                            CustomText(text: "Total Visits",colors: colorsConst.greyClr.withOpacity(0.5),),
                          ],
                        ),
                        SizedBox(
                          // color: Colors.blue,
                          width: kIsWeb?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(text: widget.active=="1"?"Active":"Inactive",colors: widget.active=="1"?colorsConst.appDarkGreen:colorsConst.appRed),8.height,
                              CustomText(text: empProvider.gradeName.toString()!="null"&&empProvider.gradeName.toString()!=""?empProvider.gradeName.toString():"-",colors: colorsConst.greyClr.withOpacity(0.5),),8.height,
                              CustomText(text: empProvider.lastCheck.toString()!="null"&&empProvider.lastCheck.toString()!=""?DateFormat("hh:mm a, MMM d, yyyy").format(DateTime.parse(empProvider.lastCheck)):"-",colors: colorsConst.greyClr.withOpacity(0.5),),8.height,
                              CustomText(text: empProvider.commentCount.toString()!="null"&&empProvider.commentCount.toString()!=""?empProvider.commentCount:"-",colors: colorsConst.greyClr.withOpacity(0.5),),8.height,
                            ],
                          ),
                        ),
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                onTap: (){
                                  utils.makingPhoneCall(ph: empProvider.signMobileNumber.text);
                                },
                                child: Container(
                                  width: 30,height: 30,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                    color: Colors.grey.shade300,radius: 5
                                  ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SvgPicture.asset(assets.call,width: 15,height: 15,),
                                    ))),15.height,
                            InkWell(
                                // onTap: (){
                                //   // utils.makingEmail(mail: empProvider.signEmailid.text, context: context);
                                // },
                                child: Container(
                                  width: 30,height: 30,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                    color: Colors.grey.shade300,radius: 5
                                  ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SvgPicture.asset(assets.map,width: 15,height: 15,),
                                    ))),
                          ],
                        )
                      ],
                    ),
                    15.height,
                    const DotLine(),10.height,
                    const CustomText(text: "Personal Details",isBold: true,size: 17,),10.height,
                    if(empProvider.signReffered.text!="")
                    AppCustomDataText(title: "Mobile Number", value: empProvider.signMobileNumber.text,img: assets.call,isImg: true),
                    AppCustomDataText(title: "WhatsApp Number", value: empProvider.signWhatsappNumber.text),
                    AppCustomDataText(title: "Date Of Birth", value: empProvider.signDob.text),
                    AppCustomDataText(title: "Date Of Joining", value: empProvider.signJoiningDate.text),
                    AppCustomDataText(title: "Last Working Day", value: empProvider.lastWorkingday.text),
                    AppCustomDataText(title: "Blood Group", value: empProvider.blood.text),
                    AppCustomDataText(title: "Salary", value: empProvider.salary.text),
                    if(empProvider.signEmailid.text!="")
                    AppCustomDataText(title: "Email", value: empProvider.signEmailid.text,img: assets.email,isImg: true),
                    AppCustomDataText(title: "Address", value: buildAddress(),img: assets.location,isImg: true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: 80,
                            height: 80,
                            decoration: customDecoration.baseBackgroundDecoration(
                                radius:5,
                                borderColor: Colors.grey.shade300
                            ),
                            child: NetworkImg(image: empProvider.oldImage2, width: 10)),
                        Container(
                            width: 80,
                            height: 80,
                            decoration: customDecoration.baseBackgroundDecoration(
                                radius:5,
                                borderColor: Colors.grey.shade300
                            ),
                            child: NetworkImg(image: empProvider.oldImage3, width: 10)),
                        Container(
                            width: 80,
                            height: 80,
                            decoration: customDecoration.baseBackgroundDecoration(
                                radius:5,
                                borderColor: Colors.grey.shade300
                            ),
                            child: NetworkImg(image: empProvider.oldImage4, width: 10)),
                      ],
                    ),
                    10.height,
                    const DotLine(),10.height,
                    const CustomText(text: "Permanent Address",isBold: true,size: 17,),10.height,
                    AppCustomDataText(title: "Address", value: buildAddress2(),img: assets.location,isImg: true),
                    10.height,
                    const DotLine(),10.height,
                    const CustomText(text: "Emergency Contact Information",isBold: true,size: 17,),10.height,
                    AppCustomDataText(title: "Full Name", value: empProvider.signEmFname.text,img: assets.contact,isImg: true),
                    AppCustomDataText(title: "Phone Number", value: empProvider.signEmPh.text,img: assets.call,isImg: true),
                    AppCustomDataText(title: "Relation", value: empProvider.signEmRelation.text),
                    10.height,
                    const DotLine(),10.height,
                    const CustomText(text: "Job Information",isBold: true,size: 17,),10.height,
                    AppCustomDataText(title: "Last Organization", value: empProvider.signLastOrganization.text),
                    AppCustomDataText(title: "Referred By", value: empProvider.signReffered.text,img: assets.contact,isImg: true),
                    10.height,
                    const DotLine(),10.height,
                    const CustomText(text: "Reference",isBold: true,size: 17,),10.height,
                    AppCustomDataText(title: "Reference 1 Name", value: empProvider.signReFname1.text,img: assets.contact,isImg: true),
                    AppCustomDataText(title: "Reference 1 No", value: empProvider.signRePh1.text,img: assets.call,isImg: true),
                    AppCustomDataText(title: "Reference 2 Name", value: empProvider.signReFname2.text,img: assets.contact,isImg: true),
                    AppCustomDataText(title: "Reference 2 No", value: empProvider.signRePh2.text,img: assets.call,isImg: true),
                    10.height,
                    const DotLine(),10.height,
                    const CustomText(text: "KYC",isBold: true,size: 17,),10.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: 80,
                            height: 80,
                            decoration: customDecoration.baseBackgroundDecoration(
                                radius:5,
                                borderColor: Colors.grey.shade300
                            ),
                            child: NetworkImg(image: empProvider.oldImage5, width: 10)),
                        Container(
                            width: 80,
                            height: 80,
                            decoration: customDecoration.baseBackgroundDecoration(
                                radius:5,
                                borderColor: Colors.grey.shade300
                            ),
                            child: NetworkImg(image: empProvider.oldImage6, width: 10)),
                        Container(
                            width: 80,
                            height: 80,
                            decoration: customDecoration.baseBackgroundDecoration(
                                radius:5,
                                borderColor: Colors.grey.shade300
                            ),
                            child: NetworkImg(image: empProvider.oldImage7, width: 10)),
                      ],
                    ),20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomLoadingButton(callback: (){
                          utils.navigatePage(context, ()=> DashBoard(child:EmployeeFullHistory(id:widget.id,active: widget.active,roleName: widget.role,)));
                        }, isLoading: false,
                          backgroundColor: colorsConst.blueClr,
                          radius: 5, width: kIsWeb?webWidth/2.1:phoneWidth/2.1,text: "View Full History",),
                        CustomLoadingButton(callback: (){
                          utils.navigatePage(context, ()=> DashBoard(child: ViewLog(id: widget.id.toString())));
                        }, isLoading: false, backgroundColor: colorsConst.appYellow,
                          radius: 5, width: kIsWeb?webWidth/2.1:phoneWidth/2.1,text: "View Activities",),
                      ],
                    ),
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomLoadingButton(callback: (){
                          utils.navigatePage(context, ()=> DashBoard(child:
                          UserAttendanceReport(id:widget.id,name: empProvider.signFirstName.text,active: widget.active,roleName: widget.role)));
                        }, isLoading: false, backgroundColor: Colors.deepOrange,
                          radius: 5, width: kIsWeb?webWidth/2.1:phoneWidth/2.1,text: "Attendance",),130.width
                      ],
                    ),
                    20.height,
                  ],
                ),
              ),
                ),
          ),
        )
      ),
    );
    });
  }
}
