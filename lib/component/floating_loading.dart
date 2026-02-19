import 'package:flutter/material.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../source/constant/colors_constant.dart';

class FloatingLoadingBtn extends StatelessWidget {
  const FloatingLoadingBtn({super.key,required this.callback, required this.controller, this.text="Save",
});
  final RoundedLoadingButtonController controller;
  final VoidCallback callback;
  final String? text;
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width*0.3,
      child: RoundedLoadingButton(
          borderRadius: 10,
          color: colorsConst.primary,
          successColor: colorsConst.primary,
          valueColor: Colors.white,
          onPressed: callback,
          controller: controller,
          // child: const Icon(Icons.add)
          child: CustomText(text: text.toString(),colors: Colors.white,isBold: true,size: 15,)
      ),
    );
  }
}

class SlideBtn extends StatefulWidget {
  const SlideBtn({super.key,required this.callback, this.controller, required this.iconData, required this.color, required this.isLoading,
  });
  final RoundedLoadingButtonController? controller;
  final VoidCallback callback;
  final IconData iconData;
  final Color color;
  final bool isLoading;
  @override
  State<SlideBtn> createState() => _SlideBtnState();
}

class _SlideBtnState extends State<SlideBtn> {
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 45,
      width: 45,
      child:
      IconButton(
          // borderRadius: 30,
          // elevation: 0.0,
          // color:Colors.white,
          // successColor: colorsConst.primary,
          // valueColor: colorsConst.primary,
          onPressed: widget.callback,
          // controller: widget.controller!,
          icon: Icon(widget.iconData,color: widget.color)
      ));
  }
}
