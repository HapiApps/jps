
import 'package:flutter/foundation.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/location_provider.dart';

class EmpViaMap extends StatefulWidget {
  const EmpViaMap({super.key});

  @override
  State<EmpViaMap> createState() => _EmpViaMapState();
}

class _EmpViaMapState extends State<EmpViaMap> {
  double lat=0.0;
  double lng=0.0;
  late CameraPosition initialCameraPosition;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<LocationProvider>(context, listen: false).manageLocation(context,false);
      var latitude=double.parse(Provider.of<LocationProvider>(context, listen: false).latitude);
      var longitude=double.parse(Provider.of<LocationProvider>(context, listen: false).longitude);
      setState(() {
        lat = latitude;
        lng = longitude;
      });
      Provider.of<EmployeeProvider>(context, listen: false).search.clear();
      Provider.of<EmployeeProvider>(context, listen: false).marker.clear();
      Provider.of<EmployeeProvider>(context, listen: false).getAdd(lat,lng);
      Provider.of<EmployeeProvider>(context, listen: false).marker.add(
        Marker(
          markerId: const MarkerId("1"),
          position:LatLng(lat,lng),
          infoWindow: const InfoWindow(title: "Current Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet
          ),),);
    });
  }
  CameraPosition? cameraPosition;
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<EmployeeProvider>(builder: (context,empProvider,_){
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            toolbarHeight: 50,
            automaticallyImplyLeading: false,
            title: CustomTextField(
              text: "",
              controller: empProvider.search,
              textInputAction: TextInputAction.done,
              width: kIsWeb?webWidth:phoneWidth,
              hintText: "Search Address",
              isLogin: true,
              iconData: Icons.search,
              onChanged: (value){
                empProvider.mapAddress();
              },
              isShadow: true,
              iconCallBack: (){
                empProvider.mapAddress();
              },
            ),
          ),
          body:Stack(
            children:[
              lat == 0.0 && lng == 0.0?const Loading():
              GoogleMap(
                initialCameraPosition:CameraPosition(target:LatLng(lat,lng),
                    zoom: 20),
                markers:Set<Marker>.of(empProvider.marker),
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                compassEnabled: true,
                onCameraMove: (CameraPosition cameraPositions) {
                  cameraPosition = cameraPositions;
                },
                mapType: MapType.normal,
                onMapCreated:(GoogleMapController controller){
                  empProvider.googleMapController=controller;
                },
              ),
              Positioned(
                bottom: 100,
                right: 20,left: 20,
                child: Container(
                  height: 200,
                  width: kIsWeb?webWidth:phoneWidth,
                  decoration: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,radius: 10
                  ),
                  child:Column(
                    mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(text:"Street Name",colors: Colors.grey),
                              CustomText(text:"Area",colors: Colors.grey),
                              CustomText(text:"City",colors: Colors.grey),
                              CustomText(text:"State",colors: Colors.grey),
                              CustomText(text:"Pincode",colors: Colors.grey),
                              CustomText(text:"Country",colors: Colors.grey),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(text:empProvider.doorNo.text),
                                CustomText(text:empProvider.comArea.text),
                                CustomText(text:empProvider.city.text),
                                CustomText(text:empProvider.state.toString()=="null"?"":empProvider.state.toString()),
                                CustomText(text:empProvider.pinCode.text),
                                CustomText(text:empProvider.country.text),
                              ],
                            ),
                          )
                        ],
                      ),
                      CustomLoadingButton(
                          callback: (){
                            Navigator.pop(context);
                            empProvider.makeChanges();
                          }, isLoading: false,text: "Continue",
                          backgroundColor: Colors.white, textColor:colorsConst.primary,radius: 10, width: 100)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
