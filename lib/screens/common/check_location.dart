import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
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

  /// true -> only the map (no Scaffold / AppBar). Used inside the dialog.
  final bool embedded;

  const CheckLocation({
    super.key,
    required this.lat1,
    required this.long1,
    required this.lat2,
    required this.long2,
    this.addressShow,
    this.embedded = false,
  });

  @override
  State<CheckLocation> createState() => _CheckLocationState();
}

class _CheckLocationState extends State<CheckLocation> {
  final List<Marker> _marker = [];

  // lazy: Geocoding() is never created on web
  late final Geocoding geocodingService = Geocoding();

  double lat1 = 0.0;
  double lat2 = 0.0;
  double lng1 = 0.0;
  double lng2 = 0.0;
  String address1 = '';
  String address2 = '';

  GoogleMapController? _googleMapController;

  // web (flutter_map) controller
  final fm.MapController _webController = fm.MapController();

  bool get _hasIn => !(lat1 == 0.0 && lng1 == 0.0);
  bool get _hasOut => lat2 != 0.0 && lng2 != 0.0;

  @override
  void initState() {
    super.initState();

    lat1 = double.tryParse(widget.lat1.trim()) ?? 0.0;
    lng1 = double.tryParse(widget.long1.trim()) ?? 0.0;
    lat2 = double.tryParse(widget.lat2.trim()) ?? 0.0;
    lng2 = double.tryParse(widget.long2.trim()) ?? 0.0;

    // Google markers are needed only on Android / iOS
    if (!kIsWeb) {
      _marker.add(
        Marker(
          markerId: const MarkerId("1"),
          position: LatLng(lat1, lng1),
          infoWindow: const InfoWindow(title: "Check In"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      if (_hasOut) {
        _marker.add(
          Marker(
            markerId: const MarkerId("2"),
            position: LatLng(lat2, lng2),
            infoWindow: const InfoWindow(title: "Check Out"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }

    getAddress(lat1, lng1, lat2, lng2);
  }

  String _join(Placemark p) => [
    p.street,
    p.subLocality,
    p.thoroughfare,
    p.locality,
    p.administrativeArea,
    p.postalCode,
    p.country,
  ].where((e) => e != null && e.isNotEmpty).join(", ");

  Future<void> getAddress(
      double lat, double lng, double lat2, double lng2) async {
    // geocoding package has no web support
    if (kIsWeb) return;
    try {
      final p1 = await geocodingService.placemarkFromCoordinates(lat, lng);
      if (!mounted) return;
      if (p1.isNotEmpty) setState(() => address1 = _join(p1[0]));

      if (lat2 != 0.0 && lng2 != 0.0) {
        final p2 = await geocodingService.placemarkFromCoordinates(lat2, lng2);
        if (!mounted) return;
        if (p2.isNotEmpty) setState(() => address2 = _join(p2[0]));
      }
    } catch (e) {
      debugPrint("getAddress failed: $e");
    }
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _webController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // WEB map: flutter_map + OpenStreetMap (no API key, no script tag)
  // ==========================================================================
  Widget _webMap() {
    if (!_hasIn) {
      return Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: CustomText(
          text: "Location not available",
          size: 14,
          colors: colorsConst.greyClr,
        ),
      );
    }

    final p1 = ll.LatLng(lat1, lng1);
    final ll.LatLng? p2 = _hasOut ? ll.LatLng(lat2, lng2) : null;

    final fm.MapOptions options = p2 != null
        ? fm.MapOptions(
      // fit both points; extra bottom padding for the info card
      initialCameraFit: fm.CameraFit.bounds(
        bounds: fm.LatLngBounds(p1, p2),
        padding: const EdgeInsets.fromLTRB(60, 70, 60, 200),
        maxZoom: 17,
      ),
      minZoom: 3,
      maxZoom: 19,
    )
        : fm.MapOptions(
      initialCenter: p1,
      initialZoom: 16,
      minZoom: 3,
      maxZoom: 19,
    );

    return Stack(
      children: [
        fm.FlutterMap(
          mapController: _webController,
          options: options,
          children: [
            fm.TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.yourcompany.yourapp', // TODO: your package name
            ),
            if (p2 != null)
              fm.PolylineLayer(
                polylines: [
                  fm.Polyline(
                    points: [p1, p2],
                    strokeWidth: 3,
                    color: Colors.blue,
                  ),
                ],
              ),
            fm.MarkerLayer(
              markers: [
                fm.Marker(
                  point: p1,
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on,
                      color: Colors.green, size: 38),
                ),
                if (p2 != null)
                  fm.Marker(
                    point: p2,
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 38),
                  ),
              ],
            ),
            // OSM attribution is required by their tile policy
            const fm.RichAttributionWidget(
              alignment: fm.AttributionAlignment.bottomLeft,
              attributions: [
                fm.TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),

        // zoom buttons (right side, below the dialog close button)
        Positioned(
          top: 56,
          right: 10,
          child: Column(
            children: [
              _zoomBtn(Icons.add, () {
                final c = _webController.camera;
                _webController.move(c.center, c.zoom + 1);
              }),
              6.height,
              _zoomBtn(Icons.remove, () {
                final c = _webController.camera;
                _webController.move(c.center, c.zoom - 1);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  // ==========================================================================
  // MOBILE map: Google Maps (unchanged)
  // ==========================================================================
  Widget _googleMap() {
    return GoogleMap(
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      initialCameraPosition:
      CameraPosition(target: LatLng(lat1, lng1), zoom: 12),
      markers: Set<Marker>.of(_marker),
      onMapCreated: (controller) => _googleMapController = controller,
    );
  }

  Widget _mapBody(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: kIsWeb ? _webMap() : _googleMap()),
        if (widget.addressShow == true)
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: customDecoration.baseBackgroundDecoration(
                  color: Colors.white, radius: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    5.height,
                    CustomText(
                        text: "Check In",
                        colors: colorsConst.greyClr,
                        isBold: true),
                    5.height,
                    CustomText(text: address1),
                    5.height,
                    if (address2 != "") ...[
                      CustomText(
                          text: "Check Out",
                          colors: colorsConst.greyClr,
                          isBold: true),
                      5.height,
                      CustomText(text: address2),
                      5.height,
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _mapBody(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const PreferredSize(
          preferredSize: Size(300, 70),
          child: CustomAppbar(text: "Location"),
        ),
        body: _mapBody(context),
      ),
    );
  }
}