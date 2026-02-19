import 'package:flutter/material.dart';
import '../screens/common/check_location.dart';
import '../source/constant/colors_constant.dart';
import '../source/utilities/utils.dart';
import 'custom_text.dart';

class CustomReport extends StatelessWidget {
  final String date;
  final String inTime;
  final String outTime;
  final String name;
  final String role;
  final String inLat;
  final String outLat;
  final String inLng;
  final String outLng;
  final String image1;
  final String image2;
  final String projectName;
  final String main;
  const CustomReport({super.key, required this.date, required this.inTime, required this.outTime, required this.name, required this.role, required this.inLat, required this.outLat, required this.inLng, required this.outLng, required this.image1, required this.image2, required this.projectName, required this.main});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: main=="1"?colorsConst.primary.withOpacity(0.1):Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)
                ),
                border: Border.all(
                    color: Colors.grey.shade100,
                    width: 2
                )
            ),
            height: 50,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: name,colors: Colors.black,isBold: true,size: 13,),
                          CustomText(text: role,colors: Colors.grey,size: 13,),
                        ],
                      ),
                      CustomText(text: projectName=="null"?"":projectName,colors: colorsConst.greyClr,size: 13,),
                      InkWell(
                          onTap: (){
                            utils.navigatePage(context, ()=>CheckLocation(
                                lat1: inLat,
                                long1: inLng,
                                lat2: outLat,
                                long2: outLng
                            ));
                          },
                          child: Icon(Icons.location_on,color: colorsConst.primary,)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)
              ),
            ),
            height: 50,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomText(text: "Date",colors: Colors.grey,size: 13,),
                      CustomText(text: utils.dateReturn(date),colors: Colors.black,isBold: true, size: 13,),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomText(text: "In Time",colors: Colors.grey,size: 13,),
                      CustomText(text: inTime,colors:Colors.black,isBold: true, size: 13,),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomText(text: "Out Time",colors: Colors.grey,size: 13,),
                      CustomText(text: outTime=="null"?"-":outTime,colors:Colors.black,isBold: true, size: 13,),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
