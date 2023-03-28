import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saera/learn/custom_learn/create_sentence/presentation/custom_statement_loading_screen.dart';
import 'package:saera/style/color.dart';
import 'package:saera/style/font.dart';

import '../../../accent_learn/presentation/accent_learn_screen.dart';

class CustomDonePage extends StatelessWidget {

  final int id;

  const CustomDonePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);


    Future<void> initializeSettings() async {
      await Future.delayed(Duration(seconds: 3));
    }

    Widget checkIconSection = Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.3),
      child: SvgPicture.asset('assets/icons/check_round_fill.svg', fit: BoxFit.scaleDown,),
    );

    Widget doneSection = Container(
      padding: EdgeInsets.only(top: 36.0),
      child: const Text(
        "문장이 생성되었어요!\n'학습 - 사용자 정의 문장 학습/생성'에서\n방금 만든 문장을 학습할 수 있어요.",
        style: TextStyles.large25TextStyle,
        textAlign: TextAlign.center,
      ),
    );

    Widget goLearnPageSection = Container(
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
      height: 56,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 6,
              blurRadius: 7,
              offset: Offset(0, 3),
            )
          ]
      ),
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          side: const BorderSide(
            width: 1.0,
            color: Colors.transparent,
          ),
          backgroundColor: Colors.white
        ),
        child: const Center(
          child: Text(
            '학습 화면으로',
            style: TextStyles.mediumBlueBoldTextStyle,
            textAlign: TextAlign.center,
          ),
        )
      ),
    );

    Widget goAccentPageSection = Container(
      margin: const EdgeInsets.only(left: 14, right: 14),
      height: 56,
      child: OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => AccentPracticePage(id: id, isCustom: true,)));
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: ColorStyles.saeraAppBar,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
            ),
            side: const BorderSide(
              width: 1.0,
              color: ColorStyles.saeraAppBar,
            ),
          ),
          child: const Center(
            child: Text(
              '바로 학습',
              style: TextStyles.mediumWhiteBoldTextStyle,
              textAlign: TextAlign.center,
            ),
          )
      ),
    );

    Widget bottomButtonSection = SizedBox(
      height: 142,
      child: Column(
        children: [
          goLearnPageSection,
          goAccentPageSection
        ],
      ),
    );

    return FutureBuilder(
        future: initializeSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoadingPage();
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Container(
                  child: Text('에러'),
                ),
              );
            } else {
              return Stack(
                children: [
                  Container(
                    color: Colors.white,
                  ),
                  SafeArea(
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        resizeToAvoidBottomInset: false,
                        body: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            checkIconSection,
                            doneSection,
                          ],
                        ),
                        bottomSheet: bottomButtonSection,
                      )
                  )
                ],
              );
            }
          }
        }
    );
  }
}