import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:master_code/screens/employee/employee_details.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/lib_extensions.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/styles/decoration.dart';
import '../source/constant/local_data.dart';
import '../source/extentions/int_extensions.dart';
import '../source/utilities/utils.dart';
import 'custom_text.dart';

/// simple cache to avoid repeated reverse-geocoding calls for the same lat/lng
final Map<String, String> _areaCache = {};

class AttendanceDetails extends StatelessWidget {
  final String date;
  final bool? showDate;
  final String inTime;
  final String outTime;
  final VoidCallback callback;
  final String img;
  final String timeD;
  final String name;
  final String role;
  final String perCreatedTs;
  final String perStatus;
  final String perReason;
  final String perTime;
  final bool? isName;
  final String? inLat;
  final String? inLng;
  final String? outLat;
  final String? outLng;
  final String empId;
  final String active;

  const AttendanceDetails({
    super.key,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.callback,
    required this.img,
    required this.timeD,
    required this.name,
    required this.role,
    this.showDate = false,
    required this.perStatus,
    required this.perReason,
    required this.perTime,
    required this.perCreatedTs,
    this.isName = true,
    this.inLat,
    this.inLng,
    this.outLat,
    this.outLng,
    required this.empId,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    var perCreatedTsList = perCreatedTs.toString().split(',');
    var perStatusList = perStatus.toString().split(',');
    var perReasonList = perReason.toString().split(',');
    var perTimeList = perTime.toString().split(',');
    List chunked = [];

    if (perTime.toString() != "null" && perTime.toString() != "") {
      for (var i = 0; i < perTimeList.length; i += 2) {
        String inTime = perTimeList[i];
        String outTime = (i + 1 < perTimeList.length) ? perTimeList[i + 1] : ""; // fallback

        String inTs = i < perCreatedTsList.length ? perCreatedTsList[i] : "";
        String outTs = (i + 1 < perCreatedTsList.length) ? perCreatedTsList[i + 1] : "";

        chunked.add({
          "in": inTime,
          "out": outTime,
          "reason": i < perReasonList.length ? perReasonList[i] : "",
          "status": i < perStatusList.length ? perStatusList[i] : "",
          "in_ts": inTs,
          "out_ts": outTs
        });
      }
    }
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.95;

    // ✅ Web-ku dedicated clean layout (Expanded based, overflow aagaadhu)
    if (kIsWeb) return _webLayout(context, chunked);

    return Column(
      children: [
        if (localData.storage.read("role") != "1" && showDate == true)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: kIsWeb ? webWidth / 4 : phoneWidth / 4,
                    child: CustomText(text: "Date", colors: colorsConst.greyClr, size: 12,)),
                5.width,
                SizedBox(
                  width: kIsWeb ? webWidth / 5 : phoneWidth / 5,
                  child: const CustomText(text: "In Time", size: 12,),
                ), 5.width,
                SizedBox(
                  width: kIsWeb ? webWidth / 5 : phoneWidth / 5,
                  child: const CustomText(text: "Out Time", size: 12),
                ), 5.width,
                SizedBox(
                  width: kIsWeb ? webWidth / 5.2 : phoneWidth / 5.2,
                  child: CustomText(text: "Total Hrs", size: 12,),
                ),
              ],
            ),
          ),
        InkWell(
          // ✅ parent-oda callback use pannrom (web -> browser Google Maps, mobile -> CheckLocation)
          onTap: callback,
          child: Container(
            width: kIsWeb ? webWidth : phoneWidth,
            decoration: customDecoration.baseBackgroundDecoration(
                color: isLate(inTime) ? const Color(0xFFFFF3E0) : Colors.white,
                radius: 5,
                borderColor: Colors.grey.shade200, isShadow: true, shadowColor: Colors.grey.shade200
            ),
            child: Padding(
              padding: isName == false
                  ? const EdgeInsets.fromLTRB(5, 4, 5, 4)
                  : localData.storage.read("role") != "1"
                  ? const EdgeInsets.fromLTRB(5, 10, 5, 10)
                  : const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ FIX: "!kIsWeb" condition remove pannittom -> web-layum name, role show aagum
                      if (isName == true)
                        if (localData.storage.read("role") == "1")
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EmployeeDetails(id: empId, active: active, role: role)));
                            },
                            child: SizedBox(
                              width: kIsWeb ? webWidth / 3.8 : phoneWidth / 3.8,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.grey.shade400,
                                      child: SvgPicture.asset(assets.profile)
                                  ), 5.height,
                                  CustomText(text: name, isBold: true, size: 13,), 5.height,
                                  CustomText(text: role, colors: colorsConst.blueClr, size: 11,),
                                ],
                              ),
                            ),
                          ),
                      if (isName == true)
                        if (localData.storage.read("role") == "1")
                          Container(color: colorsConst.litGrey, width: 1, height: 75,),
                      if (localData.storage.read("role") != "1")
                        SizedBox(
                            width: kIsWeb ? webWidth / 4 : phoneWidth / 4,
                            child: CustomText(text: date, size: 12,)),
                      if (isName == true)
                        2.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // ---------------- IN TIME ----------------
                              SizedBox(
                                width: kIsWeb ? webWidth / 6 : phoneWidth / 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (localData.storage.read("role") == "1")
                                      const CustomText(text: "In Time", colors: Colors.grey, size: 11,),
                                    5.height,
                                    CustomText(text: inTime.toString() != "null" ? inTime : "-", size: 11,),
                                  ],
                                ),
                              ), 2.width,
                              // ---------------- OUT TIME ----------------
                              SizedBox(
                                width: kIsWeb ? webWidth / 5 : phoneWidth / 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (localData.storage.read("role") == "1")
                                      const CustomText(text: "Out Time", colors: Colors.grey, size: 11,),
                                    5.height,
                                    CustomText(text: outTime.toString(), size: 11),
                                  ],
                                ),
                              ), 2.width,
                              SizedBox(
                                width: kIsWeb ? webWidth / 5.2 : phoneWidth / 5.2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (localData.storage.read("role") == "1")
                                      const CustomText(text: "Total Hrs  ", colors: Colors.grey, size: 11,),
                                    if (localData.storage.read("role") == "1")
                                      2.height,
                                    CustomText(text: outTime.toString() == "-" ? "-" : timeD, size: 11,),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: _mapIcon(callback),
                              ),
                            ],
                          ),
                          5.height,
                          if (inLat != null && inLng != null && inLat!.isNotEmpty && inLng!.isNotEmpty)
                            FutureBuilder<String>(
                              future: _getAreaName(inLat!, inLng!),
                              builder: (context, snapshot) {
                                return CustomText(
                                  text: snapshot.hasData ? snapshot.data! : "...",
                                  size: 12,
                                  colors: Colors.black,
                                );
                              },
                            ),
                          5.height,
                          if (outLat != null && outLng != null && outLat!.isNotEmpty && outLng!.isNotEmpty)
                            FutureBuilder<String>(
                              future: _getAreaName(outLat!, outLng!),
                              builder: (context, snapshot) {
                                return CustomText(
                                  text: snapshot.hasData ? snapshot.data! : "...",
                                  size: 12,
                                  colors: Colors.black,
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),

                  if (chunked.isNotEmpty)
                    Padding(
                      padding: isName == false
                          ? const EdgeInsets.fromLTRB(5, 10, 5, 10)
                          : EdgeInsets.fromLTRB(
                          localData.storage.read("role") == "1" ? 10 : 2,
                          localData.storage.read("role") == "1" ? 0 : 5,
                          localData.storage.read("role") == "1" ? 10 : 2,
                          5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: kIsWeb ? webWidth / 1 : phoneWidth / 1,
                            height: 0.2, color: Colors.grey,
                          ),
                          5.height,
                          CustomText(text: "Permission${chunked.length == 1 ? "" : "s"}", colors: colorsConst.greyClr,),
                          5.height,
                          SizedBox(
                            width: kIsWeb ? webWidth : phoneWidth,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: chunked.length,
                              itemBuilder: (context, index) {
                                final item = chunked[index];
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (localData.storage.read("role") == "1" && chunked.isNotEmpty)
                                        SizedBox(
                                          width: kIsWeb ? webWidth / 4 : phoneWidth / 3,
                                          child: CustomText(
                                            text: name,
                                            size: 11,
                                            isBold: true,
                                          ),
                                        ),
                                      10.height,
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: kIsWeb ? webWidth / 3 : phoneWidth / 3,
                                            child: CustomText(text: "${item['in']} - ${item['out']}", size: 11, isBold: true,),
                                          ),
                                          SizedBox(
                                            width: kIsWeb ? webWidth / 5 : phoneWidth / 5,
                                            child: CustomText(
                                                text: item["out"] != "" ? timeDifference("${item["in"]},${item["out"]}") : "-",
                                                size: 11,
                                                isBold: true),
                                          ),
                                          SizedBox(
                                            width: kIsWeb ? webWidth / 3 : phoneWidth / 2.7,
                                            child: CustomText(text: "${item['reason']}", size: 11,),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===================== WEB LAYOUT =====================
  Widget _webLayout(BuildContext context, List chunked) {
    final bool isAdmin = localData.storage.read("role") == "1";
    final bool late = isLate(inTime);
    final bool hasIn = inLat != null && inLng != null && inLat!.isNotEmpty && inLng!.isNotEmpty;
    final bool hasOut = outLat != null && outLng != null && outLat!.isNotEmpty && outLng!.isNotEmpty;

    Widget cell(String label, String value) => Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: label, colors: Colors.grey, size: 11),
          4.height,
          CustomText(text: value, size: 13, isBold: true),
        ],
      ),
    );

    // ✅ CHANGED: geocoding web-la work aagaadhu, so web-la lat,lng-a
    // (4 decimal) kaattrom. "In: -" maathiri empty-a theriyaadhu.
    Widget areaLine(String label, String? lat, String? lng) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: CustomText(
          text: "$label: ${_fmtCoord(lat)}, ${_fmtCoord(lng)}",
          size: 12,
          colors: colorsConst.greyClr,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: callback,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: late ? const Color(0xFFFFF3E0) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ---------- LEFT: employee / date ----------
                  // ✅ CHANGED: 200 -> 180 (times ku konjam adhigam idam)
                  SizedBox(
                    width: 180,
                    child: (isAdmin && isName == true)
                        ? InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EmployeeDetails(id: empId, active: active, role: role),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade300,
                            child: SvgPicture.asset(assets.profile, width: 18, height: 18),
                          ),
                          10.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(text: name, isBold: true, size: 14),
                                2.height,
                                CustomText(text: role, colors: colorsConst.blueClr, size: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        : CustomText(text: date, size: 13, isBold: true),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.grey.shade300,
                  ),
                  // ---------- MIDDLE: times ----------
                  cell("In Time", inTime.toString() != "null" ? inTime : "-"),
                  cell("Out Time", outTime.toString()),
                  cell("Total Hrs", outTime.toString() == "-" ? "-" : timeD),
                  // ---------- RIGHT: location ----------
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: "Location", colors: Colors.grey, size: 11),
                        4.height,
                        if (!hasIn && !hasOut) CustomText(text: "-", size: 12),
                        if (hasIn) areaLine("In", inLat, inLng),
                        if (hasOut) areaLine("Out", outLat, outLng),
                      ],
                    ),
                  ),
                  8.width,
                  _mapIcon(callback),
                ],
              ),
              // ---------- PERMISSIONS ----------
              if (chunked.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                CustomText(
                  text: "Permission${chunked.length == 1 ? "" : "s"}",
                  colors: colorsConst.greyClr,
                  size: 12,
                ),
                6.height,
                for (final item in chunked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CustomText(
                              text: "${item['in']} - ${item['out']}", size: 12, isBold: true),
                        ),
                        Expanded(
                          flex: 2,
                          child: CustomText(
                              text: item["out"] != ""
                                  ? timeDifference("${item["in"]},${item["out"]}")
                                  : "-",
                              size: 12,
                              isBold: true),
                        ),
                        Expanded(
                          flex: 5,
                          child: CustomText(text: "${item['reason']}", size: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Common clickable map icon with bigger tap area and ripple effect
  Widget _mapIcon(VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(2),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: colorsConst.primary.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          assets.map,
          width: 30,
          height: 15,
          colorFilter: ColorFilter.mode(colorsConst.primary, BlendMode.srcIn),
        ),
      ),
    );
  }

  /// Grace 09:10 AM. Late only when check-in is AFTER 09:10
  /// (Excel report / provider rule oda same).
  bool isLate(String? inTime) {
    if (inTime == null || inTime.trim().isEmpty) return false;

    final format = DateFormat("hh:mm a");

    try {
      DateTime graceTime = format.parse("09:10 AM");
      DateTime userTime = format.parse(inTime);
      return userTime.isAfter(graceTime);
    } catch (e) {
      return false; // invalid time format
    }
  }

  String timeDifference(String timeRange) {
    try {
      List<String> parts = timeRange.split(',');

      DateFormat format = DateFormat("hh:mm a");

      DateTime startTime = format.parse(parts[0].trim());
      DateTime endTime = format.parse(parts[1].trim());

      Duration difference = endTime.difference(startTime);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} Mins";
      } else {
        int hours = difference.inHours;
        int minutes = difference.inMinutes.remainder(60);

        return minutes == 0 ? "$hours Hrs" : "$hours Hrs $minutes Mins";
      }
    } catch (e) {
      return "-"; // bad permission time -> crash aagaama
    }
  }

  DateTime parseTime(String time) {
    final now = DateTime.now();
    final parts = time.split(" ");
    final period = parts[1]; // AM or PM
    final timeParts = parts[0].split(":");
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    if (period == "PM" && hour != 12) {
      hour += 12;
    } else if (period == "AM" && hour == 12) {
      hour = 0;
    }

    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

/// ✅ lat/lng-a 4 decimal-ku short pannum (web-la area name illaama kaattradhukku)
String _fmtCoord(String? v) {
  final double? d = double.tryParse((v ?? "").trim());
  return d == null ? "-" : d.toStringAsFixed(4);
}

/// ✅ reverse-geocodes a lat/lng pair into "SubLocality, Locality"
/// (top-level final = lazy; web-la _getAreaName first-ye return aagum, so Geocoding() create aagaadhu)
final Geocoding geocodingService = Geocoding();
Future<String> _getAreaName(String lat, String lng) async {
  // ✅ ADDED: geocoding package has no web support
  if (kIsWeb) return "-";
  try {
    if (lat.isEmpty || lng.isEmpty) return "-";
    final String key = "$lat,$lng";
    if (_areaCache.containsKey(key)) return _areaCache[key]!;

    final double? latitude = double.tryParse(lat);
    final double? longitude = double.tryParse(lng);
    if (latitude == null || longitude == null) return "-";

    final List<Placemark> placemarks =
    await geocodingService.placemarkFromCoordinates(latitude, longitude);

    String result = "-";
    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks.first;
      final String sub = (place.subLocality ?? '').trim();
      final String loc = (place.locality ?? '').trim();
      final String area = [sub, loc]
          .where((e) => e.isNotEmpty)
          .toSet()
          .join(', ');

      result = area.isNotEmpty ? area : (place.name ?? "-");
    }
    _areaCache[key] = result;
    return result;
  } catch (e) {
    return "-";
  }
}