import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/component/custom_appbar.dart';

import '../../source/constant/colors_constant.dart';
import '../../source/utilities/utils.dart';

import '../../view_model/customer_provider.dart';
import '../../view_model/home_provider.dart';

import '../common/dashboard.dart';
import '../common/home_page.dart';

class TrackingLive extends StatefulWidget {
  const TrackingLive({super.key});

  @override
  State<TrackingLive> createState() => _TrackingLiveState();
}

class _TrackingLiveState extends State<TrackingLive> {
  GoogleMapController? _googleMapController;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CustomerProvider>().getLiveTrack();
    });
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  void _moveCamera(CustomerProvider provider) {
    if (_googleMapController != null &&
        provider.liveMarker.isNotEmpty) {
      _googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          provider.liveMarker.first.position,
          15,
        ),
      );

      Future.delayed(const Duration(milliseconds: 400), () {
        _googleMapController!.showMarkerInfoWindow(
          provider.liveMarker.first.markerId,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider, HomeProvider>(
      builder: (context, custProvider, homeProvider, _) {

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _moveCamera(custProvider);
        });

        return SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: CustomAppbar(
                text: "Tracking Employee",
                callback: () {
                  homeProvider.updateIndex(0);
                  utils.navigatePage(
                    context,
                        () => const DashBoard(child: HomePage()),
                  );
                },
              ),
            ),

            body: PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                homeProvider.updateIndex(0);

                if (!didPop) {
                  utils.navigatePage(
                    context,
                        () => const DashBoard(child: HomePage()),
                  );
                }
              },

              child: Stack(
                children: [

                  /// GOOGLE MAP
                  GoogleMap(
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,

                    initialCameraPosition: const CameraPosition(
                      target: LatLng(11.1271, 78.6569),
                      zoom: 6,
                    ),

                    markers: Set<Marker>.of(custProvider.liveMarker),

                    onMapCreated: (controller) {
                      _googleMapController = controller;
                      _moveCamera(custProvider);
                    },
                  ),

                  /// LOADING
                  if (!custProvider.refresh)
                    Container(
                      color: Colors.black.withOpacity(.15),
                      child: const Center(
                        child: Loading(),
                      ),
                    ),

                  /// NO DATA
                  if (custProvider.refresh &&
                      custProvider.liveMarker.isEmpty)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomText(
                          text: "No Tracking Employees Found",
                          colors: colorsConst.greyClr,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}