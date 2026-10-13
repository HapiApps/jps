import 'package:master_code/screens/common/fullscreen_photo.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../component/audio_player.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../model/customer/customer_attendance_model.dart';
import '../../source/utilities/utils.dart';
import '../common/check_location.dart';

class CustomerTaskAttendance extends StatefulWidget {
  final String id;
  final String date1;
  final String date2;
  final String name;
  const CustomerTaskAttendance({super.key, required this.id, required this.date1, required this.date2, required this.name});

  @override
  State<CustomerTaskAttendance> createState() => _CustomerTaskAttendanceState();
}

class _CustomerTaskAttendanceState extends State<CustomerTaskAttendance> {
  Map<String, String> addressMap1 = {}; // key = "lat,lng"
  Map<String, String> addressMap2 = {}; // key = "lat,lng"

  Future<void> resolveAddress1(double lat, double lng) async {
    String key = "$lat,$lng";
    if (!addressMap1.containsKey(key)) {
      try {
        List<Placemark> placeMark = await placemarkFromCoordinates(lat, lng);
        Placemark place = placeMark[0];

        String stateFull = place.administrativeArea ?? '';
        String stateShort = getStateShortForm(stateFull);

        String address = [
          place.subLocality,
          place.locality,
          stateShort,
        ].where((e) => e != null && e.isNotEmpty).join(", ");

        setState(() {
          addressMap1[key] = address;
        });
      } catch (e) {
        setState(() {
          addressMap1[key] = "Address not found";
        });
      }
    }
  }
  Future<void> resolveAddress2(double lat, double lng) async {
    String key = "$lat,$lng";
    if (!addressMap2.containsKey(key)) {
      try {
        List<Placemark> placeMark = await placemarkFromCoordinates(lat, lng);
        Placemark place = placeMark[0];

        String stateFull = place.administrativeArea ?? '';
        String stateShort = getStateShortForm(stateFull);

        String address = [
          place.subLocality,
          place.locality,
          stateShort,
        ].where((e) => e != null && e.isNotEmpty).join(", ");

        setState(() {
          addressMap2[key] = address;
        });
      } catch (e) {
        setState(() {
          addressMap2[key] = "Address not found";
        });
      }
    }
  }
  String getStateShortForm(String state) {
    Map<String, String> stateMap = {
      'Andhra Pradesh': 'AP',
      'Arunachal Pradesh': 'AR',
      'Assam': 'AS',
      'Bihar': 'BR',
      'Chhattisgarh': 'CG',
      'Goa': 'GA',
      'Gujarat': 'GJ',
      'Haryana': 'HR',
      'Himachal Pradesh': 'HP',
      'Jharkhand': 'JH',
      'Karnataka': 'KA',
      'Kerala': 'KL',
      'Madhya Pradesh': 'MP',
      'Maharashtra': 'MH',
      'Manipur': 'MN',
      'Meghalaya': 'ML',
      'Mizoram': 'MZ',
      'Nagaland': 'NL',
      'Odisha': 'OD',
      'Punjab': 'PB',
      'Rajasthan': 'RJ',
      'Sikkim': 'SK',
      'Tamil Nadu': 'TN',
      'Telangana': 'TS',
      'Tripura': 'TR',
      'Uttar Pradesh': 'UP',
      'Uttarakhand': 'UK',
      'West Bengal': 'WB',
      'Andaman and Nicobar Islands': 'AN',
      'Chandigarh': 'CH',
      'Dadra and Nagar Haveli and Daman and Diu': 'DN',
      'Delhi': 'DL',
      'Jammu and Kashmir': 'JK',
      'Ladakh': 'LA',
      'Lakshadweep': 'LD',
      'Puducherry': 'PY',
    };

    return stateMap[state.trim()] ?? state;
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).getCustomerTaskAttendance(widget.id,widget.date1,widget.date2);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.7;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<TaskProvider>(builder: (context,taskProvider,_){
      return SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: const PreferredSize(
          preferredSize: Size(300, 50),
          child: CustomAppbar(text: "Visited Tasks"),
        ),
        body: Column(
          children: [
            taskProvider.refresh==false?
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
              child: Loading(),
            ):
            taskProvider.customerAttendanceReport.isEmpty?
            const Center(child: CustomText(text: "\n\n\n\nNo Visit Found"))
                :Expanded(
                  child: Column(
                    children: [
                      CustomText(text: "${widget.name}\n"),
                      Expanded(
                        child: ListView.builder(
                        itemCount: taskProvider.customerAttendanceReport.length,
                        itemBuilder: (context,index){
                          CustomerAttendanceModel data = taskProvider.customerAttendanceReport[index];
                          final String latKey1 = "${data.inLat},${data.inLng}";
                          if (!addressMap1.containsKey(latKey1)) {
                            resolveAddress1(double.parse(data.inLat.toString()), double.parse(data.inLng.toString()));
                          }
                          final String latKey2 = "${data.outLat},${data.outLng}";
                          if(data.outLat.toString().contains(".")){
                            if (!addressMap2.containsKey(latKey2)) {
                              resolveAddress2(double.parse(data.outLat.toString()), double.parse(data.outLng.toString()));
                            }
                          }
                          return Column(
                            children: [
                              if(index==0)
                              10.height,
                              Container(
                                 width: kIsWeb?webWidth:phoneWidth,
                                 decoration: customDecoration.baseBackgroundDecoration(
                                 color: Colors.white,radius: 5,borderColor: colorsConst.litGrey
                               ),
                                 child: Padding(
                                   padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           // CustomText(text: data.projectName.toString(),colors: colorsConst.primary,isBold: true,),5.width,
                                           CustomText(text: taskProvider.crtDate(data.checkInTs.toString(), "1"),isBold: true),
                                           InkWell(
                                               onTap:(){
                                                 utils.navigatePage(context, ()=>CheckLocation(
                                                     addressShow: true,
                                                     lat1: data.inLat.toString(),
                                                     long1: data.inLng.toString(),
                                                     lat2: data.checkInTs.toString().contains("2")? data.outLat.toString(): "",
                                                     long2: data.checkInTs.toString().contains("2")? data.outLng.toString(): ""
                                                 ));
                                               },
                                               child: Icon(Icons.location_on_outlined,color: colorsConst.appRed,))
                                         ],
                                       ),
                                       CustomText(text: data.taskTitle.toString(),colors: colorsConst.greyClr,),10.height,
                                       Row(
                                         children: [
                                           SizedBox(
                                               // color:Colors.yellow,
                                               width:kIsWeb?MediaQuery.of(context).size.width*0.05:MediaQuery.of(context).size.width*0.1,
                                               child: CustomText(text: "In : ",colors: colorsConst.greyClr,)),5.width,
                                           SizedBox(
                                               // color:Colors.pink,
                                               width:kIsWeb?MediaQuery.of(context).size.width*0.05:MediaQuery.of(context).size.width*0.17,
                                               child: CustomText(text: taskProvider.crtDate(data.checkInTs.toString(), "2"),isBold: true)),
                                           if(!kIsWeb)
                                           SizedBox(
                                               // color:Colors.blue,
                                               width:kIsWeb?MediaQuery.of(context).size.width*0.05:MediaQuery.of(context).size.width*0.55,
                                               child: CustomText(text: addressMap1[latKey1] ?? "Loading address...")),
                                         ],
                                       ),5.height,
                                       if(taskProvider.crtDate(data.checkInTs.toString(), "1")!=taskProvider.crtDate(data.checkOutTs.toString(), "1"))
                                       Padding(
                                         padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                         child: CustomText(text: taskProvider.crtDate(data.checkOutTs.toString(), "1"),colors: colorsConst.orange,),
                                       ),
                                       Row(
                                         children: [
                                           SizedBox(
                                             // color:Colors.pink,
                                               width:kIsWeb?MediaQuery.of(context).size.width*0.05:MediaQuery.of(context).size.width*0.1,
                                               child: CustomText(text: "Out : ",colors: colorsConst.greyClr,)),5.width,
                                           SizedBox(
                                               width:kIsWeb?MediaQuery.of(context).size.width*0.05:MediaQuery.of(context).size.width*0.17,
                                               child: CustomText(text: data.isCheckedOut.toString()=="2"?taskProvider.crtDate(data.checkOutTs.toString(), "2"):"-",isBold: true)),
                                           if(!kIsWeb)
                                             SizedBox(
                                             // color:Colors.blue,
                                               width:kIsWeb?MediaQuery.of(context).size.width*0.05:MediaQuery.of(context).size.width*0.55,
                                               child: CustomText(text: data.outLat.toString().contains(".")?addressMap2[latKey2] ?? "Loading address...":"")),
                                         ],
                                       ),5.height,
                                       Row(
                                         children: [
                                           if(data.inImage.toString().contains("/"))
                                             InkWell(
                                             onTap:(){
                                               utils.navigatePage(context, ()=>FullScreen(image: data.inImage.toString(), isNetwork: true));
                                             },
                                             child: SizedBox(
                                                 width: 50,height:50,
                                                 child: ShowNetWrKImg(img: data.inImage.toString(),)
                                             ),
                                           ),
                                           if(data.outImage.toString().contains("/"))
                                           InkWell(
                                             onTap:(){
                                               utils.navigatePage(context, ()=>FullScreen(image: data.outImage.toString(), isNetwork: true));
                                             },
                                             child: Padding(
                                               padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                               child: SizedBox(
                                                   width: 50,height:50,
                                                   child: ShowNetWrKImg(img: data.outImage.toString(),)
                                               ),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ],
                                   ),
                                 )
                          ),
                              index==taskProvider.customerAttendanceReport.length-1?80.height:10.height
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                            ),
          ],
        ),
      ),
    );
    });
  }
}
