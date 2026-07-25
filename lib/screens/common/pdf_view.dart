import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';

class PdfViewPage extends StatelessWidget {
  final String pdfPath;

  const PdfViewPage({
    super.key,
    required this.pdfPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed:(){Navigator.pop(context);},
          icon: Icon(Icons.arrow_back_ios_sharp,color: colorsConst.primary,size: 20,),
        ),
        title: CustomText(text: "PDF Viewer",colors: colorsConst.primary,isBold: true,size: 17,),
      ),
      body: pdfPath.startsWith('http')?
      SfPdfViewer.network(pdfPath): SfPdfViewer.file(File(pdfPath))
    );
  }
}