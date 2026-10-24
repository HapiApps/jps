
import 'package:flutter/material.dart';
import '../source/constant/colors_constant.dart';

class CreateButton extends StatelessWidget {
  final VoidCallback? callback;

  final IconData? icon;
  final String? text;

  final Color? backgroundColor;
  final Color? foregroundColor;

  final double? width;
  final double height;
  final double iconSize;
  final double fontSize;
  final double borderRadius;
  final double elevation;
  final double spacing;

  const CreateButton({
    super.key,
    required this.callback,
    this.icon,
    this.text,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.width = 35,
    this.height = 35,
    this.iconSize = 17,
    this.fontSize = 14,
    this.borderRadius = 50,
    this.elevation = 0,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: backgroundColor ?? colorsConst.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: elevation,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: callback,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: foregroundColor,
                    size: iconSize,
                  ),
                if (icon != null &&
                    text != null &&
                    text!.isNotEmpty)
                  SizedBox(width: spacing),
                if (text != null && text!.isNotEmpty)
                  Flexible(
                    child: Text(
                      text!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
