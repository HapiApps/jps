
import 'package:flutter/foundation.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:master_code/view_model/project_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/location_provider.dart';

class ViaMap extends StatefulWidget {
  const ViaMap({super.key});

  @override
  State<ViaMap> createState() => _ViaMapState();
}

class _ViaMapState extends State<ViaMap> {
  double lat=0.0;
  double lng=0.0;
  late CameraPosition initialCameraPosition;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<ProjectProvider>(context, listen: false).search.clear();
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.manageLocation(context, false);
      double latitude = double.parse(locationProvider.latitude);
      double longitude = double.parse(locationProvider.longitude);
      setState(() {
        lat = latitude;
        lng = longitude;
      });
      Provider.of<ProjectProvider>(context, listen: false).search.clear();
      Provider.of<ProjectProvider>(context, listen: false).marker.clear();
      Provider.of<ProjectProvider>(context, listen: false).getAdd(lat, lng);
      Provider.of<ProjectProvider>(context, listen: false).marker.add(
        Marker(
          markerId: const MarkerId("1"),
          position: LatLng(lat, lng),
          infoWindow: const InfoWindow(title: "Current Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );
    });
  }
  CameraPosition? cameraPosition;
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(builder: (context,prjProvider,_){
      var webWidth=MediaQuery.of(context).size.width * 0.5;
      var phoneWidth=MediaQuery.of(context).size.width * 0.9;
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            toolbarHeight: 50,
            automaticallyImplyLeading: false,
            title: CustomTextField(
              text: "",
              controller: prjProvider.search,
              textInputAction: TextInputAction.done,
              width: kIsWeb?webWidth:phoneWidth,
              hintText: "Search Address",
              isLogin: true,
              iconData: Icons.search,
              isShadow: true,
              onChanged: (value){
                prjProvider.mapAddress();
              },
              iconCallBack: (){
                prjProvider.mapAddress();
              },
            ),
          ),
          body:Stack(
            children:[
              lat == 0.0 && lng == 0.0?const Loading():
              GoogleMap(
                initialCameraPosition:CameraPosition(target:LatLng(lat,lng),
                    zoom: 20),
                markers:Set<Marker>.of(prjProvider.marker),
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                compassEnabled: true,
                onCameraMove: (CameraPosition cameraPositions) {
                  cameraPosition = cameraPositions;
                },
                mapType: MapType.normal,
                onMapCreated:(GoogleMapController controller){
                  prjProvider.googleMapController=controller;
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
                                CustomText(text:prjProvider.presentStreet.text),
                                CustomText(text:prjProvider.presentArea.text),
                                CustomText(text:prjProvider.presentCity.text),
                                CustomText(text:prjProvider.state.toString()=="null"?"":prjProvider.state.toString()),
                                CustomText(text:prjProvider.presentPin.text),
                                CustomText(text:prjProvider.presentCountry.text),
                              ],
                            ),
                          )
                        ],
                      ),
                      CustomLoadingButton(
                          callback: (){
                            Navigator.pop(context);
                          }, isLoading: false,text: "Continue",
                          backgroundColor: Colors.white, textColor: colorsConst.primary, radius: 10, width: 100)
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
