import 'package:flutter/material.dart';

class AccentPracticeBackgroundImage extends StatelessWidget {
  const AccentPracticeBackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.topLeft,
          image: AssetImage('assets/images/top_bird.png'), // 배경 이미지
        ),
        color: Color(0xffFFFFFF),
      ),
    );
  }
}