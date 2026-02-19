import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master_code/model/customer/customer_report_model.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../source/constant/api.dart';
import '../source/constant/assets_constant.dart';
import '../source/constant/colors_constant.dart';
import '../source/styles/decoration.dart';
import 'audio_player.dart';
import 'custom_text.dart';

class CustomComment extends StatelessWidget {
  final CustomerReportModel data;
  final bool? isCompany;
  final bool? isUsers;
  const CustomComment({super.key, required this.data, this.isCompany=false, this.isUsers});

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.9;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    var docList=data.documents.toString().split('||');
    return SizedBox(
      width: kIsWeb?webWidth:phoneWidth,
      child: Column(
        children: [
          Center(child: CustomText(text: DateFormat("MMM d, yyyy").format(DateTime.parse(data.createdTs.toString())),colors: colorsConst.primary,)),10.height,
          Container(
              decoration: customDecoration.baseBackgroundDecoration(
                  color: Colors.white,
                  radius: 5,
                  borderColor: Colors.grey.shade200,isShadow: true,shadowColor: Colors.grey.shade200
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.height,
                  Center(child: CustomText(text: "Meeting Discussion",colors: colorsConst.primary,)),
                  5.height,
                  Center(
                    child: SizedBox(
                      // color: Colors.yellow,
                        width: MediaQuery.of(context).size.width*0.75,
                        child: CustomText(text: data.comments.toString())),
                  ),
                  10.height,
                ],
              )),
          if(docList[0]!="")
            const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: "\nNotes/Attachments:\n",isBold: true,),
            ],
          ),
          if(docList[0]!="")
            GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 50,
                  mainAxisSpacing: 50,
                  mainAxisExtent: 70,
                ),
            itemCount: docList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context,index){
              // print(docList);
              //   print('$imageFile?path=${docList[index]}');
                return  SizedBox(
                  width: 70,height:70,
                  child: docList[index].endsWith(".jpg")||docList[index].endsWith(".png")||docList[index].endsWith(".jpeg")?
                  ShowNetWrKImg(img: docList[index],)
                  :docList[index].endsWith(".mp4")?Image.asset(assets.video): AudioTile(audioUrl: '$imageFile?path=${docList[index]}')
                );
              }
          )
        ],
      ),
    );
  }
}
