import 'dart:io';
import 'dart:io' show Platform;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saera/learn/accent_learn/presentation/widgets/audio_bar.dart';
import 'package:saera/learn/pronounce_learn/widgets/word_tag.dart';
import 'package:saera/login/data/refresh_token.dart';
import 'package:saera/style/color.dart';
import 'package:saera/style/font.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:saera/server.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:saera/learn/pronounce_learn/today_learn_word_list.dart';
import 'dart:convert';

import '../../../login/data/authentication_manager.dart';
import '../../login/data/user_info_controller.dart';
import '../../login/presentation/widget/profile_image_clipper.dart';

class PronouncePracticePage extends StatefulWidget {

  final int idx;
  final bool isTodayLearn;
  final List<int> wordList;
  final List<int> pcList;

  // wordList.length를 체크 후 length보다 작으면 idx 증가해서 보여주는 방식 처음 화면에서 넘겨 줄 때는 무조건 0
  const PronouncePracticePage({Key? key, required this.idx, required this.isTodayLearn, required this.wordList, required this.pcList}) : super(key: key);

  @override
  State<PronouncePracticePage> createState() => _PronouncePracticePageState();
}

class _PronouncePracticePageState extends State<PronouncePracticePage> with TickerProviderStateMixin {
  final AuthenticationManager _authManager = Get.find();
  final UserInfoController _userController = Get.find();

  late FToast fToast;

  int contentTag = 0;
  String content = "";
  String contentPronounce = "";
  String contentInfo = "";
  String userName = "";

  double accuracyRate = 0;
  int recordingState = 1;


  bool _isBookmarked = false;
  bool _isRecording = false;
  bool _isPracticed = false;
  late Future <dynamic> _isAudioReady;

  AudioPlayer audioPlayer = AudioPlayer();

  List<int> practicedList = List.empty(growable : true);

  // String audioPath = "mp3/ex.wav";
  String audioPath = "";
  String recordingPath = "";

  final _recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  Widget wordActiveNextBtn(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: ColorStyles.saeraOlive1
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: ColorStyles.saeraOlive1,
        boxShadow:[
          BoxShadow(
            color: ColorStyles.black00.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: const Text(
        "다음",
        style: TextStyles.regularWhiteTextStyle,
      ),

    );
  }

  Widget activeNextBtn(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: ColorStyles.saeraOlive1
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: const Text(
        "다음",
        style: TextStyles.regularOliveTextStyle,
      ),

    );
  }

  Widget completeBtn(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: ColorStyles.saeraOlive1
        ),
        color: ColorStyles.saeraOlive1,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: const Text(
        "완료",
        style: TextStyles.regularWhiteTextStyle,
      ),

    );
  }

  Widget unActiveCompleteBtn(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: ColorStyles.disableGray
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: const Text(
        "완료",
        style: TextStyles.regularAATextStyle,
      ),

    );
  }

  Widget unActiveNextBtn(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: ColorStyles.disableGray
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: const Text(
        "다음",
        style: TextStyles.regularAATextStyle,
      ),

    );
  }

  getExampleAccent() async {

    var url = Uri.parse('${serverHttp}/words/${widget.wordList[widget.idx]}');
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });



    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        content = body["notation"];
        contentPronounce = body["pronunciation"];
        contentInfo = body["definition"];
        _isBookmarked = body["bookmarked"];
        contentTag = body["tag_id"];
      });

    }
    else if(response.statusCode == 401){
      String? before = _authManager.getToken();
      await RefreshToken(context);

      if(before != _authManager.getToken()){
        getExampleAccent();
      }


    }
  }



  Future<dynamic> getTTS() async {

    var url = Uri.parse('${serverHttp}/words/record/${widget.wordList[widget.idx]}');

    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "audio/wav", "authorization" : "Bearer ${_authManager.getToken()}"});

    if (response.statusCode == 200) {
      Uint8List audioInUnit8List = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();

      File file = await File('${tempDir.path}/exampleAudio${widget.wordList[widget.idx]}.wav').create();
      file.writeAsBytesSync(audioInUnit8List);

      setState(() {
        audioPath = file.path;
      });

      return true;
    }
    else{
      return false;
    }
  }

  createBookmark (int id) async {

    var url = Uri.parse('${serverHttp}/bookmark?type=WORD&fk=${widget.wordList[widget.idx]}');


    final response = await http.post(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}"});

    if (response.statusCode == 200) {
      print(response.body);

      setState(() {
        _isBookmarked = !_isBookmarked;
      });
    }
  }

  void deleteBookmark () async {
    var url = Uri.parse('${serverHttp}/bookmark?type=WORD&fk=${widget.wordList[widget.idx]}');

    final response = await http.delete(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}", "RefreshToken" : "Bearer ${_authManager.getRefreshToken()}" });

    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
    }
  }

  getUserExp() async {
    var url = Uri.parse('${serverHttp}/member');
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });

    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));

      int xp = 0;

      setState(() {
        xp = body["xp"];
        print("xp changed : $xp");
      });

      _userController.saveExp(xp);

    }
    else{
      print(jsonDecode(utf8.decode(response.bodyBytes)));
    }
  }

  completePractice() async {
    var url = Uri.parse('${serverHttp}/practice?type=WORD&fk=${widget.wordList[widget.idx].toString()}&isTodayStudy=${widget.isTodayLearn}');
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({'accept': 'application/json', "content-type": "multipart/form-data" , "authorization" : "Bearer ${_authManager.getToken()}"});

    request.files.add(await http.MultipartFile.fromPath('record', recordingPath));

    var responsed = await request.send();
    var response = await http.Response.fromStream(responsed);

    if (responsed.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      practicedList.add(widget.wordList[widget.idx]);
      if(widget.isTodayLearn && _authManager.getTodayWordIdx()! < widget.idx +1){
        _authManager.saveTodayWordIdx(widget.idx + 1);
      }

      print(body);
      setState(() {
        _isPracticed = true;
      });

      getUserExp();
      return true;
    }
  }


  @override
  void initState(){
    initRecorder();
    getExampleAccent();
    _isAudioReady = getTTS();
    fToast = FToast();
    fToast.init(context);
    practicedList = widget.pcList;

    if(widget.isTodayLearn && _authManager.getTodayWordIdx() == null){
      _authManager.saveTodayWordIdx(0);
    }

    super.initState();
  }

  @override
  void dispose(){
    _recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if(status != PermissionStatus.granted){
      throw 'Microphone permission not granted';
    }else{
      if (await Permission.storage.request().isGranted){

        if(Platform.isAndroid){
          Directory appFolder = Directory("/storage/emulated/0/saera");
          bool appFolderExists = await appFolder.exists();

          if (!appFolderExists) {
            final created = await appFolder.create(recursive: true);
            print(created.path);
          }
        }

        await _recorder.openRecorder();
        isRecorderReady = true;
      }

    }

  }

  Future startRecording() async {
    if(!isRecorderReady){
      return;
    }
    if(Platform.isAndroid){
      await _recorder.startRecorder(toFile: '/storage/emulated/0/saera/practiceAudio.wav');
    }
    else{
      await _recorder.startRecorder(toFile: 'audio.wav');

    }
  }

  Future stopRecording() async {
    if(!isRecorderReady){
      return;
    }

    recordingPath  = (await _recorder.stopRecorder())!;
    final audioFile = File(recordingPath!);
    print("녹음이 완료되었습니다. ${audioFile.path}");

    if(Platform.isAndroid){
      recordingPath = '/storage/emulated/0/saera/practiceAudio.wav';
    }
  }

  Widget todayTopBarSection(bool isRecord){
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (){
              if(widget.idx != 0 || !widget.isTodayLearn){
                return GestureDetector(
                  onTap: (){
                    if(widget.idx - 1 >= 0 || !widget.isTodayLearn ){

                      int nextIdx = widget.idx - 1;
                      print(nextIdx);

                      if(!widget.isTodayLearn && widget.idx - 1 < 0){
                        nextIdx = widget.wordList.length - 1;
                      }

                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PronouncePracticePage(idx: nextIdx, isTodayLearn: widget.isTodayLearn, wordList: widget.wordList, pcList: [],)),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: ColorStyles.saeraOlive1
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      color: Colors.white,
                      boxShadow:[
                        BoxShadow(
                          color: ColorStyles.black00.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    child: const Text(
                      "이전",
                      style: TextStyles.regularOliveTextStyle,
                    ),

                  ),
                );
              }
              else{
                return const Spacer();
              }
            }(),

            GestureDetector(
                onTap: (){
                  if(((isRecord || (widget.isTodayLearn && _authManager.getTodayWordIdx()! >= widget.idx) ) && widget.idx + 1 != 5) || !widget.isTodayLearn){

                    int nextIdx = widget.idx + 1;

                    if(!widget.isTodayLearn && widget.idx + 1 == widget.wordList.length){
                      nextIdx = 0;
                    }

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PronouncePracticePage(idx: nextIdx, isTodayLearn: widget.isTodayLearn, wordList: widget.wordList, pcList: [],)),
                    );
                  }
                  else if((isRecord  || (widget.isTodayLearn && _authManager.getTodayWordIdx()! >= widget.idx) ) && widget.idx + 1 == 5 && widget.isTodayLearn){
                    //TODO 학습 결과 리스트를 보여주는 페이지로 페이지 전환
                    _authManager.saveTodayWordIdx(widget.idx + 1);
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => TodayLearnWordListPage(wordList: [], isTodayWord: true, tagList: [],),
                    ));
                  }
                },
                child: (){
                  if((isRecord || (widget.isTodayLearn && _authManager.getTodayWordIdx()! > widget.idx)) && (widget.idx + 1 == 5 && widget.isTodayLearn)){
                    return completeBtn();
                  }
                  else if(widget.idx + 1 == 5 && widget.isTodayLearn){
                    return unActiveCompleteBtn();
                  }
                  else if(isRecord || !widget.isTodayLearn || (widget.isTodayLearn && _authManager.getTodayWordIdx()! > widget.idx )){
                    return activeNextBtn();
                  }
                  else{
                    return unActiveNextBtn();
                  }

                }()
            )
          ],
        ),

        Center(
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: (){

                  if(widget.idx == 0){
                    return Image.asset('assets/icons/first_progress.png');
                  }
                  else if(widget.idx == 1){
                    return Image.asset('assets/icons/second_progress.png');
                  }
                  else if(widget.idx == 2){
                    return Image.asset('assets/icons/third_progress.png');
                  }
                  else if(widget.idx == 3){
                    return Image.asset('assets/icons/fourth_progress.png');
                  }
                  else {
                    return Image.asset('assets/icons/fifth_progress.png');
                  }

                }()
            )
        )
      ],
    );
  }

  Widget topBarSection (bool isRecord){
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: (){
                if(widget.idx - 1 >= 0 || !widget.isTodayLearn ){

                  int nextIdx = widget.idx - 1;
                  print(nextIdx);

                  if(!widget.isTodayLearn && widget.idx - 1 < 0){
                    nextIdx = widget.wordList.length - 1;
                  }

                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PronouncePracticePage(idx: nextIdx, isTodayLearn: widget.isTodayLearn, wordList: widget.wordList, pcList: practicedList,)),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: ColorStyles.saeraOlive1
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    color: Colors.white,
                    boxShadow:[
                      BoxShadow(
                        color: ColorStyles.black00.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 0), // changes position of shadow
                      ),
                    ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                child: const Text(
                  "이전",
                  style: TextStyles.regularOliveTextStyle,
                ),

              ),
            ),

            GestureDetector(
                onTap: (){
                  if(((isRecord || (widget.isTodayLearn && _authManager.getTodayWordIdx()! >= widget.idx) ) && widget.idx + 1 != 5) || !widget.isTodayLearn){

                    int nextIdx = widget.idx + 1;

                    if(!widget.isTodayLearn && widget.idx + 1 == widget.wordList.length){
                      nextIdx = 0;
                    }

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PronouncePracticePage(idx: nextIdx, isTodayLearn: widget.isTodayLearn, wordList: widget.wordList, pcList: practicedList,)),
                    );
                  }
              },
              child: (){
                return wordActiveNextBtn();
              }()
            )
          ],
        ),

        Center(
          child: GestureDetector(
            onTap: (){
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TodayLearnWordListPage(wordList: practicedList.toSet().toList(), isTodayWord: widget.isTodayLearn, tagList: widget.wordList,)),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                  "그만 학습하기",
                  style: TextStyles.mediumGrayTextStyle
              ),
            )
          ),
        )
      ],
    );
  }


  Widget appBarSection (){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
              icon: SvgPicture.asset(
                'assets/icons/back.svg',
                color: ColorStyles.saeraAppBar,
                fit: BoxFit.scaleDown,
              ),
              label: const Text(' 뒤로',
                  style: TextStyles.backBtnTextStyle
              )
          ),

          IconButton(
              onPressed: (){
                if(_isBookmarked){
                  deleteBookmark();
                }
                else{
                  createBookmark(widget.wordList[widget.idx]);
                }
              },
              icon: _isBookmarked ?
              SvgPicture.asset(
                'assets/icons/star_fill.svg',
                fit: BoxFit.scaleDown,
              )
                  :
              SvgPicture.asset(
                'assets/icons/star_unfill.svg',
                color: ColorStyles.saeraAppBar,
                fit: BoxFit.scaleDown,
              )
          )

        ],
      ),
    );
  }

  Widget practiceSentenceSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.only(top:20.0, bottom: 20.0, left: 16, right: 16),
      decoration: BoxDecoration(
          color: ColorStyles.searchFillGray,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              content,
              style: TextStyles.large00MediumTextStyle,
            ),
            const SizedBox(height: 4),
            Text(
              contentInfo,
              style: TextStyles.regular55TextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        )
      ),
    );
  }

  Widget pronounceSection(){
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.only(top:20.0, bottom: 20.0),
      decoration: BoxDecoration(
          color: ColorStyles.searchFillGray,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$content ",
              style: TextStyles.large00MediumTextStyle,
            ),
            Text(
              "[$contentPronounce]",
              style: TextStyles.largeGreenTextStyle,
            ),
          ],
        )
      ),
    );
  }

  Widget pronounceMethodSection(){
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.only(top:14.0, bottom: 14.0),
      decoration: BoxDecoration(
          color: ColorStyles.saeraOlive3,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/light.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 16,),
            Text(
              WordTip(contentTag),
              maxLines: 2,
              style: TextStyles.small55TextStyle,
            ),
          ],
        )
      ),
    );
  }

  Widget exampleSectionText(){
    return Row(
      children: [
        SvgPicture.asset(
            'assets/icons/flag.svg',
            color: ColorStyles.saeraOlive1,
        ),
        const SizedBox(width: 9,),
        const Text(
          "이 발음을 목표로 연습해 볼까요?",
          style: TextStyles.medium00BoldTextStyle,
        )

      ],
    );
  }

  Widget exampleSection(){
    return Container(
      margin: const EdgeInsets.only(top: 28),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            exampleSectionText(),
            FutureBuilder(
                future: _isAudioReady,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData == false) {
                    return Column(
                      children: [
                        before_audio_bar(),
                        pronounceSection(),
                        pronounceMethodSection(),
                      ],
                    );
                  }
                  else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  }
                  // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행
                  else {
                    return Column(
                      children: [
                        AudioBar(recordPath: audioPath, isRecording: false, isAccent: false,),
                        pronounceSection(),
                        pronounceMethodSection(),
                      ],
                    );
                  }
                }),
          ]
      ),
    );
  }

  Widget practiceSectionText(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipPath(
            clipper: ProfileImageClipper(),
            child: Container(
              width: 20,
              height: 21,
              child: Image.network("${_authManager.getPhoto()}"),
            )

        ),
        const SizedBox(width: 9,),
        Text(
          "현재 ${_authManager.getName()}님의 발음이에요.",
          style: TextStyles.medium00BoldTextStyle,
        )

      ],
    );
  }

  Widget recordingStart(){
    return GestureDetector(
      onTap: () async {
        await startRecording();
        setState(() {
          recordingState = 2;
        });
      },
      child: Container(
          margin: const EdgeInsets.only(top: 8),
          height: 64,
          decoration: BoxDecoration(
            color: ColorStyles.saeraOlive1,
            borderRadius: BorderRadius.circular(16), //border radius exactly to ClipRRect
          ),
          child: const Center(
            child: Text(
              "여기를 눌러 녹음을 시작하세요.",
              style: TextStyles.mediumWhiteTextStyle,
            ),
          )
      ),
    );
  }

  Widget recordingWidget(){
    return GestureDetector(
      onTap: () async {
        await stopRecording();

        setState(() {
          _isRecording = true;
          completePractice();

          recordingState = 3;
        });
      },
      child: Container(
          margin: const EdgeInsets.only(top: 8),
          height: 64,
          decoration: BoxDecoration(
            color: ColorStyles.saeraOlive2,
            borderRadius: BorderRadius.circular(16), //border radius exactly to ClipRRect
          ),
          child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.black,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "녹음 중이에요...\n여기를 다시 눌러 녹음을 완료할 수 있어요.",
                    style: TextStyles.small25TextStyle,
                    textAlign: TextAlign.start,
                  )
                ],
              )
          )
      ),
    );
  }

  Widget recordingCompleteWidget(){
    return GestureDetector(
      onTap: () async {
        await stopRecording();
        setState(() {
          _isRecording = false;
          recordingState = 1;
        });
      },
      child: Container(
          margin: const EdgeInsets.only(top: 8),
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), //border radius exactly to ClipRRect
            boxShadow:[
              BoxShadow(
                color: ColorStyles.saeraOlive1.withOpacity(0.2),
                //spreadRadius: 0.1,
                blurRadius: 16,
                offset: const Offset(0, 8), // changes position of shadow
              ),
            ],
          ),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text(
                      "학습 완료! 다시 녹음하려면 여기를 누르세요.",
                      style: TextStyles.mediumRecordTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )
          )
      ),
    );
  }

  Widget infoSection(){
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: const Text(
        "단어 학습은 억양 그래프와 점수를 제공하지 않습니다.\n목표로 하는 발음이 나올 때까지 자유롭게 연습해 보세요!",
        textAlign: TextAlign.center,
        style: TextStyles.small82400TextStyle,
      ),
    );
  }

  Widget before_audio_bar() {
    return Container(
      margin: const EdgeInsets.only(left: 2.0, right: 16.0, top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              //
            },
            icon: SvgPicture.asset('assets/icons/play_pronounce.svg',
                fit: BoxFit.scaleDown
            ),
            iconSize: 32,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 5.0),
                child: Text(formatTime(Duration.zero),
                  style: TextStyles.small66TextStyle,
                ),
              ),
              SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                    trackHeight: 5.0,
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 5.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 200,
                    child: Slider(
                      min: 0,
                      max: 0,
                      value: 0,
                      activeColor: ColorStyles.primary.withOpacity(0.4),
                      inactiveColor: Color(0xffE7E7E7),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                      },
                    ),
                  )
              ),
              Container(
                margin: EdgeInsets.only(left: 5.0),
                child: Text(formatTime(Duration.zero),
                  style: TextStyles.small66TextStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget practiceSection(){
    return Container(
      margin: const EdgeInsets.only(top:28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          practiceSectionText(),
              (){
            if(!_isRecording){
              return before_audio_bar();
            }
            else{
              return AudioBar(recordPath: recordingPath, isRecording: true, isAccent: false);
            }
          }(),
              (){
            if(recordingState == 1){
              return recordingStart();
            }
            else if(recordingState == 2){
              return recordingWidget();
            }
            return recordingCompleteWidget();
          }(),
          infoSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Stack(
      children: [
        Container(
          color: Colors.white,
        ),
        SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: appBarSection(),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: ListView(
                    //physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // appBarSection(),
                      Container(
                        margin: const EdgeInsets.only(left: 14, right: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            (){
                              if(widget.isTodayLearn){
                                if(_isPracticed == true){
                                  return todayTopBarSection(_isPracticed);
                                }
                                else{
                                  return todayTopBarSection(_isPracticed);
                                }
                              }
                              else{
                                if(_isPracticed){
                                  return topBarSection(_isPracticed);
                                }
                                else{
                                  return topBarSection(_isPracticed);
                                }
                              }
                            }(),
                            practiceSentenceSection(),
                            exampleSection(),
                            practiceSection(),
                          ],
                        ),
                      )
                    ]
                )
            )
        )

      ],
    );
  }
}
