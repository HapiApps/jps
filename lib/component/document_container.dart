import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/component/custom_network_image.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../source/styles/decoration.dart';
import 'custom_text.dart';

class DocumentContainer extends StatelessWidget {
  final String text;
  final String imageValue;
  final String? netWrk;
  final VoidCallback callback;
  const DocumentContainer({super.key, required this.text,required this.callback,required this.imageValue, this.netWrk});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.grey.shade100,
        key: const ValueKey("documents"),
        onTap: callback,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: customDecoration.baseBackgroundDecoration(
                  radius:5,
                  borderColor: Colors.grey.shade300
              ),
              child: Center(
                child: SizedBox(
                    height: 100,
                    width: 100,
                    child: imageValue==""&&netWrk!=""?NetworkImg(image:netWrk.toString(), width: 10,isTap: false,):imageValue==""?Icon(Icons.camera_alt):kIsWeb?Image.memory(base64Decode(imageValue),width: 30,height: 30,fit: BoxFit.cover,):Image.file(File(imageValue),width: 30,height: 30,fit: BoxFit.cover,)
                ),
              ),
            ),
            CustomText(text:text,colors:Colors.black,size: 10),5.height,
          ],
        )
    );
  }
}