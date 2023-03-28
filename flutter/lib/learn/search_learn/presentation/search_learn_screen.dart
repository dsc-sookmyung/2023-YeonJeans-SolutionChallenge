import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saera/learn/accent_learn/presentation/accent_learn_screen.dart';
import 'package:saera/learn/search_learn/presentation/widgets/response_statement.dart';
import 'package:http/http.dart' as http;

import '../../../login/data/authentication_manager.dart';
import '../../../server.dart';
import '../../../style/color.dart';
import '../../../style/font.dart';

class SearchPage extends StatefulWidget {

  final String value;

  const SearchPage({Key? key, required this.value}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final AuthenticationManager _authManager = Get.find();

  Future<dynamic>? statement;
  final List<ChipData> _chipList = [];
  List<String> situationList = ["일상", "소비", "인사", "은행/공공기관", "회사"];
  List<String> statementTypeList = ["의문문", "존댓말", "부정문", "감정표현"];
  int? _selectedIndex;

  late TextEditingController _textEditingController;

  bool _chipSectionVisibility = false;
  bool _categorySectionVisibility = false;

  bool checkChipList(String categoryName) {
    bool isExist = false;
    for(int i = _chipList.length-1; i >= 0; i--) { //리스트 검사해서
      if (_chipList[i].name == categoryName) { //버튼 눌렀을 때 이름이 같은게 있으면
        isExist = true;
        break;
      } else {
        isExist = false;
      }
    }
    return isExist;
  }

  void _setChipSectionVisibility() {
    setState(() {
      _chipList.isNotEmpty ? _chipSectionVisibility = true : _chipSectionVisibility = false;
    });
  }

  void _setCategorySectionVisibility() {
    setState(() {
      _selectedIndex != null ? _categorySectionVisibility = true : _categorySectionVisibility = false;
    });
  }

  void checkSituationCategorySelected(String categoryName) {
    bool isSituationCategorySelected = false;
    setState(() {
      for (int i = _chipList.length-1; i >= 0; i--) {
        if (_chipList[i].name == categoryName) {
          isSituationCategorySelected = true;
          _deleteChip(_chipList[i].id);
          break;
        } else {
          isSituationCategorySelected = false;
        }
        for (int j = 0; j < situationList.length; j++) {
          if (_chipList[i].name == situationList[j]) {
            isSituationCategorySelected = true;
            _deleteChip(_chipList[i].id);
            _addChip(categoryName);
            break;
          }
        }
      }
      if (isSituationCategorySelected == false) {
        _addChip(categoryName);
        isSituationCategorySelected == true;
      }
    });
  }

  void _setTypeVisibility(String categoryName) {
    bool isTypeCategorySelected = false;
    setState(() {
      for(int i = _chipList.length-1; i >= 0; i--) {
        if (_chipList[i].name == categoryName) {
          isTypeCategorySelected = true;
          _deleteChip(_chipList[i].id);
          break;
        } else {
          isTypeCategorySelected = false;
        }
      }
      if (isTypeCategorySelected == false) {
        _addChip(categoryName);
        isTypeCategorySelected = true;
      } else {
        return;
      }
    });
  }

  void _addChip(var chipText) {
    setState(() {
      if (widget.value != "") {
        _chipList.add(ChipData(
            id: DateTime.now().toString(),
            name: chipText,
            color: {situationList.contains(chipText) ? ColorStyles.saeraPink2 : ColorStyles.saeraBeige}
        ));
        statement = searchStatement("");
      } else {
        Container();
      }
      _setChipSectionVisibility();
    });
  }

  void _deleteChip(String id) {
    setState(() {
      _chipList.removeWhere((element) => element.id == id);
      statement = searchStatement("");
      _setChipSectionVisibility();
    });
  }

  void _deleteAllChip() {
    for (int i = _chipList.length-1; i >= 0; i--) {
      _deleteChip(_chipList[i].id);
    }
    _setChipSectionVisibility();
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

  Future<List<Statement>> searchStatement(String input) async {
    List<Statement> _list = [];
    Uri url;
    String tags = "";
    for (int i = _chipList.length-1; i >= 0; i--) {
      tags += 'tags=${_chipList[i].name}&';
    }
    if (input == "") {
      url = Uri.parse('$serverHttp/statements?$tags');
    } else {
      url = Uri.parse('$serverHttp/statements?content=$input&$tags');
    }
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      if (_list.isEmpty) {
        for (dynamic i in body) {
          int id = i["id"];
          String content = i["content"];
          List<String> tags = List.from(i["tags"]);
          bool bookmarked = i["bookmarked"];
          bool recommended = i["recommended"];
          _list.add(Statement(id: id, content: content, tags: tags, bookmarked: bookmarked, recommended: recommended));
        }
      }
      return _list;
    } else {
      throw Exception("데이터를 불러오는데 실패했습니다.");
    }
  }

  createBookmark (int id) async {
    var url = Uri.parse('${serverHttp}/bookmark?type=STATEMENT&fk=$id');
    final response = await http.post(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    print("create : $response");
  }

  void deleteBookmark (int id) async {
    var url = Uri.parse('${serverHttp}/bookmark?type=STATEMENT&fk=$id');
    final response = await http.delete(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    print("delete : $response");
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    statement = searchStatement("");
    _addChip(widget.value);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    Widget appBarSection = Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent
                ),
                icon: SvgPicture.asset(
                  'assets/icons/back.svg',
                    color: ColorStyles.backIconGreen
                ),
                label: const Padding(
                  padding: EdgeInsets.only(bottom: 2.0),
                  child: Text(' 뒤로',
                    style: TextStyles.backBtnTextStyle,
                    textAlign: TextAlign.center,
                  ),
                )
            )
          ],
        ),
    );

    Widget searchSection = Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: <Widget>[
          Flexible(
              child: TextField(
                controller: _textEditingController,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ㆍ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ]'))
                ],
                maxLines: 1,
                onSubmitted: (s) {
                  setState(() {
                    statement = searchStatement(s);
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: SvgPicture.asset('assets/icons/search.svg', fit: BoxFit.scaleDown),
                  ),
                  hintText: '어떤 문장을 학습할까요?',
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

    List<String> filterList = ['상황', '문장 유형'];
    Widget filterSection = Container(
      child: Wrap(
          spacing: 7,
          children: List.generate(filterList.length, (index) {
            return ChoiceChip(
              label: Text(filterList[index]),
              labelStyle: TextStyles.small25TextStyle,
              avatar: _selectedIndex == index ? SvgPicture.asset('assets/icons/filter_up.svg') : SvgPicture.asset('assets/icons/filter_down.svg'),
              selectedColor: filterList[index] == "상황" ? ColorStyles.saeraPink2 : ColorStyles.saeraBeige,
              backgroundColor: Colors.white,
              visualDensity: VisualDensity(horizontal: 0.0, vertical: -2),
              side: _selectedIndex == index ? BorderSide(color: Colors.transparent) : BorderSide(color: ColorStyles.disableGray),
              selected: _selectedIndex == index,
              onSelected: (bool selected) {
                setState(() {
                  _selectedIndex = selected ? index : null;
                  _setCategorySectionVisibility();
                });
              },
            );
          }).toList()
      ),
    );

    InkWell selectSituationCategory(String icon, String categoryName) {
      return InkWell(
        onTap: () {
          checkSituationCategorySelected(categoryName);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height*0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: checkChipList(categoryName) ? 1.0 : 0.4,
                child: SvgPicture.asset(icon),
              ),
              Padding(padding: EdgeInsets.only(top: 3)),
              Opacity(
                opacity: checkChipList(categoryName) ? 1.0 : 0.4,
                child: Text(
                  categoryName,
                  style: TextStyles.tiny55TextStyle,
                ),
              )
            ],
          ),
        ),
      );
    }

    InkWell selectStatementCategory(String categoryName) {
      return InkWell(
        onTap: () {
          setState(() {
            _setTypeVisibility(categoryName);
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width*0.18,
          margin: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.2),
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.003),
          child: Row(
            children: [
              Opacity(
                opacity: checkChipList(categoryName) ? 1.0 : 0.5,
                child: Text(
                  categoryName,
                  style: TextStyles.small00TextStyle,
                ),
              ),
              Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),),
              Visibility(
                  visible: checkChipList(categoryName) ? true : false,
                  child: SvgPicture.asset('assets/icons/click_check.svg')
              )
            ],
          ),
        ),
      );
    }

    Widget selectCategorySection = Visibility(
        visible: _categorySectionVisibility,
        child: _selectedIndex == 0
            ? Container(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height*0.01,
                horizontal: MediaQuery.of(context).size.width*0.038
            ),
            //margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.005),
            decoration: const BoxDecoration(
              color: ColorStyles.tagGray,
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                selectSituationCategory('assets/icons/conservation.svg', '일상'),
                selectSituationCategory('assets/icons/order.svg', '소비'),
                selectSituationCategory('assets/icons/greeting.svg', '인사'),
                selectSituationCategory('assets/icons/public.svg', '은행/공공기관'),
                selectSituationCategory('assets/icons/company.svg', '회사'),
              ],
            )
        )
            : Container(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height*0.02,
                horizontal: MediaQuery.of(context).size.width*0.06
            ),
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.005),
            decoration: const BoxDecoration(
              color: ColorStyles.tagGray,
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: Wrap(
              children: [
                selectStatementCategory('의문문'),
                selectStatementCategory('존댓말'),
                selectStatementCategory('부정문'),
                selectStatementCategory('감정표현'),
              ],
            )
        )
    );

    Widget chipSection = Visibility(
      visible: _chipSectionVisibility,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width*0.75,
              height: MediaQuery.of(context).size.height*0.05,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  Wrap(
                      spacing: 8.0,
                      children: _chipList.map((chip) => Chip(
                        labelPadding: const EdgeInsets.only(left: 8.0, right: 4.0, bottom: 2.0),
                        labelStyle: TextStyles.small00TextStyle,
                        label: Text(
                          chip.name,
                        ),
                        backgroundColor: chip.color.first,
                        visualDensity: VisualDensity(horizontal: 0.0, vertical: -2),
                        onDeleted: () => _deleteChip(chip.id),
                      )).toList()
                  )
                ]
              ),
            ),
            IconButton(
              onPressed: () => {
                if (_chipList.isNotEmpty) {
                  _deleteAllChip(),
                  statement = searchStatement(""),
                } else {
                  Container(),
                }
              },
              icon: SvgPicture.asset('assets/icons/refresh.svg', color: ColorStyles.totalGray,),
            ),
          ],
        )
    );

    Container recommendedStatement(Statement statement) {
      if (statement.recommended == true) {
        return Container(
          margin: EdgeInsets.only(left: 5),
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
          decoration: BoxDecoration(
              color: ColorStyles.saeraPink2.withOpacity(0.5),
              borderRadius: BorderRadius.all(Radius.circular(4.0))
          ),
          child: const Text(
            '추천',
            style: TextStyles.tinyPinkTextStyle,
            textAlign: TextAlign.center,
          ),
        );
      } else {
        return Container();
      }
    }


    Widget statementSection = FutureBuilder(
        future: statement,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              List<Statement> statements = snapshot.data;
              return Container(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
                height: MediaQuery.of(context).size.height*0.7,
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      statement = searchStatement("");
                    });
                  },
                  child: ListView.separated(
                      itemBuilder: ((context, index) {
                        Statement statement = statements[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AccentPracticePage(id: statement.id, isCustom: false))
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: statements.length - 1 == index ? 120 : 0
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(vertical: 3),
                                          child: Text(
                                              statement.content,
                                              style: TextStyles.regular00TextStyle
                                          ),
                                        ),
                                        recommendedStatement(statement)
                                      ],
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width*0.7,
                                      child: Wrap(
                                        spacing: 7.0,
                                        children: statement.tags.map((tag) {
                                          return Chip(
                                              label: Text(tag),
                                              labelStyle: TextStyles.small00TextStyle,
                                              backgroundColor: selectTagColor(tag),
                                              visualDensity: VisualDensity(horizontal: 0.0, vertical: -4)
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  ],
                                ),
                                IconButton(
                                    onPressed: (){
                                      if(statement.bookmarked){
                                        setState(() {
                                          statement.bookmarked = false;
                                        });
                                        deleteBookmark(statement.id);
                                      }
                                      else{
                                        setState(() {
                                          statement.bookmarked = true;
                                        });
                                        createBookmark(statement.id);
                                      }
                                    },
                                    icon: statement.bookmarked?
                                    SvgPicture.asset(
                                      'assets/icons/star_fill.svg',
                                      fit: BoxFit.scaleDown,
                                    )
                                        :
                                    SvgPicture.asset(
                                      'assets/icons/star_unfill.svg',
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
                      itemCount: statements.length
                  ),
                )
              );
            }
          } else {
            return Container();
          }
        })
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
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 21.0),
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    appBarSection,
                    searchSection,
                    filterSection,
                    selectCategorySection,
                    chipSection,
                    statementSection,
                  ],
                ),
              )
            )
        )
      ],
    );
  }
}

class ChipData {
  final String id;
  final String name;
  final Set<Color> color;
  ChipData({required this.id, required this.name, required this.color});
}