import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final double fontSize;
  final bool isBold;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLines = 2,
    this.fontSize = 14,
    this.isBold = true,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  // Cached measurement: TextPainter layout is heavy, so it is re-run ONLY
  // when text / width / font / lines actually change (not on every rebuild).
  String? _cText;
  double? _cWidth;
  double? _cFont;
  bool? _cBold;
  int? _cLines;
  bool _cOverflow = false;

  bool _checkOverflow(double maxWidth, TextStyle style) {
    if (_cText == widget.text &&
        _cWidth == maxWidth &&
        _cFont == widget.fontSize &&
        _cBold == widget.isBold &&
        _cLines == widget.trimLines) {
      return _cOverflow;
    }

    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: widget.trimLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    final overflow = tp.didExceedMaxLines;
    tp.dispose();

    _cText = widget.text;
    _cWidth = maxWidth;
    _cFont = widget.fontSize;
    _cBold = widget.isBold;
    _cLines = widget.trimLines;
    _cOverflow = overflow;

    return overflow;
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: widget.fontSize,
      fontWeight: widget.isBold ? FontWeight.bold : FontWeight.normal,
      color: Colors.black,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isOverflow = _checkOverflow(constraints.maxWidth, style);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: expanded ? null : widget.trimLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: style,
            ),
            if (isOverflow)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        expanded = !expanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        expanded ? "View Less" : "View More",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  10.width,
                ],
              ),
          ],
        );
      },
    );
  }
}