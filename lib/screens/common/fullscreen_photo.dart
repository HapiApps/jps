
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../component/custom_text.dart';
import '../../source/constant/api.dart';
import '../../source/constant/colors_constant.dart';
class FullScreen extends StatefulWidget {
  final String image;
  final bool isNetwork;
  const FullScreen({super.key, required this.image, required this.isNetwork});

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {

  @override
  Widget build(BuildContext context) {
    // print('$imageFile?path=${widget.image}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
        leading: IconButton(
          onPressed:(){Navigator.pop(context);},
          icon: Icon(Icons.arrow_back_ios_sharp,color: colorsConst.primary,size: 15,),
        ),
      title: CustomText(text: constValue.appName,colors: colorsConst.primary,isBold: true,size: 17,),
    ),
    body:widget.isNetwork==true
        ?InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
                imageUrl: '$imageFile?path=${widget.image}',
                fit:BoxFit.cover ,
                imageBuilder: (context, imageProvider) =>
                   Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(5),
                       image: DecorationImage(
                         image: imageProvider,
                         filterQuality: FilterQuality.high,
                         // fit: BoxFit.fill,
                         // colorFilter:
                         // ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                       ),
                     ),
                   ),
               errorWidget: (context,url,error)=>const Icon(Icons.error),
               placeholder: (context,url)=>const Loading()
             //Image.network(snapshot.data!.img1.toString(),fit: BoxFit.cover)
            ),
          ),
        )
        :InteractiveViewer(
            child: Container(
        decoration:  BoxDecoration(
            image:  DecorationImage(
              image:kIsWeb?MemoryImage(base64Decode(widget.image)):FileImage(File(widget.image))),
        ),
      ),
          ),
    );
  }
}
