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

/// ✅ MULTI CHECK IN / OUT: oru check in -> check out jodi.
/// outTime "" = innum check out pannala (office-la irukkaanga)
class AttSession {
  final String inTime;
  final String outTime;
  const AttSession(this.inTime, this.outTime);
  bool get isOpen => outTime.trim().isEmpty || outTime.trim() == "-";
}

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

  /// ✅ NEW: andha naal ella check in / out (time order). 2+ irundha
  /// In / Out column-la ovvoru line-a kaattum. Illana pazhaya madhiri.
  final List<AttSession> sessions;

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
    this.sessions = const [],
  });

  bool get _multi => sessions.length > 1;

  /// Total: multi-la check out pannala-naalum (open session) mudinja
  /// sessions-oda total kaattum. Single-la pazhaya rule.
  String get _totalText {
    if (_multi) return (timeD.trim().isEmpty || timeD == "null") ? "-" : timeD;
    return outTime.toString() == "-" ? "-" : timeD;
  }

  /// In / Out column value. Multi-na ovvoru line-um, illana single text.
  Widget _timeColumn({required bool isIn, required double size, bool bold = false}) {
    if (!_multi) {
      final String v = isIn
          ? (inTime.toString() != "null" ? inTime : "-")
          : outTime.toString();
      return CustomText(text: v, size: size, isBold: bold);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < sessions.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 3),
            child: isIn
                ? CustomText(text: sessions[i].inTime, size: size, isBold: bold)
                : sessions[i].isOpen
                ? CustomText(
                text: "Working…",
                size: size,
                isBold: true,
                colors: Colors.orange.shade800)
                : CustomText(text: sessions[i].outTime, size: size, isBold: bold),
          ),
      ],
    );
  }

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

    // ✅ Web-ku dedicated clean layout (Expanded based, overflow aagaadhu)
    if (kIsWeb) return _webLayout(context, chunked);

    return _mobileLayout(context, chunked);
  }

  // ===================== MOBILE LAYOUT (premium card) =====================
  // Ellaa pazhaya features-um irukku:
  //  * admin -> avatar + name + role (tap -> EmployeeDetails)
  //  * employee -> date
  //  * In / Out / Total (multi check in / out line by line)
  //  * late -> orange tint + "Late" badge
  //  * map icon + card tap -> callback
  //  * in / out area name
  //  * permissions list (admin-ku name-oda)
  //  * isName == false -> name block illama compact
  Widget _mobileLayout(BuildContext context, List chunked) {
    final bool isAdmin = localData.storage.read("role") == "1";
    final bool late = isLate(inTime);
    final bool showName = isName == true && isAdmin;
    final bool hasIn = inLat != null && inLng != null && inLat!.isNotEmpty && inLng!.isNotEmpty;
    final bool hasOut = outLat != null && outLng != null && outLat!.isNotEmpty && outLng!.isNotEmpty;
    final Color primary = colorsConst.primary;
    const Color lateClr = Color(0xFFE65100);

    Widget lateBadge() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const CustomText(text: "Late", size: 10, isBold: true, colors: lateClr),
    );

    Widget label(String t, Color dot) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        4.width,
        CustomText(text: t, size: 10, colors: Colors.grey.shade600),
      ],
    );

    Widget timeCell(String t, Color dot, Widget value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [label(t, dot), 5.height, value],
      ),
    );

    Widget areaText(String lat, String lng) => FutureBuilder<String>(
      future: _getAreaName(lat, lng),
      builder: (context, snapshot) => CustomText(
        text: snapshot.hasData ? snapshot.data! : "...",
        size: 11,
        colors: Colors.grey.shade700,
      ),
    );

    // ---------- header (name / date + late + map) ----------
    final Widget header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showName)
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeDetails(id: empId, active: active, role: role),
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: primary.withOpacity(0.10),
                    child: SvgPicture.asset(assets.profile, width: 18, height: 18),
                  ),
                  10.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: name, isBold: true, size: 14),
                        2.height,
                        CustomText(text: role, colors: colorsConst.blueClr, size: 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: primary),
                6.width,
                Flexible(child: CustomText(text: date, size: 13, isBold: true)),
              ],
            ),
          ),
        if (late) ...[lateBadge(), 8.width],
        _mapIcon(callback),
      ],
    );

    // ---------- times strip ----------
    final Widget times = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: late ? Colors.white.withOpacity(0.7) : const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          timeCell("In Time", Colors.green, _timeColumn(isIn: true, size: 12, bold: true)),
          timeCell("Out Time", Colors.red, _timeColumn(isIn: false, size: 12, bold: true)),
          timeCell(
            "Total Hrs",
            primary,
            CustomText(text: _totalText, size: 12, isBold: true, colors: primary),
          ),
        ],
      ),
    );

    // ---------- location ----------
    final Widget? location = (!hasIn && !hasOut)
        ? null
        : Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
          4.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasIn) areaText(inLat!, inLng!),
                if (hasIn && hasOut) 2.height,
                if (hasOut) areaText(outLat!, outLng!),
              ],
            ),
          ),
        ],
      ),
    );

    // ---------- permissions ----------
    final Widget? permissions = chunked.isEmpty
        ? null
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        10.height,
        Divider(height: 1, color: Colors.grey.shade200),
        8.height,
        Row(
          children: [
            Icon(Icons.lock_clock, size: 13, color: Colors.purple.shade400),
            5.width,
            CustomText(
              text: "Permission${chunked.length == 1 ? "" : "s"}",
              size: 11,
              isBold: true,
              colors: Colors.purple.shade400,
            ),
          ],
        ),
        for (final item in chunked)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAdmin && isName == false)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: CustomText(text: name, size: 11, isBold: true),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CustomText(
                        text: "${item['in']} - ${item['out'] == "" ? "…" : item['out']}",
                        size: 11,
                        isBold: true,
                      ),
                    ),
                    8.width,
                    CustomText(
                      text: item["out"] != ""
                          ? timeDifference("${item["in"]},${item["out"]}")
                          : "-",
                      size: 11,
                      isBold: true,
                      colors: Colors.grey.shade700,
                    ),
                    8.width,
                    Expanded(
                      child: CustomText(
                        text: "${item['reason']}",
                        size: 11,
                        colors: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // parent-oda callback (map open)
          onTap: callback,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isName == false ? 10 : 12),
            decoration: BoxDecoration(
              color: late ? const Color(0xFFFFF8EE) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: late ? const Color(0xFFFFD8A8) : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                10.height,
                times,
                if (location != null) location,
                if (permissions != null) permissions,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== WEB LAYOUT =====================
  Widget _webLayout(BuildContext context, List chunked) {
    final bool isAdmin = localData.storage.read("role") == "1";
    final bool late = isLate(inTime);
    final bool hasIn = inLat != null && inLng != null && inLat!.isNotEmpty && inLng!.isNotEmpty;
    final bool hasOut = outLat != null && outLng != null && outLat!.isNotEmpty && outLng!.isNotEmpty;

    Widget cell(String label, String value, {Widget? child}) => Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: label, colors: Colors.grey, size: 11),
          4.height,
          child ?? CustomText(text: value, size: 13, isBold: true),
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
                crossAxisAlignment:
                _multi ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                  cell("In Time", "", child: _timeColumn(isIn: true, size: 13, bold: true)),
                  cell("Out Time", "", child: _timeColumn(isIn: false, size: 13, bold: true)),
                  cell("Total Hrs", _totalText),
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