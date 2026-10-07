import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import '../../source/utilities/utils.dart';
import 'package:flutter/material.dart';


import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../source/constant/api.dart';

Future<void> downloadImageCommon(BuildContext context, String image) async {
  try {
    final http.Response response = await http.get(Uri.parse('$imageFile?path=$image'));
    final dir = await getTemporaryDirectory();
    final filename = '${dir.path}/image.png';
    final file = File(filename);
    await file.writeAsBytes(response.bodyBytes);

    final params = SaveFileDialogParams(sourceFilePath: file.path);
    final finalPath = await FlutterFileDialog.saveFile(params: params);

    if (finalPath != null) {
      utils.showSuccessToast(context: context, text: 'Image saved to disk');
    }
    } catch (e) {
        utils.showWarningToast(context, text: 'An error occurred while saving the image');
    }
}
