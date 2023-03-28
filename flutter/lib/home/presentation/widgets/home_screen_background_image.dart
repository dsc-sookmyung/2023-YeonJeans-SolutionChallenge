import 'package:flutter/material.dart';

class HomeBackgroundImage extends StatelessWidget {
  const HomeBackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.center,
          image: AssetImage('assets/images/home_bg.png'),
          fit: BoxFit.fill
        ),
        color: Color(0xffFFFFFF)
      ),
    );
  }
}