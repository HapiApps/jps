import 'package:flutter/material.dart';
import '../source/constant/colors_constant.dart';

class CreateButton extends StatelessWidget {
  final VoidCallback callback;
  const CreateButton({super.key,required this.callback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,height: 35,
      child: FloatingActionButton(
        backgroundColor: colorsConst.primary,
          onPressed: callback,
          child: const Icon(Icons.add,color: Colors.white,size: 17,)),
    );
  }
}
