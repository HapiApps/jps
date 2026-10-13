import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../../component/custom_text.dart';
import '../../model/track/track_model.dart';

class TrackedLocation extends StatefulWidget {
  final List<TrackingModel> trackData;
  const TrackedLocation({super.key, required this.trackData});

  @override
  State<TrackedLocation> createState() => _TrackedLocationState();
}

class _TrackedLocationState extends State<TrackedLocation> {
  late GoogleMapController _googleMapController;
  MarkerId? firstMarkerId;  // Store the first marker ID

  @override
  void initState() {
    _createMarkers();
    super.initState();
  }

  Future<String> _getAddress(double lat, double lng) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placeMarks[0];
    return "${place.street}, ${place.administrativeArea}, ${place.locality}, ${place.postalCode}, ${place.country}"; // Customize as needed
  }

  Set<Marker> markers = {};
  Set<Marker> _createMarkers() {
    for (var i = 0; i < widget.trackData.length; i++) {
      var entry = widget.trackData[i];
      double firstLat = double.parse(entry.firstLat);
      double firstLng = double.parse(entry.firstLng);
      String unitId = entry.unitName.toString() == "null" ? "Main" : entry.unitName.toString();
      MarkerId markerId = MarkerId(unitId);

      if (i == 0) {
        // Store the MarkerId of the first marker
        firstMarkerId = markerId;
      }

      markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(firstLat, firstLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
            title: "Unit: $unitId",
            // snippet: "View Location...",
            snippet: "View Location...",
            onTap: () async {
              String address = await _getAddress(firstLat, firstLng);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: SizedBox(
                    height: 200,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        10.height,
                        Row(
                          children: [
                            const SizedBox(
                              width: 70,
                                child: CustomText(text: "Unit Name", colors: Colors.grey)),
                            CustomText(text: unitId),
                          ],
                        ),
                        10.height,
                        Row(
                          children: [
                            const SizedBox(
                                width: 70,
                                child: CustomText(text: "Location  ", colors: Colors.grey)),
                            SizedBox(width: 150, child: CustomText(text: address)),
                          ],
                        ),
                        10.height,
                        Row(
                          children: [
                            const SizedBox(
                                width: 70,
                                child: CustomText(text: "Time  ", colors: Colors.grey)),
                            CustomText(text: "${entry.firstCreatedTs}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const CustomText(text: "Tracked Location", colors: Colors.black, size: 15,isBold: true,),
        elevation: 0.0,
      ),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            double.parse(widget.trackData[0].firstLat.toString()),
            double.parse(widget.trackData[0].firstLng.toString()),
          ),
          zoom: 10,
        ),
        markers: _createMarkers(),
        onMapCreated: (controller) {
          _googleMapController = controller;

          // Show the info window of the first marker after a delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (firstMarkerId != null) {
              _googleMapController.showMarkerInfoWindow(firstMarkerId!);
            }
          });
        },
      ),
    );
  }
}


