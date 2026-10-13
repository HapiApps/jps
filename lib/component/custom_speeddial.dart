import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
class CustomSpeedDial extends StatelessWidget {
  final Color bgColor;
  final String childLabel1;
  final String childLabel2;
  final VoidCallback childOnTap1;
  final VoidCallback childOnTap2;
  final String childImg1;
  final String childImg2;
  const CustomSpeedDial({super.key, required this.bgColor, required this.childLabel1, required this.childLabel2, required this.childOnTap1, required this.childOnTap2, required this.childImg1, required this.childImg2});
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return SpeedDial(
          shape: const CircleBorder(),
          foregroundColor: Colors.black,
          animatedIconTheme: const IconThemeData(size: 22, color: Colors.white),
          closeDialOnPop: true,
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: bgColor,
          children: [
            SpeedDialChild(
              shape: const CircleBorder(),
              backgroundColor: bgColor,
              child: SvgPicture.asset(childImg1),
              label: childLabel1,
              labelBackgroundColor: bgColor,
              labelStyle: const TextStyle(color: Colors.white),
              onTap: childOnTap1,
            ),
            SpeedDialChild(
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              child: SvgPicture.asset(childImg2),
              label: childLabel2,
              labelBackgroundColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.black),
              onTap: childOnTap2,
            ),
          ],
        );
      },
    );
  }
}
