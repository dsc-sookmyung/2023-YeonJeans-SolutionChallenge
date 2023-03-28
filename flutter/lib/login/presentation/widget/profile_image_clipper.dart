import 'package:flutter/cupertino.dart';

class ProfileImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * 0.51, 0);
    path.cubicTo(size.width * 0.71, 0, size.width * 0.91, size.height * 0.12, size.width * 0.97, size.height * 0.32);
    path.cubicTo(size.width * 1.04, size.height * 0.53, size.width * 0.97, size.height * 0.77, size.width * 0.8, size.height * 0.9);
    path.cubicTo(size.width * 0.63, size.height * 1.03, size.width * 0.39, size.height * 1.03, size.width / 5, size.height * 0.9);
    path.cubicTo(size.width * 0.04, size.height * 0.77, -0.05, size.height * 0.53, size.width * 0.03, size.height * 0.32);
    path.cubicTo(size.width * 0.09, size.height * 0.11, size.width * 0.3, 0, size.width * 0.51, 0);
    path.cubicTo(size.width * 0.51, 0, size.width * 0.51, 0, size.width * 0.51, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(ProfileImageClipper oldClipper) => false;
}