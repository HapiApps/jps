import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import '../source/constant/colors_constant.dart';

class Loading extends StatelessWidget {
  final double size;
  const Loading({super.key, this.size=25});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.threeArchedCircle(
        color: colorsConst.primary,
        size: size,
      ),
    );
  }
}

class SkeletonLoading extends StatelessWidget {
  const SkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      builder: SizedBox(
        height: 40,
        child: ListView.builder(
          itemCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(height: 3, color: colorsConst.primary);
          },
        ),
      ),
      items: 4,
      period: const Duration(seconds: 2),
      highlightColor: colorsConst.primary.withOpacity(0.2),
      direction: SkeletonDirection.ltr,
    );
  }
}