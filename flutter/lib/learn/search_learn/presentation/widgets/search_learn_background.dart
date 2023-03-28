import 'package:flutter/material.dart';

class SearchLearnBackgroundImage extends StatelessWidget {
  const SearchLearnBackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.center,
          image: AssetImage('assets/images/learn_detail_bg.png'),
            fit: BoxFit.fill// 배경 이미지
        ),
        color: Color(0xffFFFFFF),
      ),
    );
  }
}