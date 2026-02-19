import 'package:master_code/component/custom_text.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../component/custom_appbar.dart';
import '../../source/styles/decoration.dart';

class CheckLocation extends StatefulWidget {
  final String lat1;
  final String long1;
  final String lat2;
  final String long2;
  final bool? addressShow;
  const CheckLocation({super.key, required this.lat1, required this.long1, required this.lat2, required this.long2, this.addressShow});
  @override
  State<CheckLocation> createState() => _CheckLocationState();
}

class _CheckLocationState extends State<CheckLocation> {
  final List<Marker> _marker =[];
  double lat1=0.0;
  double lat2=0.0;
  double lng1=0.0;
  double lng2=0.0;
  String address1 = '';
  String address2 = '';
  @override
  void initState() {
    dynamic latitude1;
    if(widget.lat1!="") {
      latitude1=double.parse(widget.lat1);
    }
    dynamic latitude2;
    if(widget.lat2.toString().contains(".")) {
      latitude2=double.parse(widget.lat2);
    }
    dynamic longitude1;
    if(widget.long1!="") {
      longitude1=double.parse(widget.long1);
    }
    dynamic longitude2;
    if(widget.long2.toString().contains(".")) {
      longitude2 =double.parse(widget.long2);
    }
    if(latitude1!=null) {
      lat1=latitude1;
    }
    if(latitude2!=null) {
      lat2=latitude2;
    }
    if(longitude1!=null) {
      lng1=longitude1;
    }
    if(longitude2!=null) {
      lng2=longitude2;
    }
    _marker.addAll(
        [
          Marker(
            markerId: const MarkerId("1"),
            position:LatLng(lat1,lng1),
            infoWindow: const InfoWindow(title:"Check In"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen
            ),),
          if(lat2!=0.0&&lng2!=0.0)
          Marker(
            markerId: const MarkerId("1"),
            position:LatLng(lat2,lng2),
            infoWindow: const InfoWindow(title:"Check Out"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed
            ),),
        ]
      );
    getAddress(lat1,lng1,lat2,lng2);
    super.initState();
  }
  void getAddress(double lat, double lng, double lat2, double lng2) async {
    List<Placemark> placeMark = await placemarkFromCoordinates(lat, lng);
    Placemark place = placeMark[0];

    setState(() {
      address1 = [
        place.street,
        place.subLocality,
        place.thoroughfare,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e != null && e.isNotEmpty).join(", ");
    });

    // Second address
    if (lat2 != 0.0 && lng2 != 0.0) {
      List<Placemark> placeMark2 = await placemarkFromCoordinates(lat2, lng2);
      Placemark place2 = placeMark2[0];
      setState(() {
        address2 = [
          place2.street,
          place2.subLocality,
          place2.thoroughfare,
          place2.locality,
          place2.administrativeArea,
          place2.postalCode,
          place2.country,
        ].where((e) => e != null && e.isNotEmpty).join(", ");
      });
    }

    // print("Address 1: $address1");
    // print("Address 2: $address2");

    // You can now use address1 and address2 as needed
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }
  late GoogleMapController _googleMapController;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const PreferredSize(
          preferredSize: Size(300, 70),
          child: CustomAppbar(text: "Location"),
        ),
        body: Stack(
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              initialCameraPosition:CameraPosition(target:LatLng(lat1,lng1),
                  zoom: 12),
              markers: Set<Marker>.of(_marker),
              onMapCreated: (controller)=>_googleMapController=controller,
            ),
            if(widget.addressShow==true)
            Positioned(
              bottom: 10,left: 20,right: 20,
             child:
             //    child: widget.img1=="null"&&widget.img2=="null"?
             // Center(child: Container(
             //   width: 200,
             //   height: 50,
             //   decoration: customDecoration.baseBackgroundDecoration(
             //     color: Colors.grey.shade50,
             //     radius: 5
             //   ),
             //    child: const Center(child: CustomText(text: "No Images Found",colors: Colors.black,size: 15,)))):
            Container(
              // height: 100,
              width: MediaQuery.of(context).size.width*0.85,
              decoration: customDecoration.baseBackgroundDecoration(color: Colors.white,radius: 10),
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     if(widget.img1!="null")
              //       InkWell(
              //         onTap: (){
              //           Get.to(FullScreen(image: widget.img1, isNetwork: true));
              //         },
              //         child: Column(
              //           children: [
              //             CustomText(text: "IN - ${widget.inTime}",colors: Colors.grey,size: 13,),
              //             Container(
              //               height: 130,
              //               width: 130,
              //               decoration: BoxDecoration(
              //                   borderRadius: BorderRadius.circular(10)
              //               ),
              //               child: CachedNetworkImage(
              //                   imageUrl: widget.img1,fit:BoxFit.cover ,
              //                   imageBuilder: (context, imageProvider) =>
              //                       Container(
              //                         decoration: BoxDecoration(
              //                           borderRadius: BorderRadius.circular(5),
              //                           image: DecorationImage(
              //                             image: imageProvider,
              //                             fit: BoxFit.cover,
              //                             // colorFilter:
              //                             // ColorFilter.mode(Colors.red, BlendMode.colorBurn)
              //                           ),
              //                         ),
              //                       ),
              //                   errorWidget: (context,url,error)=>const Center(child: Icon(Icons.error),),
              //                   placeholder: (context,url)=>const Loading()
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     if(widget.img2!="null")
              //       InkWell(
              //         onTap: (){
              //           Get.to(FullScreen(image: widget.img2, isNetwork: true));
              //         },
              //         child: Column(
              //           children: [
              //             CustomText(text: "OUT - ${widget.outTime}",colors: Colors.grey,size: 13,),
              //             Container(
              //               height: 130,
              //               width: 130,
              //               decoration: BoxDecoration(
              //                   borderRadius: BorderRadius.circular(10)
              //               ),
              //               child: CachedNetworkImage(
              //                   imageUrl: widget.img2,fit:BoxFit.cover ,
              //                   imageBuilder: (context, imageProvider) =>
              //                       Container(
              //                         decoration: BoxDecoration(
              //                           borderRadius: BorderRadius.circular(5),
              //                           image: DecorationImage(
              //                             image: imageProvider,
              //                             fit: BoxFit.cover,
              //                             // colorFilter:
              //                             // ColorFilter.mode(Colors.red, BlendMode.colorBurn)
              //                           ),
              //                         ),
              //                       ),
              //                   errorWidget: (context,url,error)=>const Center(child: Icon(Icons.error),),
              //                   placeholder: (context,url)=>const Loading()
              //               ),
              //             ),
              //           ],
              //         ),
              //       )
              //   ],
              // ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    5.height,
                    CustomText(text: "Check In",colors: colorsConst.greyClr,isBold: true,),5.height,
                    CustomText(text: address1),5.height,
                    if(address2!="")
                    CustomText(text: "Check Out",colors: colorsConst.greyClr,isBold: true),5.height,
                    if(address2!="")
                    CustomText(text: address2),5.height,
                  ],
                ),
              ),
            )
            )
          ],
        ),
      ),
    );
  }
}
