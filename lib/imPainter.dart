// import 'dart:async';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
//
// class TouchPainter extends StatefulWidget {
//   @override
//   _TouchPainterState createState() => _TouchPainterState();
// }
//
// class _TouchPainterState extends State<TouchPainter> {
//   List<Offset?> points = [];
//   bool isSaving = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Touch Painter'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: isSaving ? null : saveImage,
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         onPanUpdate: (details) {
//           setState(() {
//             points = [...points, details.localPosition];
//           });
//         },
//         onPanEnd: (details) {
//           setState(() {
//             points = [...points, null];
//           });
//         },
//         child: CustomPaint(
//           painter: ImagePainter(points),
//           child: Container(
//             decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/highland-view-bed-and.jpg"),
//             )
//           ),),
//         ),
//       ),
//     );
//   }
//
//   Future<void> saveImage() async {
//     setState(() {
//       isSaving = true;
//     });
//
//     // Convert the drawn image to a byte array
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);
//     final imagePainter = ImagePainter(points);
//     imagePainter.paint(canvas, ui.Size.infinite);
//     final picture = recorder.endRecording();
//     final image = await picture.toImage(
//       imagePainter.size.width.toInt(),
//       imagePainter.size.height.toInt(),
//     );
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     final pngBytes = byteData!.buffer.asUint8List();
//
//     // Save the image to the device's gallery
//     final directory = await getTemporaryDirectory();
//     print(directory);
//     final imagePath = '${directory.path}/drawn_image.png';
//     await File(imagePath).writeAsBytes(pngBytes);
//     await ImageGallerySaver.saveFile(imagePath);
//
//     setState(() {
//       isSaving = false;
//     });
//   }
// }
//
// class ImagePainter extends CustomPainter {
//   final List<Offset?> points;
//   final Size size;
//
//   ImagePainter(this.points) : size = Size(300,300); // Set the size of the image
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 1
//       ..strokeCap = StrokeCap.round;
//
//     // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
//     //     Paint()..color = Colors.white); // Fill the image with white color
//
//     for (int i = 0; i < points.length - 1; i++) {
//       if (points[i] != null && points[i + 1] != null) {
//         canvas.drawLine(points[i]!, points[i + 1]!, paint);
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
// Future<ui.Image> loadImage() async {
//   final ByteData byteData = await rootBundle.load('assets/highland-view-bed-and.jpg');
//   final Uint8List bytes = byteData.buffer.asUint8List();
//   final codec = await ui.instantiateImageCodec(bytes);
//   final frame = await codec.getNextFrame();
//   return frame.image;
// }
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: FutureBuilder<ui.Image>(
//         future: loadImage(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return TouchPainter();
//           } else {
//             return Scaffold(
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