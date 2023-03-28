import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:saera/learn/accent_learn/presentation/accent_learn_screen.dart';
import 'package:saera/learn/pronounce_learn/pronounce_learn_screen.dart';
import 'package:saera/tabbar.dart';

import 'package:http/http.dart' as http;
import 'package:saera/learn/pronounce_learn/today_learn_word_list.dart';
import 'dart:convert';

import '../../learn/accent_learn/presentation/accent_todaylearn_screen.dart';
import '../../login/data/authentication_manager.dart';
import '../../login/data/refresh_token.dart';
import '../../server.dart';
import '../../style/font.dart';
import '../../style/color.dart';
import '../../learn/accent_learn/presentation/today_learn_statement_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthenticationManager _authManager = Get.find();

  List<int> wordList = [];
  List<int> statementList = [];
  List<top5Statement> top5StatementList = [];

  int todayWordLearnIdx = 0;
  int todayStatementLearnIdx = 0;

  int todayWordProgressIdx = 0;
  int todayStatementProgressIdx = 0;

  @override
  void initState() {
    if(_authManager.getTodayStatementIdx() == null){
      _authManager.saveTodayStatementIdx(0);
    }
    if(_authManager.getTodayWordIdx() == null){
      _authManager.saveTodayWordIdx(0);
    }

    todayWordProgressIdx = _authManager.getTodayWordIdx()!;
    todayStatementProgressIdx = _authManager.getTodayStatementIdx()!;

    getTop5SentenceList();
    getTodayWordList();
    getTodaySentenceList();
    super.initState();
  }

  getTodayWordList() async {
    await Future.delayed(const Duration(seconds: 1));
    var url = Uri.parse('$serverHttp/today-list?type=WORD');
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });

    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));

      wordList.clear();
      wordList = List.from(body);
      if(wordList[0] != todayWordLearnIdx){
        _authManager.saveTodayWordIdx(0);
      }
    }
    else if(response.statusCode == 401){
      String? before = _authManager.getToken();
      await RefreshToken(context);

      if(before != _authManager.getToken()){
        getTodayWordList();
      }
    }
  }

  getTodaySentenceList() async {
    await Future.delayed(const Duration(seconds: 1));
    var url = Uri.parse('$serverHttp/today-list?type=STATEMENT');
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });

    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      statementList.clear();
      statementList = List.from(body);
      if(statementList[0] != todayStatementLearnIdx){
        _authManager.saveTodayStatementIdx(0);
      }
    }
  }

  Future<List<top5Statement>> getTop5SentenceList() async {
    var url = Uri.parse('$serverHttp/top5-statement');
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });

    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      top5StatementList.clear();
      for (dynamic i in body) {
        int id = i["id"];
        String name = i["name"];
        top5StatementList.add(top5Statement(id: id, content: name));
      }
      return top5StatementList;
    } else {
      top5StatementList.add(top5Statement(id: 0, content: "네트워크 오류로 정보가 없습니다."));
      return top5StatementList;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    Widget imageSection = Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height*0.147,
        left: MediaQuery.of(context).size.width*0.05
      ),
      child: SvgPicture.asset('assets/images/home_image.svg'),
    );

    Widget greetingTextSection = Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height*0.07,
          left: MediaQuery.of(context).size.width*0.07
      ),
      child: Text(
        '${_authManager.getName()} 님,\n어서 오세요!',
        style: TextStyles.xLarge25TextStyle,
        textAlign: TextAlign.left,
      ),
    );

    Widget learnDateTextSection = Container(
      width: 116,
      height: 54,
      decoration: const BoxDecoration(
        image: DecorationImage(
           image: AssetImage('assets/images/home_speech_bubble.png'),
           alignment: Alignment.center
        ),
      ),
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height*0.12,
        left: MediaQuery.of(context).size.width*0.63
      ),
      child: Container(
        margin: EdgeInsets.only(top: 6),
        child: const Text.rich(
          TextSpan(
              children: [
                TextSpan(
                  text: '8일 연속',
                  style: TextStyles.small55BoldTextStyle,
                ),
                TextSpan(
                    text: '으로\n학습 중이에요',
                    style: TextStyles.small55TextStyle
                )
              ]
          ),
          textAlign: TextAlign.center,
        ),
      )
    );

    Widget searchSection = Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.04),
      //padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Row(
        children: <Widget>[
          Flexible(
              child: TextField(
                readOnly: true,
                onTap: () {
                  TabBarMainPage.myTabbedPageKey.currentState?.tabController.animateTo(1);
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: SvgPicture.asset('assets/icons/search.svg', fit: BoxFit.scaleDown),
                  ),
                  hintText: '무엇을 학습할까요?',
                  hintStyle: TextStyles.mediumAATextStyle,
                  enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(99.0)),
                      borderSide: BorderSide(color: ColorStyles.searchFillGray)
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(99.0)),
                    borderSide: BorderSide(color: ColorStyles.searchFillGray),
                  ),
                  filled: true,
                  fillColor: ColorStyles.searchFillGray,
                ),
              )
          )
        ],
      ),
    );

    Widget mostLearnTextSection = Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02),
      child: const Text(
        '가장 많이 학습한 문장 Top 5',
        style: TextStyles.medium25BoldTextStyle,
      ),
    );

    InkWell statementSection(int id, String statement) {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccentPracticePage(id: id, isCustom: false,))
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                )
              ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statement,
                style: TextStyles.regular25TextStyle,
              ),
              SvgPicture.asset('assets/icons/expand_right.svg'),
            ],
          ),
        ),
      );
    }

    Widget top5StatementSection = FutureBuilder(
        future: getTop5SentenceList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                  margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.03),
                  child: LoadingAnimationWidget.waveDots(
                      color: ColorStyles.expFillGray,
                      size: 45.0
                  )
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError) {
              return Center(
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                  margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.03),
                  child: Text(snapshot.error.toString())
                )
              );
            } else {
              return Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.01),
                child: CarouselSlider.builder(
                  itemCount: snapshot.data?.length,
                  options: CarouselOptions(
                      height: MediaQuery.of(context).size.height*0.09,
                      initialPage: 0,
                      aspectRatio: 6.0,
                      enlargeCenterPage: true,
                      autoPlay: true
                  ),
                  itemBuilder: (BuildContext context, int index, int realIndex) {
                    return statementSection(snapshot.data![index].id, snapshot.data![index].content);
                  },
                ),
              );
            }
          } else {
            return Container();
          }
        }
    );

    Widget todayRecommandSection = Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
      child: const Text(
        '오늘의 추천 학습',
        style: TextStyles.medium25BoldTextStyle,
      ),
    );

    Widget todayRecommandTextSection = Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.015),
      child: const Text(
        '매일 새롭게 추천하는 5개의 단어와 문장으로\n빠르게 발음과 억양을 학습해요.',
        style: TextStyles.small55TextStyle,
      ),
    );

    Widget todayLearnSection = Container(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: (){
              todayWordProgressIdx = _authManager.getTodayWordIdx()!;
              if(todayWordProgressIdx == 5){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TodayLearnWordListPage(wordList: wordList, isTodayWord: true, tagList: [],),
                ));
              }
              else{
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PronouncePracticePage(idx: todayWordProgressIdx, isTodayLearn: true, wordList: wordList, pcList: [],)
                ));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 8),
                    )
                  ]
              ),
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width*0.05,
                  right: MediaQuery.of(context).size.width*0.2
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.025)),
                  SvgPicture.asset('assets/icons/today_word.svg'),
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.015)),
                  const Text(
                    '오늘의\n단어 학습',
                    style: TextStyles.medium25TextStyle,
                  ),
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.010)),
                  const Text(
                    '약 3분 소요',
                    style: TextStyles.tiny82TextStyle,
                  ),
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.025)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: (){
              todayStatementProgressIdx = _authManager.getTodayStatementIdx()!;
              if(todayStatementProgressIdx == 5){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TodayLearnStatementListPage(sentenceList: statementList,),
                ));
              }else{
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AccentTodayPracticePage(idx: todayStatementProgressIdx, sentenceList: statementList)
                ));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 8),
                    )
                  ]
              ),
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width*0.05,
                  right: MediaQuery.of(context).size.width*0.2
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.025)),
                  SvgPicture.asset('assets/icons/today_statement.svg'),
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.015)),
                  const Text(
                    '오늘의\n문장 학습',
                    style: TextStyles.medium25TextStyle,
                  ),
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.010)),
                  const Text(
                    '약 5분 소요',
                    style: TextStyles.tiny82TextStyle,
                  ),
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.025)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget container = Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.25),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32.0), topRight: Radius.circular(32.0)),
      ),
      child: Container(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            searchSection,
            mostLearnTextSection,
            top5StatementSection,
            todayRecommandSection,
            todayRecommandTextSection,
            todayLearnSection,
          ],
        ),
      )
    );

    return Stack(
      children: [
        Container(
          color: Color(0xff8DDDB6),
        ),
        SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  greetingTextSection,
                  learnDateTextSection,
                  container,
                  imageSection,
                ],
              ),
            )
        )
      ],
    );
  }
}

class top5Statement {
  final int id;
  final String content;
  top5Statement({required this.id, required this.content});
}