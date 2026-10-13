import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/constant/colors_constant.dart';

final CustomStyle customStyle = CustomStyle._();

class CustomStyle{
  CustomStyle._();
  InputDecoration inputDecoration({required Color fieldClr,String? text,bool? isIcon,bool? isLogin,bool? isSearch,IconData? iconData,VoidCallback? voidCallback,VoidCallback? searchCall,double? radius=10,Color? iconColor=Colors.grey}) {
    return InputDecoration(
      hintText:text,
      hintStyle: const TextStyle(
          // color: Colors.grey,
          fontSize: 14
      ),
      fillColor: fieldClr,
      filled: true,
      prefixIcon: isIcon==true?Icon(iconData,color: Colors.grey,):null,
      suffixIcon: isLogin==true?GestureDetector(
          onTap: voidCallback,
          child: Icon(iconData,color: iconColor,size: 18,)):
      isSearch==true?GestureDetector(
          onTap: searchCall,
          child: Container(
              width: 10,height: 10,color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(assets.cancel2),
              ))):null,
      errorStyle: const TextStyle(
        fontSize: 12.0,
        height: 0.20,
      ),
      enabledBorder: OutlineInputBorder(
          // grey.shade300
          borderSide:  BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(radius!)
      ),
      focusedBorder: OutlineInputBorder(
          borderSide:  BorderSide(color: colorsConst.primary),
          borderRadius: BorderRadius.circular(radius)
      ),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorsConst.primary),
          borderRadius: BorderRadius.circular(radius)
      ),
      // errorStyle: const TextStyle(height:0.05,fontSize: 12),
      contentPadding:const EdgeInsets.fromLTRB(10, 10, 10, 10),
      errorBorder: OutlineInputBorder(
          borderSide:  const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(radius)
      ),
    );
  }

  ButtonStyle buttonStyle({Color? color,required double radius}){
   return ElevatedButton.styleFrom(
     backgroundColor: color,
     elevation: 0.0,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(radius),
       side: BorderSide(color: color==Colors.white?colorsConst.primary:Colors.transparent, width: 1), // Set border color
     )
   );
  }
}
