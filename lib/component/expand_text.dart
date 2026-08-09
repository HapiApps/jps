import 'package:flutter/cupertino.dart';
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: widget.text,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        );

        final tp = TextPainter(
          text: span,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        );

        tp.layout(maxWidth: constraints.maxWidth);

        final isOverflow = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: expanded ? null : widget.trimLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
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