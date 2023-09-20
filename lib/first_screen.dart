import 'dart:io';
import 'package:drow_demo/touch_painter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late File imageCameraFile;
  final ImagePicker cameraPicker = ImagePicker();
  String pickedImagePath = '';

  Future<void> _openCamera() async {
    final image = await cameraPicker.pickImage(source: ImageSource.camera).then((value){
      if (value != null) {
        imageCameraFile = File(value.path);
        pickedImagePath = value.path;
        print(pickedImagePath);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
      body: const Center(
        child: Text('Press on camera to pick an image'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          _openCamera().then((value){
            if(pickedImagePath != ''){
              Navigator.push(context, MaterialPageRoute(builder: (context) => TouchPainter(path: pickedImagePath)));
            }
          });
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}