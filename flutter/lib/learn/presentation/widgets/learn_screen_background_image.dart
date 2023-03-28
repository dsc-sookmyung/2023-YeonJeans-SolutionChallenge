import 'package:flutter/material.dart';

class LearnBackgroundImage extends StatelessWidget {
  const LearnBackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/learn_bg.png'),
          fit: BoxFit.fill
        ),
        color: Color(0xffFFFFFF)
      ),
    );
  }
}