import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:saera/style/font.dart';
import 'package:http/http.dart' as http;

import '../../../learn/accent_learn/presentation/accent_learn_screen.dart';
import '../../../learn/search_learn/presentation/widgets/response_statement.dart';
import '../../../login/data/authentication_manager.dart';
import '../../../login/data/refresh_token.dart';
import '../../../server.dart';
import '../../../style/color.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final AuthenticationManager _authManager = Get.find();

  Future<dynamic>? statement1;
  Future<dynamic>? word1;
  int _selectedIndex = 1;

  List<Statement> statementList = [];
  List<Word> wordList = [];

  getStatement(int _selectedIndex) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var url;
    if (_selectedIndex == 1) {
      url = Uri.parse('$serverHttp/statements?bookmarked=true');
    } else {
      url = Uri.parse('$serverHttp/customs?bookmarked=true');
    }
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });

    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      statementList.clear();
      for (dynamic i in body) {
        int id = i["id"];
        String content = i["content"];
        List<String> tags = List.from(i["tags"]);
        bool bookmarked = i["bookmarked"];
        bool recommended = i["recommended"];
        statementList.add(Statement(id: id, content: content, tags: tags, bookmarked: bookmarked, recommended: recommended, ));
      }
    } else if (response.statusCode == 401) {
      String? before = _authManager.getToken();
      await RefreshToken(context);

      if(before != _authManager.getToken()){
        getStatement(_selectedIndex);
      }
    }
  }

  getWord(int _selectedIndex) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var url = Uri.parse('$serverHttp/words?bookmarked=true');
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });

    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      wordList.clear();
      for (dynamic i in body) {
        int id = i["id"];
        String notation = i["notation"];
        String pronunciation = i["pronunciation"];
        String tag = i["tag"];
        bool bookmarked = i["bookmarked"];
        wordList.add(Word(id: id, notation: notation, pronunciation: pronunciation, tag: tag, bookmarked: bookmarked));
      }
    } else if (response.statusCode == 401){
      String? before = _authManager.getToken();
      await RefreshToken(context);

      if(before != _authManager.getToken()){
        getWord(_selectedIndex);
      }
    }
  }

  void deleteBookmark (int id, int _selectedIndex) async {
    var url;
    if (_selectedIndex == 0) {
      url = Uri.parse('$serverHttp/bookmark?type=WORD&fk=$id');
    } else if (_selectedIndex == 1) {
      url = Uri.parse('$serverHttp/bookmark?type=STATEMENT&fk=$id');
    } else {
      url = Uri.parse('$serverHttp/bookmark?type=CUSTOM&fk=$id');
    }
    final response = await http.delete(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    print("delete : $response");
  }

  Color selectTagColor(String tag) {
    if (tag == '일상' || tag == '소비' || tag == '인사' || tag == '은행/공공기관' || tag == '회사') {
      return ColorStyles.saeraPink2;
    } else if (tag == '의문문' || tag == '존댓말' || tag == '부정문' || tag == '감정표현') {
      return ColorStyles.saeraBeige;
    } else {
      return ColorStyles.saeraYellow.withOpacity(0.5);
    }
  }

  Color selectWordTagColor(String tag) {
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

  @override
  void initState() {
    super.initState();
    statement1 = getStatement(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    Widget textSection = Container(
      padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
      child: Text(
        _selectedIndex == 0 ? "${_authManager.getName()}님이 즐겨찾기한\n발음들이에요." : "${_authManager.getName()}님이 즐겨찾기한\n억양들이에요.",
        style: TextStyles.xxLargeTextStyle
      )
    );

    List<String> filterList = ['발음', '억양', '사용자 정의'];
    Widget filterSection = Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height*0.02,
        left: 10.0,
        right: 10.0
      ),
      child: Wrap(
          spacing: 7,
          children: List.generate(filterList.length, (index) {
            return ChoiceChip(
              label: Text(filterList[index]),
              labelStyle: TextStyles.small25TextStyle,
              selectedColor: ColorStyles.saeraBeige,
              backgroundColor: Colors.white,
              side: _selectedIndex == index ? BorderSide(color: Colors.transparent) : BorderSide(color: ColorStyles.disableGray),
              visualDensity: VisualDensity(horizontal: 0.0, vertical: -2),
              selected: _selectedIndex == index,
              onSelected: (bool selected) {
                setState(() {
                  _selectedIndex = selected ? index : _selectedIndex;
                });
              },
            );
          }).toList()
      ),
    );

    Widget bookmarkStatementSection(){
      return FutureBuilder(
          future: getStatement(_selectedIndex),
          builder: ((context, snapshot) {
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
            } else if (snapshot.connectionState == ConnectionState.done) {
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
                    padding: EdgeInsets.only(top: 16.0, left: 10.0, right: 10.0),
                    height: MediaQuery.of(context).size.height*0.65,
                    child: RefreshIndicator(
                      onRefresh: () async => (
                          setState(() {
                            getStatement(_selectedIndex);
                          })
                      ),
                      child: ListView.separated(
                          itemBuilder: ((context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => AccentPracticePage(id: statementList[index].id, isCustom: false),
                                ));
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    bottom: statementList.length - 1 == index ? 120 : 0
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 3),
                                          child: Text(
                                              statementList[index].content,
                                              style: TextStyles.regular00TextStyle
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width*0.7,
                                          child: Wrap(
                                            spacing: 7.0,
                                            children: statementList[index].tags.map((tag) {
                                              return Chip(
                                                label: Text(tag),
                                                labelStyle: TextStyles.small00TextStyle,
                                                backgroundColor: selectTagColor(tag),
                                                visualDensity: const VisualDensity(vertical: -4),
                                              );
                                            }).toList(),
                                          ),
                                        )
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: (){
                                          setState(() {
                                            statementList[index].bookmarked = false;
                                            deleteBookmark(statementList[index].id, _selectedIndex);
                                            getStatement(_selectedIndex);
                                          });

                                        },
                                        icon: SvgPicture.asset(
                                          'assets/icons/star_fill.svg',
                                          fit: BoxFit.scaleDown,
                                        )
                                    )
                                  ],
                                ),
                              )
                            );
                          }),
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(thickness: 1,);
                          },
                          itemCount: statementList.length
                      ),
                    )
                );
              }
            } else {
              return Container();
            }
          })
      );
    }

    Widget bookmarkWordSection() {
      return FutureBuilder(
          future: getWord(_selectedIndex),
          builder: ((context, snapshot) {
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
            } else if (snapshot.connectionState == ConnectionState.done) {
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
                    padding: EdgeInsets.only(top: 16.0, left: 10.0, right: 10.0),
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: RefreshIndicator(
                      onRefresh: () async => (
                          setState(() {
                            word1 = getWord(_selectedIndex);
                          })
                      ),
                      child: ListView.separated(
                          itemBuilder: ((context, index) {
                            return InkWell(
                              onTap: null,
                              child: Container(
                                margin: EdgeInsets.only(
                                    bottom: wordList.length - 1 == index ? 120 : 0
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      wordList[index].notation,
                                      style: TextStyles.regular00TextStyle,
                                    ),
                                    Text(
                                      '[${wordList[index].pronunciation}]',
                                      style: TextStyles.regularGreenTextStyle,
                                    ),
                                    Spacer(flex: 2,),
                                    Chip(
                                      label: Text(
                                        wordList[index].tag,
                                        style: TextStyles.small00TextStyle,
                                      ),
                                      backgroundColor: selectWordTagColor(wordList[index].tag),
                                      visualDensity: const VisualDensity(vertical: -4),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              wordList[index].bookmarked = false;
                                              deleteBookmark(wordList[index].id, _selectedIndex);
                                              word1 = getWord(_selectedIndex);
                                            });
                                          },
                                          icon: SvgPicture.asset(
                                            'assets/icons/star_fill.svg',
                                            fit: BoxFit.scaleDown,
                                          )
                                      ),
                                    )
                                  ],
                                ),
                              )
                            );
                          }),
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(thickness: 1,);
                          },
                          itemCount: wordList.length
                      ),
                    )
                );
              }
            } else {
              return Container();
            }
          })
      );
    }

    Widget listSection() {
      if (_selectedIndex == 0) {
        return bookmarkWordSection();
      } else {
        return bookmarkStatementSection();
      }
    }

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
                  children: <Widget>[
                    textSection,
                    filterSection,
                    listSection()
                  ],
                ),

            )
        )
      ],
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