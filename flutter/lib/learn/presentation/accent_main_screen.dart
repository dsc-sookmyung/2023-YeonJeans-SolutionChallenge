import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:saera/learn/custom_learn/learn_sentence/presentation/learn_statement_screen.dart';
import 'package:saera/learn/search_learn/presentation/search_learn_screen.dart';

import '../../style/color.dart';
import '../../style/font.dart';

class AccentMainPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    Widget backSection = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
            icon: SvgPicture.asset(
              'assets/icons/back.svg',
              fit: BoxFit.scaleDown,
              color: ColorStyles.backIconGreen,
            ),
            label: const Text(' 뒤로',
                style: TextStyles.backBtnTextStyle
            )
        ),
      ],
    );

    Widget whatLearnSection = Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05, left: 10, right: 10),
      child: const Text(
        '어떤 억양을 학습할까요?',
        style: TextStyles.xLarge25TextStyle,
      ),
    );

    Widget whatLearnTextSection = Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03, left: 10, right: 10),
      child: const Text(
        '연습하고 싶은 문장을 직접 만들어 억양을 학습하거나,\n새라가 제공하는 다양한 문장 표현을 학습할 수 있어요.',
        style: TextStyles.littleBit25TextStyleHeight,
      ),
    );

    Widget customButtonSection = InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => LearnStatementPage(),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height*0.01,
            left: 20, right: 20
        ),
        decoration: BoxDecoration(
            color: ColorStyles.saeraAccent,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            boxShadow: [
              BoxShadow(
                color: ColorStyles.saeraAccent.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 8),
              )
            ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height*0.023,
                bottom: MediaQuery.of(context).size.height*0.023,
                left: MediaQuery.of(context).size.width*0.04
              ),
              child: const Text(
                '내가 만든 문장 학습/문장 생성',
                style: TextStyles.medium00MediumTextStyle,
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05),
              child: SvgPicture.asset('assets/icons/custom_statement.svg'),
            )
          ],
        ),
      ),
    );

    Widget situationTextSection = Container(
      margin: EdgeInsets.only(
        left: 20.0,
        top: MediaQuery.of(context).size.height*0.025,
        bottom: MediaQuery.of(context).size.height*0.02
      ),
      child: const Text(
        '상황',
        style: TextStyles.medium00BoldTextStyle,
      ),
    );

    InkWell situationButton(String icon, String situation) {
      return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => SearchPage(value: situation),
          ));
        },
        child: Container(
            margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height*0.01,
                horizontal: MediaQuery.of(context).size.width*0.02
            ),
            width: MediaQuery.of(context).size.width*0.26,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.13),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 8),
                  )
                ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height*0.017,
                      left: MediaQuery.of(context).size.width*0.02
                  ),
                  child: SvgPicture.asset(icon),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height*0.02,
                      bottom: MediaQuery.of(context).size.height*0.02,
                      left: MediaQuery.of(context).size.width*0.02
                  ),
                  child: Text(
                    situation,
                    style: TextStyles.regular00BoldTextStyle,
                  ),
                )
              ],
            )
        ),
      );
    }

    Widget situationSection = Container(
      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05),
      child: Wrap(
        children: [
          situationButton('assets/icons/conservation.svg', '일상'),
          situationButton('assets/icons/order.svg', '소비'),
          situationButton('assets/icons/greeting.svg', '인사'),
          situationButton('assets/icons/public.svg', '은행/공공기관'),
          situationButton('assets/icons/company.svg', '회사'),
        ],
      ),
    );

    Widget statementTypeTextSection = Container(
      margin: EdgeInsets.only(
          left: 20.0,
          top: MediaQuery.of(context).size.height*0.035,
          bottom: MediaQuery.of(context).size.height*0.02
      ),
      child: const Text(
        '문장 유형',
        style: TextStyles.medium00BoldTextStyle,
      ),
    );

    Widget statementTypeSection = Container(
      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05),
      child: Wrap(
        children: [
          situationButton('assets/icons/question.svg', '의문문'),
          situationButton('assets/icons/honorific.svg', '존댓말'),
          situationButton('assets/icons/negative.svg', '부정문'),
          situationButton('assets/icons/feeling.svg', '감정 표현'),
        ],
      ),
    );

    return Container(
        decoration: const BoxDecoration(
            color: Colors.white
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      backSection,
                      whatLearnSection,
                      whatLearnTextSection
                    ],
                  ),
                )
            ),
            body: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02),
              child: ListView(
                children: [
                  customButtonSection,
                  situationTextSection,
                  situationSection,
                  statementTypeTextSection,
                  statementTypeSection
                ],
              ),
            ),
          ),
        )
    );
  }
}