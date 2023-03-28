import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:saera/learn/accent_learn/presentation/accent_learn_screen.dart';
import 'package:saera/learn/custom_learn/create_sentence/presentation/create_sentence_screen.dart';
import 'package:saera/learn/search_learn/presentation/widgets/response_statement.dart';
import 'package:saera/learn/search_learn/presentation/widgets/search_learn_background.dart';
import 'package:http/http.dart' as http;

import '../../../../login/data/authentication_manager.dart';
import '../../../../server.dart';
import '../../../../style/color.dart';
import '../../../../style/font.dart';


class LearnStatementPage extends StatefulWidget {

  @override
  State<LearnStatementPage> createState() => _LearnStatementPageState();
}

class _LearnStatementPageState extends State<LearnStatementPage> {
  final AuthenticationManager _authManager = Get.find();

  Future<dynamic>? statementData;
  int tagCount = 0;
  List<Tag> tagList = [];
  final List<ChipData> _chipList = [];
  int? _selectedIndex;

  late TextEditingController _textEditingController;

  bool _chipSectionVisibility = false;
  bool _categorySectionVisibility = false;

  bool checkChipList(String categoryName) {
    bool isExist = false;
    for(int i = _chipList.length-1; i >= 0; i--) {
      if (_chipList[i].name == categoryName) {
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
      _chipList.add(ChipData(
            id: DateTime.now().toString(),
            name: chipText,
      ));
      statementData = searchCustomStatement("");
      _setChipSectionVisibility();
    });
  }

  void _deleteChip(String id) {
    setState(() {
      _chipList.removeWhere((element) => element.id == id);
      statementData = searchCustomStatement("");
      _setChipSectionVisibility();
    });
  }

  void _deleteAllChip() {
    for (int i = _chipList.length-1; i >= 0; i--) {
      _deleteChip(_chipList[i].id);
    }
  }

  createBookmark (int id) async {
    var url = Uri.parse('$serverHttp/bookmark?type=CUSTOM&fk=$id');
    final response = await http.post(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    print("create : $response");
  }

  deleteBookmark (int id) async {
    var url = Uri.parse('$serverHttp/bookmark?type=CUSTOM&fk=$id');
    final response = await http.delete(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    print("delete : $response");
  }

  Future<List<Tag>> getTag() async {
    var url = Uri.parse('$serverHttp/customs/tags');
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      for (dynamic i in body) {
        int id = i["id"];
        String name = i["name"];
        tagList.add(Tag(id: id, name: name));
        tagCount++;
      }
    }
    return tagList;
  }

  Future<List<Statement>> searchCustomStatement(String input) async {
    await Future.delayed(const Duration(milliseconds: 300));
    List<Statement> _list = [];
    Uri url;
    String tags = "";
    for (int i = _chipList.length-1; i >= 0; i--) {
      tags += 'tags=${_chipList[i].name}&';
    }
    if (input == "") {
      url = Uri.parse('$serverHttp/customs?$tags');
    } else {
      url = Uri.parse('$serverHttp/customs?content=$input&$tags');
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

  deleteCustomStatement(int id) async {
    var url = Uri.parse('$serverHttp/customs/$id');
    final response = await http.delete(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    print("delete Custom : $response");
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    getTag();
    statementData = searchCustomStatement("");
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
                    statementData = searchCustomStatement(s);
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: SvgPicture.asset('assets/icons/search.svg', fit: BoxFit.scaleDown),
                  ),
                  hintText: '${_authManager.getName()}님이 만든 문장 내에서 검색합니다.',
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

    List<String> filterList = ['태그'];
    Widget filterSection = Wrap(
        spacing: 7,
        children: List.generate(filterList.length, (index) {
          return ChoiceChip(
            label: Text(filterList[index]),
            labelStyle: TextStyles.small25TextStyle,
            avatar: _selectedIndex == index ? SvgPicture.asset('assets/icons/filter_up.svg') : SvgPicture.asset('assets/icons/filter_down.svg'),
            backgroundColor: Colors.white,
            side: _selectedIndex == index? BorderSide(color: Colors.transparent) : BorderSide(color: ColorStyles.disableGray),
            visualDensity: VisualDensity(horizontal: 0.0, vertical: -2),
            selected: _selectedIndex == index,
            onSelected: (bool selected) {
              setState(() {
                _selectedIndex = selected ? index : null;
                _setCategorySectionVisibility();
              });
            },
          );
        }).toList()
    );

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
                vertical: MediaQuery.of(context).size.height*0.02,
                horizontal: MediaQuery.of(context).size.width*0.06
              ),
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.005),
              decoration: const BoxDecoration(
                color: ColorStyles.tagGray,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: tagList.length >= 5
                  ? SizedBox(
                  height: 40,
                  child: ListView(
                    children: [
                      Wrap(
                          children: tagList.map((tag){
                            return selectStatementCategory(tag.name);
                          }).toList()
                      )
                    ],
                  ),
              )
                  : Wrap(
                  children: tagList.map((tag){
                    return selectStatementCategory(tag.name);
                  }).toList()
              )
            )
            : Container()
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
                  statementData = searchCustomStatement("")
                } else {
                  Container(),
                }
              },
              icon: SvgPicture.asset('assets/icons/refresh.svg', color: ColorStyles.totalGray,),
            ),
          ],
        )
    );

    Container notExistStatement() {
      return Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.15),
        child: Center(
          child: Column(
            children: [
              SvgPicture.asset('assets/icons/box_open.svg'),
              Padding(padding: EdgeInsets.all(4)),
              const Text(
                '아직 생성한 문장이 없습니다.\n화면 우측 하단의 + 버튼을 눌러\n직접 학습할 문장을 생성해 보세요.',
                style: TextStyles.regular82TextStyleWithHeight,
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      );
    }

    FutureBuilder existStatement(List<Statement> statements) {
      return FutureBuilder(
        future: statementData,
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
                padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 16),
                height: MediaQuery.of(context).size.height*0.72,
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      statementData = searchCustomStatement("");
                    });
                  },
                  child: ListView.separated(
                      itemBuilder: ((context, index) {
                        Statement statement = statements[index];
                        return Dismissible(
                            key: Key(statement.id.toString()),
                            background: Container(
                                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05),
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                )
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              setState(() {
                                statements.removeAt(index);
                                deleteCustomStatement(statement.id);
                                statementData = searchCustomStatement("");
                              });
                            },
                            child: InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => AccentPracticePage(id: statement.id, isCustom: true),
                                ));
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
                                        Container(
                                          padding: EdgeInsets.symmetric(vertical: 3),
                                          child: Text(
                                              statement.content,
                                              style: TextStyles.regular00TextStyle
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width*0.7,
                                          child: Wrap(
                                            spacing: 7.0,
                                            children: statement.tags.map((tag) {
                                              return Chip(
                                                  label: Text(tag),
                                                  labelStyle: TextStyles.small00TextStyle,
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
            return throw Exception("오류");
          }
        })
      );
    }

    Widget statementSection = FutureBuilder(
        future: statementData,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                  child: Container(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.03),
                      child: Text(snapshot.error.toString())
                  )
              );
            } else {
              List<Statement> statements = snapshot.data;
              if (statements.isEmpty) {
                return notExistStatement();
              } else {
                return existStatement(statements);
              }
            }
          } else {
            return notExistStatement();
          }
        })
    );

    Widget floatingButtonSection = Container(
      margin: EdgeInsets.only(right: 8, bottom: 8),
      child: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => CreateSentenceScreen(),
          ));
        },
        backgroundColor: ColorStyles.saeraAppBar,
        child: SvgPicture.asset('assets/icons/plus.svg'),
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
                body: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 21.0),
                    children: <Widget>[
                      appBarSection,
                      searchSection,
                      filterSection,
                      selectCategorySection,
                      chipSection,
                      statementSection,
                    ],
                  ),
                ),
              floatingActionButton: floatingButtonSection,
            )
        )
      ],
    );
  }
}

class ChipData {
  final String id;
  final String name;
  ChipData({required this.id, required this.name});
}

class Tag {
  final int id;
  final String name;
  Tag({required this.id, required this.name});
}