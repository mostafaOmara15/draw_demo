// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class TouchPainter extends StatefulWidget {
//   @override
//   _TouchPainterState createState() => _TouchPainterState();
// }
//
// class _TouchPainterState extends State<TouchPainter> {
//   List<Offset?> points = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Touch Painter'),
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
//           child: Container(),
//         ),
//       ),
//     );
//   }
// }
//
// class ImagePainter extends CustomPainter {
//   final List<Offset?> points;
//
//   ImagePainter(this.points);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 4.0
//       ..strokeCap = StrokeCap.round;
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
//   final ByteData byteData = await rootBundle.load('assets/images/custom_image.jpg');
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