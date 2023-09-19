import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class TouchPainter extends StatefulWidget {
  @override
  _TouchPainterState createState() => _TouchPainterState();
}

class _TouchPainterState extends State<TouchPainter> {
  List<Offset?> points = [];
  GlobalKey globalKey = GlobalKey();
  bool isSaving = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Touch Painter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isSaving ? null : saveImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    key: globalKey,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          RenderBox renderBox = globalKey.currentContext!
                              .findRenderObject() as RenderBox;
                          points.add(
                              renderBox.globalToLocal(details.globalPosition));
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          points = [...points, null];
                        });
                      },
                      child: FutureBuilder<ui.Image>(
                        future: loadImage(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done || snapshot.connectionState == ConnectionState.waiting) {
                            if(snapshot.data!= null){
                              return CustomPaint(
                                painter: ImagePainter(snapshot.data, points),
                              );
                            }else{
                              return const Center(child: CircularProgressIndicator());
                            }
                          } else {
                            return const Center(child: SizedBox());
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(onPressed: (){
            isSaving ? null : saveImage();
          }, child: const Text("Save"))
        ],
      ),
    );
  }

  Future<void> saveImage() async {
    setState(() {
      isSaving = true;
    });

    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/drawn_image.png';
    await File(imagePath).writeAsBytes(pngBytes);
    await ImageGallerySaver.saveFile(imagePath);

    setState(() {
      isSaving = false;
    });
  }

  Future<ui.Image> loadImage() async {
    final ByteData byteData = await rootBundle
        .load('assets/highland-view-bed-and.jpg');
    final Uint8List bytes = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image? image;
  final List<Offset?> points;
  ImagePainter(this.image, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image!, Offset.zero, Paint());
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TouchPainter(),
    );
  }
}