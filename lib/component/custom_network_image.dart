import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/screens/common/fullscreen_photo.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/utilities/utils.dart';
import '../source/constant/api.dart';
import '../source/constant/assets_constant.dart';
import 'custom_loading.dart';

class NetworkImg extends StatefulWidget {
  final String image;
  final double width;
  final bool? isTap;
  const NetworkImg({super.key, required this.image, required this.width, this.isTap=true});

  @override
  State<NetworkImg> createState() => _NetworkImgState();
}

class _NetworkImgState extends State<NetworkImg> {
  @override
  Widget build(BuildContext context) {
    // print("$imageFile?path=${widget.image}");
    return GestureDetector(
      onTap: widget.isTap==true?(){
        utils.navigatePage(context, ()=>FullScreen(image: widget.image, isNetwork: true));
      }:null,
      child: CachedNetworkImage(
          imageUrl: '$imageFile?path=${widget.image}',
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.width),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error,color: colorsConst.litGrey,size: 20,),
          placeholder: (context, url) => const Loading(size: 10,)),
    );
  }
}


class CircleNetWorkImg extends StatefulWidget {
  final String img;
  final double width;
  const CircleNetWorkImg({super.key, required this.img, required this.width});

  @override
  State<CircleNetWorkImg> createState() => _CircleNetWorkImgState();
}

class _CircleNetWorkImgState extends State<CircleNetWorkImg> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: '$imageFile?path=${widget.img}',
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) => Container(
          width: widget.width,
          height: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.width),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (context, url, error) => SvgPicture.asset(assets.profile),
        placeholder: (context, url) => const Loading(size: 10,));
  }
}
