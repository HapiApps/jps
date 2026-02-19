import 'package:master_code/source/constant/default_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../model/customer/customer_model.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/local_data.dart';
import '../source/styles/decoration.dart';
import '../source/utilities/utils.dart';
import 'custom_text.dart';
import 'dotted_border.dart';

class CustomerData extends StatefulWidget {
  final CustomerModel customerData;
  final VoidCallback callback;
  final VoidCallback callback2;
  final VoidCallback editCallBack;
  final VoidCallback reportCallBack;
  final VoidCallback taskCallBack;
  final VoidCallback visitsCallBack;
  final VoidCallback iconCallback;
  final VoidCallback iconCallback2;
  final bool? show;
  final bool showDateHeader;
  final String dayOfWeek;
  final VoidCallback? shareCallback;
  final VoidCallback? mailCallback;
  const CustomerData({super.key, required this.customerData, required this.callback, required this.iconCallback, this.show=false, required this.callback2, required this.editCallBack, required this.reportCallBack, required this.visitsCallBack, required this.showDateHeader, required this.dayOfWeek, required this.taskCallBack, required this.iconCallback2, this.shareCallback, this.mailCallback});

  @override
  State<CustomerData> createState() => _CustomerDataState();
}

class _CustomerDataState extends State<CustomerData> {
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    CustomerModel data=widget.customerData;
    var visitCountList=data.visitCount.toString().split(',');
    var idList=data.customerId.toString().split('||');
    var usersList=data.firstName.toString().split('||');
    var phoneList=data.phoneNumber.toString().split('||');
    var mainList=data.mainPerson.toString().split('||');
    var sendList=[];
    for(var i=0;i<usersList.length;i++){
      sendList.add({"id": idList[i], "name": usersList[i], "no": phoneList[i]});
    }
    // print(mainList);
    return Stack(
      children: [
        InkWell(
        onTap: widget.callback2,
        child: Column(
          children: [
            if (widget.showDateHeader)
              CustomText(
                text: widget.dayOfWeek,
                colors: Colors.black,
              ),
            if (widget.showDateHeader)5.height,
              Container(
                  width: kIsWeb?webWidth:phoneWidth,
                decoration: customDecoration.baseBackgroundDecoration(
                    color: Colors.white,
                    radius: 5,
                    borderColor: Colors.grey.shade200,isShadow: true,shadowColor: Colors.grey.shade200
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: SizedBox(
                    width:kIsWeb?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.83,
                    // color:Colors.blue,
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:usersList.length,
                        itemBuilder: (context,index){
                          return mainList[index]=="1"?Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      width:kIsWeb?webWidth/1.15:phoneWidth/1.15,
                                      // color: Colors.pinkAccent,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText(text: data.companyName.toString().trim(),isBold: localData.storage.read("role") =="1"?false:true,colors: localData.storage.read("role") =="1"?colorsConst.greyClr:colorsConst.primary,),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(context).size.width*0.11,
                                                        child: IconButton(onPressed: widget.mailCallback, icon: SvgPicture.asset(assets.mail,width: 20,height: 20,))),
                                                    SizedBox(
                                                        width: MediaQuery.of(context).size.width*0.11,
                                                        child: IconButton(onPressed: widget.shareCallback, icon: SvgPicture.asset(assets.share,width: 20,height: 20,))),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if(localData.storage.read("role") =="1")15.height,
                                            CustomText(text: usersList[index].toString().trim(),colors: colorsConst.greyClr,),
                                          ],
                                        ),
                                      )),
                                  if(localData.storage.read("role") =="1")
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            // color: Colors.pink,
                                            width:30,height:30,
                                            child: IconButton(
                                              onPressed:widget.iconCallback,
                                              icon: Icon(Icons.keyboard_arrow_down_rounded,size:23,color: colorsConst.greyClr,)),
                                          ),
                                          SizedBox(
                                            width:30,height:30,
                                            // color: Colors.yellow,
                                            child: IconButton(
                                              onPressed:(){
                                                utils.makingPhoneCall(ph: phoneList[index].toString());
                                              },
                                              icon: Icon(Icons.call,color: colorsConst.blueClr,)),
                                          ),
                                          10.height
                                        ],
                                      ),
                                    ),
                                  // if(localData.storage.read("role") =="1")
                                  // IconButton(
                                  //   onPressed:widget.visitsCallBack,
                                  //   icon: SvgPicture.asset(assets.visitIcon,width: 20,height: 20,)),
                                  // if(localData.storage.read("role") !="1")
                                  //   IconButton(
                                  //     onPressed: (){
                                  //       utils.makingEmail(mail: mainList[index].toString(), context: context);
                                  //     },
                                  //     icon: SvgPicture.asset(assets.mail,width: 20,height: 20,)),
                                  // if(localData.storage.read("role") !="1")
                                  //   IconButton(
                                  //     onPressed: (){
                                  //       utils.makingPhoneCall(ph: phoneList[index].toString());
                                  //     },
                                  //     icon: SvgPicture.asset(assets.phone,width: 20,height: 20,))
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: DotLine(),
                              ),
                              // if(localData.storage.read("role") !="1")
                              SizedBox(
                                height: 32,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                        onPressed: widget.editCallBack,
                                        child: CustomText(text: "Edit ${constValue.customer}",colors: colorsConst.blueClr,)),
                                    // TextButton( onPressed : widget.taskCallBack,child: CustomText(text: "View Task",colors: colorsConst.appRed,)),
                                    // TextButton( onPressed : widget.reportCallBack,child: CustomText(text: "Report",colors: colorsConst.appYellow,)),
                                    TextButton(onPressed: widget.visitsCallBack, child: CustomText(text: "Add Visit",colors: colorsConst.blueClr,)),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 3, 3),
                                      child: InkWell(
                                        onTap : widget.callback,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.24,
                                          height: 25,
                                          decoration: customDecoration.baseBackgroundDecoration(
                                              color: data.isChecked.toString()=="null"?Colors.grey.shade300: data.isChecked.toString()=="1"?colorsConst.appGreen:colorsConst.appRed,
                                              radius: 20,
                                          ),
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.location_on_outlined,color: data.isChecked.toString()=="null"?Colors.black: Colors.white,size: 15,),
                                                CustomText(text: data.isChecked.toString()=="null"?"Check In":"Check out",colors: data.isChecked.toString()=="null"?Colors.black: Colors.white,isBold: true,),
                                              ],
                                            ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              if(visitCountList[0].toString()!="null")
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const DotLine(),5.height,
                                    CustomText(text: "Today Visits",colors: colorsConst.greyClr,)
                                  ],
                                ),
                            ),
                              if(visitCountList[0].toString()!="null")
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 10),
                                child: SizedBox(
                                    width:MediaQuery.of(context).size.width*0.95,
                                    // color:Colors.blue,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount:visitCountList.length,
                                        itemBuilder: (context,index){
                                          return Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 5, 8, 0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                SizedBox(
                                                  // color:Colors.pink,
                                                  width: kIsWeb?MediaQuery.of(context).size.width*0.4:MediaQuery.of(context).size.width*0.7,
                                                  child: CustomText(
                                                    text: visitCountList[index].toString().split('||').first.trim(),colors: colorsConst.secondary,isBold: true,),
                                                ),CustomText(
                                                  text: visitCountList[index].toString().split('||').last.trim(),colors: colorsConst.stateColor,isBold: true,),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                              ),
                            ],
                          ):0.height;
                        }),
                  ),
                )
            ),
          ],
        ),
      ),
        if(widget.show==true)
        Positioned(
          // top: 20,
            child: Container(
              width: kIsWeb?webWidth:phoneWidth,
              height: usersList.length==1?100:usersList.length*75,
              decoration: customDecoration.baseBackgroundDecoration(
                color: Colors.white, radius: 10,
                borderColor: colorsConst.litGrey,shadowColor: Colors.grey.shade300
              ),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:usersList.length,
                  itemBuilder: (context,i){
                    // usersList.sort((a, b) =>a.compareTo(b.toString()));
                    // mainList.sort((a, b) =>a.compareTo(b.toString()));
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Column(
                        children: [
                          if(i==0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                // color:Colors.pink,
                                width: kIsWeb?MediaQuery.of(context).size.width*0.35:MediaQuery.of(context).size.width*0.65,
                                child: CustomText(
                                  text: data.companyName.toString(),colors: colorsConst.greyClr),
                              ),
                              IconButton(
                                  onPressed: widget.iconCallback2,
                                  icon: Icon(Icons.cancel,color: colorsConst.greyClr))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  // color:Colors.pink,
                                  width: kIsWeb?MediaQuery.of(context).size.width*0.35:MediaQuery.of(context).size.width*0.65,
                                  child: CustomText(
                                    text: usersList[i].toString(),colors: colorsConst.greyClr),
                                ),
                                phoneList[i].toString()!="null"&&phoneList[i].toString()!=""?
                                IconButton(
                                    onPressed: (){
                                      utils.makingPhoneCall(ph: phoneList[i].toString());
                                    },
                                    icon: Icon(Icons.call,size: 20,color: mainList[i]=="1"?colorsConst.blueClr:colorsConst.appDarkGreen,))
                                    :SizedBox(
                                  width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width*0.35,
                                  height: 40,
                                )
                              ],
                            ),
                          ),
                          if(i!=usersList.length-1)
                          const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: DotLine(),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
        )
      ]
    );
  }
}
