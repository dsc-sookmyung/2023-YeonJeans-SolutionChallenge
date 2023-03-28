import 'package:flutter/material.dart';

class BookmarkBackgroundImage extends StatelessWidget {
  const BookmarkBackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.center,
          image: AssetImage('assets/images/home_detail_bg.png'),
          fit: BoxFit.fill
        ),
        color: Color(0xffFFFFFF)
      ),
    );
  }
}