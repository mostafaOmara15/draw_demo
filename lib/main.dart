// import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
//
// class ImagePainter extends CustomPainter {
//   final ui.Image image;
//   final List<Offset> points;
//
//   ImagePainter(this.image, this.points);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 5
//       ..style = PaintingStyle.stroke;
//
//     canvas.drawImage(image, Offset.zero, Paint());
//
//     for (int i = 0; i < points.length - 1; i++) {
//       if (points[i] != null && points[i + 1] != null) {
//         canvas.drawLine(points[i], points[i + 1], paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
//
// class DrawingScreen extends StatefulWidget {
//   @override
//   _DrawingScreenState createState() => _DrawingScreenState();
// }
//
// class _DrawingScreenState extends State<DrawingScreen> {
//   List<Offset> points = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Drawing on Image'),
//       ),
//       body: GestureDetector(
//         onPanUpdate: (details) {
//           setState(() {
//             points = [...points, details.localPosition];
//           });
//         },
//         onPanEnd: (details) {
//           setState(() {
//             points = [...points];
//           });
//         },
//         child: CustomPaint(
//           painter: ImagePainter(image, points),
//           child: Container(),
//         ),
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   ui.Image? image;
//
//   Future<void> loadImage() async {
//     final ByteData byteData =
//     await rootBundle.load('assets/highland-view-bed-and.jpg');
//     final Uint8List bytes = byteData.buffer.asUint8List();
//     image = await decodeImageFromList(bytes);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: FutureBuilder<void>(
//         future: loadImage(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return DrawingScreen();
//           } else {
//             return const Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class TouchPainter extends StatefulWidget {
  @override
  _TouchPainterState createState() => _TouchPainterState();
}

class _TouchPainterState extends State<TouchPainter> {
  List<Offset?> points = [];
  GlobalKey _globalKey = GlobalKey();
  bool isSaving = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Touch Painter'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: isSaving ? null : saveImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              key: _globalKey,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox renderBox =
                    _globalKey.currentContext!.findRenderObject() as RenderBox;
                    points.add(renderBox.globalToLocal(details.globalPosition));
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
                    if (snapshot.connectionState == ConnectionState.done||snapshot.connectionState == ConnectionState.waiting) {
                      return CustomPaint(
                        painter: ImagePainter(snapshot.data!, points),
                      );
                    } else {
                      return Center(child: SizedBox());
                    }
                  },
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Future<void> saveImage() async {
    setState(() {
      isSaving = true;
    });

    RenderRepaintBoundary boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
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

    _scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(content: Text('Image saved to gallery')),
    );
  }

  Future<ui.Image> loadImage() async {
    final ByteData byteData =
    await rootBundle.load('assets/WhatsApp Image 2023-09-18 at 5.00.22 PM (1).jpeg');
    final Uint8List bytes = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final List<Offset?> points;

  ImagePainter(this.image, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());

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