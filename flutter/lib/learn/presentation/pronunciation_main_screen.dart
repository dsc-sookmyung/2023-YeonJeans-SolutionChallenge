import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:saera/learn/pronounce_learn/pronounce_learn_screen.dart';

import '../../login/data/authentication_manager.dart';
import '../../server.dart';
import '../../style/color.dart';
import '../../style/font.dart';

class PronunciationMainPage extends StatelessWidget {
  final AuthenticationManager _authManager = Get.find();

  int returnId(String menu) {
    if (menu == '구개음화') {
      return 10;
    } else if (menu == '두음법칙') {
      return 11;
    } else if (menu == '치조마찰음화') {
      return 12;
    } else if (menu == '단모음화') {
      return 16;
    } else if (menu == "'ㄴ' 첨가") {
      return 13;
    } else { //기타
      return 0;
    }
  }

  Future<List<int>> getWordList(int id) async {
    List<int> wordList = [];
    var url = Uri.parse('$serverHttp/word-id?tag_id=$id');
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}"});
    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      wordList = List.from(body);
    }
    return wordList;
  }

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
        '어떤 발음을 학습할까요?',
        style: TextStyles.xLarge25TextStyle,
      ),
    );

    Widget whatLearnTextSection = Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03, left: 10, right: 10),
      child: const Text(
        '북한 조선어의 발음과 차이가 있는 남한 표준어의 발음을\n발음법에 따라 집중적으로 학습할 수 있어요.',
        style: TextStyles.littleBit25TextStyleHeight,
      ),
    );

    InkWell pronunciationMenu(String word, String description) {
      return InkWell(
        onTap: () {
          Future<dynamic> wordList;
          wordList = getWordList(returnId(word));
          wordList.then((wordList){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PronouncePracticePage(idx: 0, isTodayLearn: false, wordList: wordList, pcList: [],))
            );
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height*0.01,
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height*0.02,
                        left: MediaQuery.of(context).size.width*0.04
                    ),
                    child: Text(
                      word,
                      style: TextStyles.medium00BoldTextStyle,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height*0.01,
                      bottom: MediaQuery.of(context).size.height*0.02,
                      left: MediaQuery.of(context).size.width*0.04,
                    ),
                    child: Text(
                      description,
                      style: TextStyles.small66BoldTextStyle,
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.03),
                child: IconButton(
                    onPressed: null,
                    icon: SvgPicture.asset('assets/icons/word_main_next.svg')
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget pronunciationTypeSection = ListView(
      children: [
        pronunciationMenu('구개음화', "'ㄷ', 'ㅌ' 뒤에 'ㅣ'가 올 때 'ㅈ', 'ㅊ'로 발음합니다."),
        pronunciationMenu('두음법칙', "단어 말머리의 'ㄴ', 'ㄹ'이 다른 소리로 바뀝니다."),
        pronunciationMenu('치조마찰음화', "'ㅅ'와 'ㅆ'의 올바른 발음을 연습합니다."),
        pronunciationMenu('단모음화', "이중모음을 단모음처럼 발음하지 않도록 연습합니다."),
        pronunciationMenu("'ㄴ' 첨가", "복합어에서 'ㄴ'을 추가해 발음하는 현상입니다."),
        pronunciationMenu('기타', "그 외에 발음에 신경써야 하는 단어들을 연습합니다.")
      ],
    );

    return Container(
        decoration: BoxDecoration(
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
                child: pronunciationTypeSection
            ),
          ),
        )
    );
  }
}