import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/view_model/home_provider.dart';
import '../../component/custom_appbar.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/customer_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';

class TrackingLive extends StatefulWidget {
  const TrackingLive({super.key});

  @override
  State<TrackingLive> createState() => _TrackingLiveState();
}

class _TrackingLiveState extends State<TrackingLive> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<CustomerProvider>(context, listen: false).getLiveTrack();
    });
    super.initState();
  }
  late GoogleMapController _googleMapController;
  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider,HomeProvider>(builder: (context,custProvider,homeProvider,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 50),
            child: CustomAppbar(text: "Tracking Employee",callback: (){
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
            child: custProvider.refresh==false?
            const Loading():
            custProvider.liveMarker.isEmpty
            ?Center(child: CustomText(text: "No Tracking Employees Found",colors: colorsConst.greyClr,)):
            GoogleMap(
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
          ),
        ));
    });
  }
}
