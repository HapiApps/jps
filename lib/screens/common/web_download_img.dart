import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<void> downloadImageCommon(BuildContext context, String imageUrl) async {
  final response = await html.HttpRequest.request(
    imageUrl,
    responseType: 'arraybuffer',
  );

  final bytes = Uint8List.view((response.response as ByteBuffer));
  final blob = html.Blob([bytes], 'image/jpeg');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "image.png")
    ..click();

  html.Url.revokeObjectUrl(url);
}
