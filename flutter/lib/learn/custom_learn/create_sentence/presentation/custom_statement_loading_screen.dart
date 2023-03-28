import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saera/style/font.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoadingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    Widget loadingSpinnerSection = Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.32),
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.4),
        child: LoadingAnimationWidget.staggeredDotsWave(
            color: Color(0xff2D2D2D),
            size: 45.0
        )
    );

    Widget waitingSection = Container(
      padding: EdgeInsets.only(top: 17.0),
      child: const Text(
        '요청하신 문장에 대한\n표준어 음성을 생성하고 있어요.\n조금만 기다려 주세요!',
        style: TextStyles.large25TextStyle,
        textAlign: TextAlign.center,
      ),
    );

    Widget warningSection = Container(
      padding: EdgeInsets.only(top: 36.0),
      child: const Text(
        '이 작업은 최대 30초가 소요됩니다.\n이 화면을 벗어나면 문장이 생성되지 않으니 주의해 주세요!',
        style: TextStyles.small82TextStyle,
        textAlign: TextAlign.center,
      ),
    );

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
                children: [
                  loadingSpinnerSection,
                  waitingSection,
                  warningSection
                ],
              ),
            )
        )
      ],
    );
  }
}