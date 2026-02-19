import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:master_code/screens/track/track_details.dart';
import 'package:master_code/screens/track/tracked_location.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:provider/provider.dart';
import 'package:master_code/view_model/track_provider.dart';
import '../../component/animated_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_network_image.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/dotted_border.dart';
import '../../component/map_dropdown.dart';
import '../../model/user_model.dart';
import '../../source/constant/local_data.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/customer_provider.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/home_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';

class CorrectionReport extends StatefulWidget {
  const CorrectionReport({super.key});

  @override
  State<CorrectionReport> createState() => _CorrectionReportState();
}

class _CorrectionReportState extends State<CorrectionReport> with SingleTickerProviderStateMixin{
  late GoogleMapController _googleMapController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<TrackProvider>(context, listen: false).initDate();
      Provider.of<TrackProvider>(context, listen: false).initFilterValue(true);
    if({"1"}.contains(localData.storage.read("role"))){
      // Provider.of<CustomerProvider>(context, listen: false).getAllTrack();
      await Provider.of<TrackProvider>(context, listen: false).toTrack();
    }else{
      await Provider.of<CustomerProvider>(context, listen: false).getTrackReport(localData.storage.read("id"),false);
    }
      await Provider.of<CustomerProvider>(context, listen: false).getLiveTrack();
    });
    super.initState();
  }
  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer3<CustomerProvider,HomeProvider,TrackProvider>(builder: (context,custProvider,homeProvider,trackProvider,_){
      return  SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 40),
          child: CustomAppbar(text: constValue.trackR,callback: (){
            homeProvider.updateIndex(0);
            utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
        }),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            homeProvider.updateIndex(0);
            if (!didPop) {
              utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
            }
          },
          child: Center(
            child: SizedBox(
              width:  kIsWeb?webWidth:phoneWidth,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextField(
                        text: "",radius: 30,
                        controller: custProvider.search,
                        width: kIsWeb?webWidth:phoneWidth,
                        hintText: "Search Name Or Phone No",
                        isIcon: true,
                        iconData: Icons.search,
                        textInputAction: TextInputAction.done,
                        isShadow: true,
                        onChanged: (value) {
                          trackProvider.searchTrack(value.toString());
                        },
                        isSearch: custProvider.search.text.isNotEmpty?true:false,
                        searchCall: (){
                          custProvider.search.clear();
                          trackProvider.searchTrack("");
                        },
                      ),
                      // InkWell(
                      //   onTap: (){
                      //     showDialog(
                      //       context: context,
                      //       builder: (context) {
                      //         return Consumer<TrackProvider>(
                      //           builder: (context, trackProvider, _) {
                      //             return AlertDialog(
                      //               actions: [
                      //                 SizedBox(
                      //                   width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.9,
                      //                   child: Column(
                      //                     children: [
                      //                       20.height,
                      //                       Row(
                      //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //                         children: [
                      //                           70.width,
                      //                           const CustomText(
                      //                             text: 'Filters',
                      //                             colors: Colors.black,
                      //                             size: 16,
                      //                             isBold: true,
                      //                           ),
                      //                           30.width,
                      //                           GestureDetector(
                      //                             onTap: () {
                      //                               Navigator.of(context, rootNavigator: true).pop();
                      //                             },
                      //                             child: SvgPicture.asset(assets.cancel),
                      //                           )
                      //                         ],
                      //                       ),
                      //                       20.height,
                      //                       Row(
                      //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //                         children: [
                      //                           Column(
                      //                             crossAxisAlignment: CrossAxisAlignment.start,
                      //                             children: [
                      //                               CustomText(
                      //                                 text: "From Date",
                      //                                 colors: colorsConst.greyClr,
                      //                                 size: 12,
                      //                               ),
                      //                               InkWell(
                      //                                 onTap: () {
                      //                                   trackProvider.datePick(
                      //                                     context: context,
                      //                                     isStartDate: true,
                      //                                   );
                      //                                 },
                      //                                 child: Container(
                      //                                   height: 30,
                      //                                   width: kIsWeb?MediaQuery.of(context).size.width*0.14:MediaQuery.of(context).size.width * 0.35,
                      //                                   decoration: customDecoration.baseBackgroundDecoration(
                      //                                     color: Colors.white,
                      //                                     radius: 5,
                      //                                     borderColor: colorsConst.litGrey,
                      //                                   ),
                      //                                   child: Row(
                      //                                     mainAxisAlignment: MainAxisAlignment.center,
                      //                                     children: [
                      //                                       CustomText(text: trackProvider.startDate),
                      //                                       5.width,
                      //                                       SvgPicture.asset(assets.calendar2),
                      //                                     ],
                      //                                   ),
                      //                                 ),
                      //                               )
                      //                             ],
                      //                           ),
                      //                           Column(
                      //                             crossAxisAlignment: CrossAxisAlignment.start,
                      //                             children: [
                      //                               CustomText(
                      //                                 text: "To Date",
                      //                                 colors: colorsConst.greyClr,
                      //                                 size: 12,
                      //                               ),
                      //                               InkWell(
                      //                                 onTap: () {
                      //                                   trackProvider.datePick(
                      //                                     context: context,
                      //                                     isStartDate: false,
                      //                                   );
                      //                                 },
                      //                                 child: Container(
                      //                                   height: 30,
                      //                                   width: kIsWeb?MediaQuery.of(context).size.width*0.14:MediaQuery.of(context).size.width * 0.35,
                      //                                   decoration: customDecoration.baseBackgroundDecoration(
                      //                                     color: Colors.white,
                      //                                     radius: 5,
                      //                                     borderColor: colorsConst.litGrey,
                      //                                   ),
                      //                                   child: Row(
                      //                                     mainAxisAlignment: MainAxisAlignment.center,
                      //                                     children: [
                      //                                       CustomText(text: trackProvider.endDate),
                      //                                       5.width,
                      //                                       SvgPicture.asset(assets.calendar2),
                      //                                     ],
                      //                                   ),
                      //                                 ),
                      //                               )
                      //                             ],
                      //                           ),
                      //                         ],
                      //                       ),
                      //                       10.height,
                      //                       Row(
                      //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //                         children: [
                      //                           Column(
                      //                             crossAxisAlignment: CrossAxisAlignment.start,
                      //                             children: [
                      //                               CustomText(
                      //                                 text: "Employee Name",
                      //                                 colors: colorsConst.greyClr,
                      //                                 size: 12,
                      //                               ),
                      //                               EmployeeDropdown(
                      //                                 callback: (){
                      //                                   Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
                      //                                 },
                      //                                 text: trackProvider.user==null?"Name":"",
                      //                                 employeeList: Provider.of<EmployeeProvider>(context, listen: false).filterUserData,
                      //                                 onChanged: (UserModel? value) {
                      //                                   trackProvider.selectUser(value!);
                      //                                 },
                      //                                 size: kIsWeb?MediaQuery.of(context).size.width*0.14:MediaQuery.of(context).size.width*0.36,),
                      //                             ],
                      //                           ),
                      //                           Padding(
                      //                             padding: EdgeInsets.fromLTRB(0, Provider.of<EmployeeProvider>(context, listen: false).filterUserData.isEmpty?20:0, 0, 0),
                      //                             child: Column(
                      //                               crossAxisAlignment: CrossAxisAlignment.start,
                      //                               children: [
                      //                                 CustomText(
                      //                                   text: "Select Date Range",
                      //                                   colors: colorsConst.greyClr,
                      //                                   size: 12,
                      //                                 ),
                      //                                 Container(
                      //                                   height: 40,
                      //                                   width: kIsWeb?MediaQuery.of(context).size.width*0.14:MediaQuery.of(context).size.width * 0.36,
                      //                                   decoration: customDecoration.baseBackgroundDecoration(
                      //                                     radius: 5,
                      //                                     color: Colors.white,
                      //                                     borderColor: colorsConst.litGrey,
                      //                                   ),
                      //                                   child: DropdownButton(
                      //                                     iconEnabledColor: colorsConst.greyClr,
                      //                                     isExpanded: true,
                      //                                     underline: const SizedBox(),
                      //                                     icon: const Icon(Icons.keyboard_arrow_down_outlined),
                      //                                     value: trackProvider.filterType,
                      //                                     onChanged: (value) {
                      //                                       trackProvider.changeFilterType(value);
                      //                                     },
                      //                                     items: trackProvider.filterTypeList.map((list) {
                      //                                       return DropdownMenuItem(
                      //                                         value: list,
                      //                                         child: CustomText(
                      //                                           text: "  $list",
                      //                                           colors: Colors.black,
                      //                                           isBold: false,
                      //                                         ),
                      //                                       );
                      //                                     }).toList(),
                      //                                   ),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                       20.height,
                      //                       Row(
                      //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //                         children: [
                      //                           CustomBtn(
                      //                             width: 100,
                      //                             text: 'Clear All',
                      //                             callback: () {
                      //                               trackProvider.initFilterValue(true);
                      //                               Navigator.of(context, rootNavigator: true).pop();
                      //                             },
                      //                             bgColor: Colors.grey.shade200,
                      //                             textColor: Colors.black,
                      //                           ),
                      //                           CustomBtn(
                      //                             width: 100,
                      //                             text: 'Apply Filters',
                      //                             callback: () {
                      //                               trackProvider.initFilterValue(false);
                      //                               Navigator.of(context, rootNavigator: true).pop();
                      //                             },
                      //                             bgColor: colorsConst.primary,
                      //                             textColor: Colors.white,
                      //                           ),
                      //                         ],
                      //                       ),
                      //                       20.height,
                      //                     ],
                      //                   ),
                      //                 ),
                      //               ],
                      //             );
                      //           },
                      //         );
                      //       },
                      //     );
                      //   },
                      //   child: Container(
                      //     width: kIsWeb?MediaQuery.of(context).size.width*0.03:MediaQuery.of(context).size.width*0.12,
                      //     height: 45,
                      //     decoration: customDecoration.baseBackgroundDecoration(
                      //         color: trackProvider.filter==true?colorsConst.primary:Colors.grey.shade300,radius: 5
                      //     ),
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(6.0),
                      //       child: SvgPicture.asset(assets.filter,width: 15,height: 15,),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  custProvider.refresh==false?
                  const Loading():
                  custProvider.liveMarker.isNotEmpty?
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                      boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade300,
                              spreadRadius: 0.1,
                              blurRadius:0.1,
                              offset: const Offset(2,2)),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width*0.8,
                    child: GoogleMap(
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          custProvider.liveMarker[0].position.latitude,
                          custProvider.liveMarker[0].position.longitude,
                        ),
                        zoom: 10,
                      ),
                      markers: Set<Marker>.of(
                        custProvider.liveMarker.map((marker) {
                          return marker.copyWith(
                            infoWindowParam: InfoWindow(
                              title: marker.infoWindow.title,
                              snippet: marker.infoWindow.snippet,
                            ),
                          );
                        }),
                      ),
                      onMapCreated: (controller) {
                        _googleMapController = controller;

                        // Automatically show the info window for the first marker
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _googleMapController.showMarkerInfoWindow(
                            custProvider.liveMarker[0].markerId,
                          );
                        });
                      },
                    ),
                  ):0.height,
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: Column(
                        children: [
                          trackProvider.isTrack==false?const Padding(
                            padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                            child: Loading(),
                          )
                              :trackProvider.todayDisplayList.isNotEmpty?
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width*0.83,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: trackProvider.todayDisplayList.length,
                                itemBuilder: (context, index) {
                                  final transition = trackProvider.todayDisplayList[index];
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*0.83,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,
                                          radius: 5
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    // CircleNetWorkImg(img: transition.image, width: 40),
                                                    CustomText(text: transition.firstname,isBold: true,),
                                                    Row(
                                                      children: [
                                                        CustomText(text: transition.role,colors: colorsConst.blueClr,size: 11,),5.width,
                                                        InkWell(
                                                            onTap:(){
                                                              utils.makingPhoneCall(ph: transition.number.toString());
                                                            },
                                                            child: SvgPicture.asset(assets.call,width: 15,height: 15,))
                                                      ],
                                                    ),5.height
                                                  ],
                                                ),
                                                Container(width: 1,height:70,color: Colors.grey.shade400,),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const CustomText(text: 'Start Time',colors: Colors.grey,size: 12,),10.height,
                                                    CustomText(text: trackProvider.formatTime(transition.startTime.toString()),colors: colorsConst.greyClr,size: 12,),
                                                  ],
                                                ),Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const CustomText(text: 'End Time',colors: Colors.grey,size: 12,),10.height,
                                                    CustomText(text: trackProvider.startDate!="${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year}"?"-":trackProvider.formatTime(transition.endTime.toString()),colors: colorsConst.greyClr,size: 12,),
                                                  ],
                                                ),Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const CustomText(text: 'Total Hours',colors: Colors.grey,size: 12,),10.height,
                                                    CustomText(text: "---",colors: colorsConst.greyClr,size: 12,),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const DotLine(),5.height,
                                            Row(
                                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const CustomText(text: 'Distance Travelled',colors: Colors.grey,size: 12,),5.width,
                                                    CustomText(text: '${transition.totalDistance.toStringAsFixed(2)} km'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const CustomText(text: 'Total Visits',size: 12,colors: Colors.grey),5.width,
                                                    CustomText(text: '${transition.totalVisitUnitCount}',size: 12,),
                                                  ],
                                                ),
                                                // InkWell(
                                                //     onTap:(){
                                                //       // utils.navigatePage(context, ()=>DashBoard(child: NewEmpReport(id: transition.id,name: "${transition.firstname} - ${transition.role}")));
                                                //       // homeProvider.showMainType(2);
                                                //       // homeProvider.changeMainList(id: transition.id,name: "${transition.firstname} - ${transition.role}");
                                                //     },
                                                //     child: Icon(Icons.info,color: colorsConst.appRed,))
                                                //     // child: SvgPicture.asset(assets.tracks))
                                                // // CustomText(text: 'Visit Count: ${int.parse(transition["unique_unit_count"])-1}\n'),
                                              ],
                                            ),5.height,
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ):const Padding(
                            padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                            child: CustomText(text: "No Data Found"),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
    });
  }
}