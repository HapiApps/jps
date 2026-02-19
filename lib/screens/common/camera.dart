
import 'dart:developer';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';


List<CameraDescription> cameras = <CameraDescription>[];
enum CameraType { front, back}
class CameraWidget extends StatefulWidget {
  final CameraType cameraPosition;
  final bool? isSelfie;
  const CameraWidget({super.key,required this.cameraPosition,this.isSelfie=false});


  @override
  CameraWidgetState createState() => CameraWidgetState();
}


class CameraWidgetState extends State<CameraWidget> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();


    _initCamera();
    selectedCameraIndex = widget.cameraPosition==CameraType.front?1:0;
    _controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }


  Future<void> _initCamera() async {
    if (!mounted) return;

    final status = await Permission.camera.status;
    print("Current camera status: $status");

    if (status.isGranted) {
      _startCamera();
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _startCamera();
      } else if (result.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      } else if (result.isPermanentlyDenied) {
        await openAppSettings();
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  void _startCamera() async {
    cameras = await availableCameras();
    selectedCameraIndex = widget.cameraPosition == CameraType.front ? 1 : 0;

    _controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }
  int selectedCameraIndex = 0;
  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }
  Future<void> toggleCamera() async {
    // Get available cameras
    cameras = await availableCameras();
    // Switch to the next camera
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
    final newCamera = cameras[selectedCameraIndex];
    // Dispose the current controller
    await _controller.dispose();
    // Create a new controller with the new camera
    _controller = CameraController(
      newCamera,
      ResolutionPreset.medium,
    );
    // Initialize the new controller
    _initializeControllerFuture = _controller.initialize();
    // Update UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.8,
        toolbarHeight: 70,
        title:CustomText(text: "Camera",colors: colorsConst.primary,size: 18,isBold: true,),
        centerTitle: true,
        leading: IconButton(
          onPressed:(){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_sharp,color: colorsConst.primary,size: 15,),
        ),
      ),
      body: Container(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: colorsConst.primary,
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                if (!context.mounted) return;
                Navigator.pop(context, image.path);
              } catch (e) {
                log("Camera error $e");
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
          10.width,
          widget.isSelfie==false?FloatingActionButton(
            backgroundColor: colorsConst.primary,
            onPressed: () async {
              toggleCamera();
            },
            child: const Icon(Icons.repeat_sharp),
          ):0.width,
        ],
      ),
    );
  }
}



