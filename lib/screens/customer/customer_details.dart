import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/model/customer/customer_model.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/app_custom_data_text.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../component/dotted_border.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/customer_provider.dart';
import '../common/dashboard.dart';
import 'comments/customer_comments.dart';


class CustomerDetails extends StatefulWidget {
  final String id;
  const CustomerDetails({super.key, required this.id});

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<CustomerProvider>(context, listen: false).getCustomerDetail(widget.id,false,true);
    });
    super.initState();
  }
  bool isAddressEmpty(String? doorNo, String? area, String? city, String? state, String? pincode) {
    return [doorNo, area, city, state, pincode].every((e) => e == null || e.isEmpty || e == "null");
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<CustomerProvider>(builder: (context,custProvider,_){
      return SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 60),
          child: CustomAppbar(text: constValue.customerDetails),
        ),
        body: custProvider.refresh==false?
        const Loading()
        :Center(
          child: SizedBox(
            width: kIsWeb?webWidth:phoneWidth,
            child: ListView.builder(
                itemCount: custProvider.customerDetailData.length,
                itemBuilder: (context,index){
                  CustomerModel data = custProvider.customerDetailData[index];
                  var idList=data.customerId.toString().split('||');
                  var usersList=data.firstName.toString().split('||');
                  var phoneList=data.phoneNumber.toString().split('||');
                  var phoneList2=data.mobileNumber.toString().split('||');
                  var emailList=data.emailId.toString().split('||');
                  var designation=data.designation.toString().split('||');
                  var department=data.department.toString().split('||');
                  var mainPerson=data.mainPerson.toString().split('||');
                  String formattedAddress = [
                    if (data.doorNo != null && data.doorNo!.isNotEmpty && data.doorNo != "null") data.doorNo,
                    if (data.area != null && data.area!.isNotEmpty && data.area != "null") data.area,
                    if (data.city != null && data.city!.isNotEmpty && data.city != "null") data.city,
                    if (data.state != null && data.state!.isNotEmpty && data.state != "null") data.state,
                    if (data.pincode != null && data.pincode!.isNotEmpty && data.pincode != "null") data.pincode,
                  ].join(", "); // Join the non-empty values with ", "
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: CustomText(text: data.companyName.toString(),isBold: true)),5.height,
                      if(formattedAddress!="")
                      Center(child: SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: CustomText(text: formattedAddress,colors: Colors.grey,))),
                      15.height,
                      SizedBox(
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:usersList.length,
                            itemBuilder: (context,index){
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Container(
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,radius: 5
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(kIsWeb?10:2, 0, 0, 0),
                                    child: Column(
                                      children: [
                                        mainPerson[index].toString()=="1"?
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          child: Row(
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // 10.width,
                                              Icon(Icons.star,size: 10,color: colorsConst.appGreen,),
                                              SizedBox(
                                                  width: kIsWeb?webWidth/2.5:phoneWidth/2.6,
                                                  // color: Colors.pink,
                                                  child: CustomText(text: constValue.contactName,colors: Colors.grey,)),
                                              SizedBox(
                                                width: kIsWeb?webWidth/1.8:phoneWidth/1.8,
                                                // color: Colors.yellow,
                                                child: CustomText(text: usersList[index].toString()=="null"?"":usersList[index].toString().trim(),
                                                  isBold: true,),
                                              )
                                            ],
                                          ),
                                        ):
                                        AppCustomDataText(title: constValue.contactName, value: usersList[index].toString()=="null"?"":usersList[index].toString().trim(),),
                                        if(designation[index].toString()!="null"&&designation[index].toString()!="")
                                        AppCustomDataText(title: "Designation", value: designation[index].toString()=="null"?"":designation[index].toString(),),
                                        if(department[index].toString()!="null"&&department[index].toString()!="")
                                        AppCustomDataText(title: "Department", value: department[index].toString()=="null"?"":department[index].toString(),),
                                        if(phoneList[index].toString()!="null"&&phoneList[index].toString()!="")
                                        AppCustomDataText(
                                          title: constValue.phoneNumber, value: phoneList[index].toString()=="null"?"":phoneList[index].toString(),
                                          ),
                                        if(phoneList2[index].toString()!="null"&&phoneList2[index].toString()!="")
                                          AppCustomDataText(
                                          title: constValue.mobileNumber, value: phoneList2[index].toString()=="null"?"":phoneList2[index].toString(),
                                          ),
                                        if(emailList[index].toString()!="null"&&emailList[index].toString()!="")
                                        AppCustomDataText(
                                          title: constValue.emailId, value: emailList[index].toString()=="null"?"":emailList[index].toString(),
                                         ),
                                        const Padding(
                                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                          child: DotLine(),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                utils.navigatePage(context, ()=> DashBoard(child:
                                                ViewInteractionHistory(companyId: data.userId.toString(),companyName: data.companyName.toString(), contactId: idList[index],)));
                                              },
                                              child: Container(
                                                height:30,
                                                alignment: Alignment.centerLeft,
                                                width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                                child: CustomText(text: "View Full History",colors: colorsConst.blueClr,),
                                              ),
                                            ),
                                            if(idList.length!=1)10.width,
                                            if(idList.length!=1)
                                            InkWell(
                                              onTap:(){
                                                if(mainPerson[index]=="1"){
                                                  utils.showWarningToast(context, text: "Main contact cannot be deleted");
                                                }else{
                                                  utils.customDialog(
                                                      context: context,
                                                      isLoading: true,
                                                      title: 'Do you want to',
                                                      title2: 'Delete The ${constValue.contact}?',
                                                      roundedLoadingButtonController: custProvider.addCtr,
                                                      callback: () {
                                                        custProvider.deleteCustomer(context,id:idList[index],cusId: data.userId.toString());
                                                      }
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height:30,
                                                // color: Colors.pinkAccent,
                                                alignment: Alignment.centerLeft,
                                                width: kIsWeb?webWidth/1.8:phoneWidth/1.8,
                                                child: CustomText(text: "Delete",colors: colorsConst.appRed,),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                      15.height,
                      CustomText(text: constValue.observations,isBold: true,),
                      5.height,
                      Center(
                        child: Container(
                          decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,radius: 10
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(kIsWeb?10:2, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AppCustomDataText(title: constValue.leadStatus, value: data.leadStatus.toString(),),
                                if(data.visitType.toString()!="null"&&data.visitType.toString()!="")
                                AppCustomDataText(title: constValue.visitType, value: data.visitType.toString()=="null"?"":data.visitType.toString(),),
                                if(data.discussionPoint.toString()!="null"&&data.discussionPoint.toString()!="")
                                AppCustomDataText(title: constValue.disPoints, value: data.discussionPoint.toString()=="null"?"":data.discussionPoint.toString()),
                                if(data.points.toString()!="null"&&data.points.toString()!="")
                                AppCustomDataText(title: constValue.addPoints, value: data.points.toString()=="null"?"":data.points.toString()),
                                AppCustomDataText(title: "Added By", value: "${data.addedBy.toString()} ( ${data.role.toString()} )"),
                                AppCustomDataText(title: "Created At", value: DateFormat('dd-MM-yyyy').format(DateTime.parse(data.createdTs.toString()))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      30.height,
                    ],
                  );
                }),
              ),
        )
      ),
    );
    });
  }
}
