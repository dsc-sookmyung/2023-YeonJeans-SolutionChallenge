import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:saera/home/presentation/home_screen.dart';
import 'package:saera/server.dart';
import 'package:saera/style/color.dart';
import 'package:saera/style/font.dart';

import 'pronounce_learn_screen.dart';
import '../../login/data/authentication_manager.dart';

class TodayLearnWordListPage extends StatefulWidget {

  final List<int> wordList;
  final List<int> tagList;
  final bool isTodayWord;

  const TodayLearnWordListPage({Key? key, required this.wordList, required this.isTodayWord, required this.tagList});

  @override
  State<StatefulWidget> createState() => _TodayLearnWordListPageState();
}

class _TodayLearnWordListPageState extends State<TodayLearnWordListPage> {
  final AuthenticationManager _authManager = Get.find();

  Future<dynamic>? word;

  Color selectTagColor(String tag) {
    if (tag == '구개음화') {
      return ColorStyles.saeraBlue.withOpacity(0.5);
    } else if (tag == "ㄴ첨가") {
      return ColorStyles.saeraKhaki.withOpacity(0.5);
    } else if (tag == '두음법칙') {
      return ColorStyles.saeraPink3.withOpacity(0.5);
    } else if (tag == '치조마찰음화') {
      return ColorStyles.saeraYellow.withOpacity(0.5);
    } else if (tag == '단모음화') {
      return ColorStyles.saeraOlive1.withOpacity(0.5);
    } else {
      return ColorStyles.saeraBeige.withOpacity(0.5);
    }
  }

  Future<List<Word>> getWord() async {
    List<Word> wordList = [];
    String word_id = "";
    for(int i = 0; i<widget.wordList.length; i++) {
      word_id += 'idList=${widget.wordList[i]}&';
    }
    var url = Uri.parse('$serverHttp/complete?type=WORD&$word_id&isTodayStudy=${widget.isTodayWord}');
    print("url : $url");
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}"});
    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      for (dynamic i in body) {
        int id = i["id"];
        String notation = i["notation"];
        String pronunciation = i["pronunciation"];
        String tag = i["tag"];
        bool bookmarked = i["bookmarked"];
        wordList.add(Word(id: id, notation: notation, pronunciation: pronunciation, tag: tag, bookmarked: bookmarked));
      }
    }
    return wordList;
  }

  createBookmark (int id) async {
    var url = Uri.parse('${serverHttp}/bookmark?type=STATEMENT&fk=$id');
    final response = await http.post(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    print("create : $response");
  }

  deleteBookmark (int id) async {
    var url = Uri.parse('${serverHttp}/bookmark?type=STATEMENT&fk=$id');
    final response = await http.delete(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    print("delete : $response");
  }

  @override
  void initState() {
    word = getWord();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

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

    Widget todayLearnWordTextSection = Container(
      margin: const EdgeInsets.only(left: 10.0),
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
      child: widget.isTodayWord == true
          ? Text('오늘 학습한 단어 목록', style: TextStyles.xxLargeTextStyle,)
          : Text('학습한 단어 목록', style: TextStyles.xxLargeTextStyle,),
    );
    
    Widget wordListSection = FutureBuilder(
        future: word,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02),
                  child: LoadingAnimationWidget.waveDots(
                      color: ColorStyles.expFillGray,
                      size: 45.0
                  )
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                  child: Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02),
                    child: const Text("서버 연결이 불안정합니다.", style: TextStyles.regular25TextStyle,),
                  )
              );
            } else {
              List<Word> words = snapshot.data;
              return Container(
                height: MediaQuery.of(context).size.height*0.53,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ListView.separated(
                    itemBuilder: ((context, index) {
                      Word word = words[index];
                      return Row(
                        children: [
                          Text(
                            word.notation,
                            style: TextStyles.regular00TextStyle,
                          ),
                          Text(
                            '[${word.pronunciation}]',
                            style: TextStyles.regularGreenTextStyle,
                          ),
                          Spacer(flex: 2,),
                          Chip(
                            label: Text(
                              word.tag,
                              style: TextStyles.small00TextStyle,
                            ),
                            backgroundColor: selectTagColor(word.tag),
                            visualDensity: VisualDensity(horizontal: 0.0, vertical: -4)
                          ),
                          Container(
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                            child: IconButton(
                                onPressed: (){
                                  if(word.bookmarked){
                                    setState(() {
                                      word.bookmarked = false;
                                    });
                                    deleteBookmark(word.id);
                                  }
                                  else{
                                    setState(() {
                                      word.bookmarked = true;
                                    });
                                    createBookmark(word.id);
                                  }
                                },
                                icon: word.bookmarked?
                                SvgPicture.asset(
                                  'assets/icons/star_fill.svg',
                                  fit: BoxFit.scaleDown,
                                )
                                    :
                                SvgPicture.asset(
                                  'assets/icons/star_unfill.svg',
                                  fit: BoxFit.scaleDown,
                                )
                            ),
                          )
                        ],

                      );
                    }),
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(thickness: 1, height: 3,);
                    },
                    itemCount: snapshot.data!.length
                ),
              );
            }
          }
        }
    );

    Widget retryLearnButtonSection = Container(
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
      height: 56,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 6,
            blurRadius: 7,
            offset: Offset(0, 8),
          )
        ]
      ),
      child: OutlinedButton(
          onPressed: () {
            if (widget.isTodayWord == true) {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => PronouncePracticePage(idx: 0, isTodayLearn: true, wordList: widget.wordList, pcList: [],), //이미 학습한것은 어떻게 처리? idx
              ));
            }
            else {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => PronouncePracticePage(idx: 0, isTodayLearn: false, wordList: widget.tagList, pcList: [],), //이미 학습한것은 어떻게 처리? idx
              ));
            }
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
              '다시 학습',
              style: TextStyles.mediumRecordTextStyle,
            ),
          )
      ),
    );

    Widget goMainPageSection = Container(
      margin: const EdgeInsets.only(left: 14, right: 14),
      height: 56,
      child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: ColorStyles.saeraOlive1,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
            ),
            side: const BorderSide(
              width: 1.0,
              color: ColorStyles.saeraOlive1,
            ),
          ),
          child: const Center(
            child: Text(
              '메인 화면으로',
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
          retryLearnButtonSection,
          goMainPageSection
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
                preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      backSection,
                      todayLearnWordTextSection
                    ],
                  ),
                )
            ),
            body: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                wordListSection,
              ],
            ),
            bottomSheet: bottomButtonSection,
          ),
        )
    );
  }

}

class Word {
  final int id;
  final String notation;
  final String pronunciation;
  final String tag;
  bool bookmarked;
  Word({required this.id, required this.notation, required this.pronunciation, required this.tag, required this.bookmarked});
}