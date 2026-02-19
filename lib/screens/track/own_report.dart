import 'dart:math';
import 'package:flutter/material.dart';
import 'package:master_code/screens/track/tracked_location.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../model/track/track_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/customer_provider.dart';

class OwnReport extends StatefulWidget {
  final String id;
  final String name;
  const OwnReport({super.key, required this.id, required this.name});

  @override
  State<OwnReport> createState() => _OwnReportState();
}

class _OwnReportState extends State<OwnReport> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<CustomerProvider>(context, listen: false).getTrackReport(widget.id,false);
    });
  super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(builder: (context,custProvider,_){
      return SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 120),
          child: CustomAppbar(text: constValue.trackR),
        ),
        body:  SingleChildScrollView(
          child: Column(
            children: [
              25.height,
              CustomText(text: 'Date: ${custProvider.startDate}'),
              custProvider.refresh==false?const Padding(
                padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                child: Loading(),
              )
                  :custProvider.reportData.isNotEmpty?
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: custProvider.reportData.length,
                itemBuilder: (context, index) {
                  final transition = custProvider.reportData[index];
                  // double firstLat = double.parse(transition.firstLat);
                  // double firstLng = double.parse(transition.firstLng);
                  // double lastLat = double.parse(transition.lastLat);
                  // double lastLng = double.parse(transition.lastLng);
                  //
                  // double distance = calculateDistance(firstLat, firstLng, lastLat, lastLng);
                  double overallDistance = calculateOverallDistance(custProvider.reportData);
                  // String durationUnit = calculateDuration(transition.firstCreatedTs.toString(), transition.lastCreatedTs.toString());
                  ///
                  double firstLat = double.parse(transition.firstLat);
                  double firstLng = double.parse(transition.firstLng);

                  double distance = 0.0;
                  String duration = '';

                  if (index > 0) {
                    final previousTransition = custProvider.reportData[index - 1];
                    double previousFirstLat = double.parse(previousTransition.firstLat);
                    double previousFirstLng = double.parse(previousTransition.firstLng);

                    distance = calculateDistance(previousFirstLat, previousFirstLng, firstLat, firstLng);
                    duration = calculateDuration(previousTransition.firstCreatedTs.toString(), transition.firstCreatedTs.toString());
                    // print(previousTransition.firstCreatedTs.toString());
                    // print(transition.firstCreatedTs.toString());
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Column(
                      children: [
                        if(index==0)
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(text: 'Start Time: ${formatTime(transition.firstCreatedTs.toString())}'),
                              CustomText(text: 'End Time: ${formatTime(transition.lastCreatedTs.toString())}'),
                              GestureDetector(
                                  onTap:(){
                                    utils.navigatePage(context, ()=>TrackedLocation(trackData: custProvider.reportData));
                                  },
                                  child: const Icon(Icons.location_on_outlined,color: Colors.red,))
                            ],
                          ),
                        if(index==0)
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(text: 'Total Distance: ${overallDistance.toStringAsFixed(2)} km\n'),
                              CustomText(text: 'Visit Count: ${custProvider.reportData.length-1}\n'),
                            ],
                          ),
                        if(index!=0)
                          Container(
                            decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,
                              radius: 5,
                              borderColor: Colors.grey.shade200,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Column(
                                children: [
                                  5.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const CustomText(text:'Unit Name: ',colors: Colors.grey,),
                                          CustomText(text:'${transition.unitName}'),
                                        ],
                                      ),
                                      CustomText(text: 'Distance: ${distance.toStringAsFixed(2)} km',colors: Colors.grey,),
                                    ],
                                  ),
                                  5.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Row(
                                      //   children: [
                                      //     const CustomText(text: "Time Spent In Unit  ",colors: Colors.grey,),
                                      //     CustomText(text: durationUnit),
                                      //   ],
                                      // ),
                                      CustomText(text: 'Duration: $duration',colors: Colors.grey,),
                                    ],
                                  ),
                                  5.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(text: 'In Time: ${formatTime(transition.firstCreatedTs.toString())}'),
                                      CustomText(text: 'Out Time: ${formatTime(transition.lastCreatedTs.toString())}'),
                                    ],
                                  ),
                                  5.height,
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ):const Padding(
                padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                child: CustomText(text: "No Data Found"),
              ),
            ],
          ),
        ),
      ),
    );
    });
  }
  // Function to calculate duration between two timestamps
  String calculateDuration(String startTs, String endTs) {
    DateTime start = DateTime.parse(startTs);
    DateTime end = DateTime.parse(endTs);
    Duration difference = end.difference(start);
    return "${difference.inHours.toString().padLeft(2,"0")}: ${difference.inMinutes.remainder(60).toString().padLeft(2,"0")}: ${difference.inSeconds.remainder(60)}";
  }
  String formatTime(String dateTimeString) {
    // Parse the string into a DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Format the time to only display hours and minutes
    String hours = dateTime.hour.toString().padLeft(2, '0');
    String minutes = dateTime.minute.toString().padLeft(2, '0');

    return '$hours:$minutes';
  }
  double calculateOverallDistance(List<TrackingModel> trackData) {
    double totalDistance = 0.0;

    for (int i = 0; i < trackData.length - 1; i++) {
      var currentPoint = trackData[i];
      var nextPoint = trackData[i + 1];

      // Get the lat/lng values for current and next points
      double currentLat = double.parse(currentPoint.lastLat);
      double currentLng = double.parse(currentPoint.lastLng);
      double nextLat = double.parse(nextPoint.firstLat);
      double nextLng = double.parse(nextPoint.firstLng);

      // Calculate distance between consecutive points
      double distance = calculateDistance(currentLat, currentLng, nextLat, nextLng);
      totalDistance += distance;
    }

    return totalDistance;
  }
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371; // Radius of the Earth in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in kilometers
  }

// Helper function to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
