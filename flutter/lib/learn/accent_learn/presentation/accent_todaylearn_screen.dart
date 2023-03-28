import 'dart:io';
import 'dart:io' show Platform;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saera/learn/accent_learn/presentation/widgets/accent_learn_background_image.dart';
import 'package:saera/learn/accent_learn/presentation/widgets/accent_line_chart.dart';
import 'package:saera/learn/accent_learn/presentation/widgets/audio_bar.dart';
import 'package:saera/login/data/refresh_token.dart';
import 'package:saera/style/color.dart';
import 'package:saera/style/font.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:saera/server.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../login/data/authentication_manager.dart';
import '../../../login/data/user_info_controller.dart';
import '../../../login/presentation/widget/profile_image_clipper.dart';
import 'today_learn_statement_list.dart';


class AccentTodayPracticePage extends StatefulWidget {

  final int idx;
  final List<int> sentenceList;

  const AccentTodayPracticePage({Key? key, required this.idx, required this.sentenceList}) : super(key: key);

  @override
  State<AccentTodayPracticePage> createState() => _AccentTodayPracticePageState();
}

class _AccentTodayPracticePageState extends State<AccentTodayPracticePage> with TickerProviderStateMixin {
  final AuthenticationManager _authManager = Get.find();
  final UserInfoController _userController = Get.find();

  late FToast fToast;

  String content = "";
  String userName = "";

  double accuracyRate = 0;
  int recordingState = 1;


  bool _isBookmarked = false;
  bool _isRecording = false;
  bool _isPracticed = false;
  late Future <dynamic> _isAudioReady;

  AudioPlayer audioPlayer = AudioPlayer();

  // String audioPath = "mp3/ex.wav";
  String audioPath = "";
  String recordingPath = "";
  String _fileName = "record.wav";

  final _recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  late List<double> x = [];
  late List<double> y = [];

  late List<double> x2 = [];
  late List<double> y2 = [];

  showCustomToast() {
    Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: ColorStyles.black00.withOpacity(0.6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "음성 인식에 실패했습니다.\n목소리가 잘 들리도록 다시 녹음해 주세요!",
              style: TextStyles.smallFFTextStyle,
            ),

            IconButton(
                onPressed: (){
                  fToast.removeCustomToast();
                },
                icon: SvgPicture.asset(
                  'assets/icons/close_toast.svg',
                  fit: BoxFit.scaleDown,
                )
            )
          ],
        )
    );

    fToast.showToast(
      child: toast,
      toastDuration: const Duration(seconds: 3),
    );
  }

  Widget activeNextBtn(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: ColorStyles.saeraRed
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: const Text(
        "다음",
        style: TextStyles.regularRedTextStyle,
      ),

    );
  }

  Widget completeBtn(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: ColorStyles.saeraRed
        ),
        color: ColorStyles.saeraRed,
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

  Widget todayTopBarSection(bool isRecord){
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                (){
              if(widget.idx != 0){
                return GestureDetector(
                  onTap: () async {
                    if(widget.idx - 1 >= 0){
                      if(context.mounted) Navigator.of(context).pop();
                      //await Future.delayed(const Duration(seconds: 1));
                      if (!mounted) return;
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccentTodayPracticePage(idx: (widget.idx - 1), sentenceList: widget.sentenceList)));


                      // Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => AccentTodayPracticePage(idx: (widget.idx -1), sentenceList: widget.sentenceList)),
                      // );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: ColorStyles.saeraRed
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
                      style: TextStyles.regularRedTextStyle,
                    ),

                  ),
                );
              }
              else{
                return const Spacer();
              }
            }(),

            GestureDetector(
                onTap: () async {
                  if((_isPracticed || _authManager.getTodayStatementIdx()! > widget.idx ) && widget.idx + 1 != 5){

                    if(_authManager.getTodayStatementIdx()! < widget.idx +1){
                      _authManager.saveTodayStatementIdx(widget.idx + 1);
                    }

                    if(context.mounted) Navigator.of(context).pop();
                    //await Future.delayed(const Duration(seconds: 1));
                    if (!mounted) return;
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccentTodayPracticePage(idx: (widget.idx + 1), sentenceList: widget.sentenceList)));


                    // Navigator.pop(context);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => AccentTodayPracticePage(idx: (widget.idx + 1), sentenceList: widget.sentenceList)),
                    // );
                  }
                  else if((_isPracticed || _authManager.getTodayStatementIdx()! > widget.idx ) && widget.idx + 1 == 5){
                    //TODO 학습 결과 리스트를 보여주는 페이지로 페이지 전환
                    _authManager.saveTodayStatementIdx(widget.idx + 1);
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => TodayLearnStatementListPage(sentenceList: widget.sentenceList,),
                    ));
                  }
                },
                child: (){
                  if((_isPracticed || _authManager.getTodayStatementIdx()! > widget.idx) && widget.idx + 1 == 5){
                    return completeBtn();
                  }
                  else if(widget.idx + 1 == 5){
                    return unActiveCompleteBtn();
                  }
                  else if(_isPracticed || _authManager.getTodayStatementIdx()! > widget.idx ){
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
                    return Image.asset('assets/icons/firsts_progress.png');
                  }
                  else if(widget.idx == 1){
                    return Image.asset('assets/icons/seconds_progress.png');
                  }
                  else if(widget.idx == 2){
                    return Image.asset('assets/icons/thirds_progress.png');
                  }
                  else if(widget.idx == 3){
                    return Image.asset('assets/icons/fourths_progress.png');
                  }
                  else {
                    return Image.asset('assets/icons/fifths_progress.png');
                  }

                }()
            )
        )
      ],
    );
  }

  getExampleAccent() async {

    var url = Uri.parse('${serverHttp}/statements/${widget.sentenceList[widget.idx]}');
    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}" });
    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));

      x.clear();
      y.clear();

      setState(() {
        content = body["content"];
        _isBookmarked = body["bookmarked"];
      });

      for(int i in body["pitch_x"]){
        double pitch  = i.toDouble();
        x.add(pitch);
      }

      y = List.from(body["pitch_y"]);

    }
    else if(response.statusCode == 401){
      String? before = _authManager.getToken();
      await RefreshToken(context);

      if(before != _authManager.getToken()){
        getExampleAccent();
      }
    }
    else{
      print(response.body);
    }
  }



  Future<dynamic> getTTS() async {

    var url = Uri.parse('${serverHttp}/statements/record/${widget.sentenceList[widget.idx]}');

    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "audio/wav", "authorization" : "Bearer ${_authManager.getToken()}"});

    if (response.statusCode == 200) {

      Uint8List audioInUnit8List = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();

      File file = await File('${tempDir.path}/exampleAudio${widget.sentenceList[widget.idx]}.wav').create();
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

    var url = Uri.parse('${serverHttp}/bookmark?type=STATEMENT&fk=${widget.sentenceList[widget.idx]}');


    final response = await http.post(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}", "RefreshToken" : "Bearer ${_authManager.getRefreshToken()}" });

    if (response.statusCode == 200) {
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
    }
  }

  void deleteBookmark () async {
    var url = Uri.parse('${serverHttp}/bookmark?type=STATEMENT&fk=${widget.sentenceList[widget.idx]}');

    final response = await http.delete(url, headers: {'accept': 'application/json', "content-type": "application/json", "authorization" : "Bearer ${_authManager.getToken()}", "RefreshToken" : "Bearer ${_authManager.getRefreshToken()}" });

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
      });

      _userController.saveExp(xp);

    }
    else{
      print(jsonDecode(utf8.decode(response.bodyBytes)));
    }
  }

  getAccentEvaluation() async {
    var url = Uri.parse('${serverHttp}/practice?type=STATEMENT&fk=${widget.sentenceList[widget.idx].toString()}&isTodayStudy=true');
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({'accept': 'application/json', "content-type": "multipart/form-data" , "authorization" : "Bearer ${_authManager.getToken()}"});

    request.files.add(await http.MultipartFile.fromPath('record', recordingPath));

    var responsed = await request.send();
    var response = await http.Response.fromStream(responsed);

    if (responsed.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        _isPracticed = true;
        recordingState = 4;
        accuracyRate = body["score"];
      });

      x2.clear();
      y2.clear();

      for(int i in body["pitch_x"]){
        double pitch  = i.toDouble();
        x2.add(pitch);
      }

      y2 = List.from(body["pitch_y"]);

      if (!mounted) return;

      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          contentPadding: EdgeInsets.only(left: 24.0, right: 24.0, top: 12.0, bottom: 4.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))
          ),
          title: Text("억양 등급",
            style: TextStyles.large25TextStyle,
            textAlign: TextAlign.center,
          ),
          content:  Container(
            child: expSection(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '확인',
                style: TextStyles.medium25400TextStyle,
              ),
            ),
          ],
        ),
      );
      getUserExp();

      return true;
    }
    else{
      showCustomToast();
      setState(() {
        recordingState = 1;
        _isRecording = false;
      });
    }
  }

  String accuracyComment(double score){
    if (score > 5 ) {
      return "조금 더 노력해 봅시다!";
    }
    else if(score > 3 && score <= 5) {
      return "거의 완벽했어요!";
    }
    else{
      return "완벽합니다!!";
    }
  }

  Widget accuracyRank(double score){
    if (score > 5 ) {
      return const Text(
        "B ",
        style: TextStyles.mediumBTextStyle,
      );
    }
    else if(score > 3 && score <= 5) {
      return const Text(
        "A ",
        style: TextStyles.mediumATextStyle,
      );
    }
    else{
      return const Text(
        "S ",
        style: TextStyles.mediumSTextStyle,
      );
    }
  }

  Widget rankIcon(double score){
    if (score > 5 ) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/flower.svg',
            color: ColorStyles.saeraYellow2,
            fit: BoxFit.scaleDown,
          ),
          const Text(
            "B",
            style: TextStyles.largeWhiteTextStyle,
          )
        ],
      );
    }
    else if(score > 3 && score <= 5) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/flower.svg',
            color: ColorStyles.saeraPink,
            fit: BoxFit.scaleDown,
          ),
          const Text(
            "A",
            style: TextStyles.largeWhiteTextStyle,
          )
        ],
      );
    }
    else if(score == 0){
      return Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/flower.svg',
            color: ColorStyles.searchFillGray,
            fit: BoxFit.scaleDown,
          ),
        ],
      );
    }
    else{
      return Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/flower.svg',
            color: ColorStyles.saeraRed,
            fit: BoxFit.scaleDown,
          ),
          const Text(
            "S",
            style: TextStyles.largeWhiteTextStyle,
          )
        ],
      );
    }
  }


  @override
  void initState(){
    if(_authManager.getTodayStatementIdx() == null){
      _authManager.saveTodayStatementIdx(0);
    }
    initRecorder();
    getExampleAccent();
    _isAudioReady = getTTS();
    fToast = FToast();
    fToast.init(context);

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
          final tempDir = await getTemporaryDirectory();
          Directory appFolder = Directory("${tempDir.path}/saera");
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
      final tempDir = await getTemporaryDirectory();
      await _recorder.startRecorder(toFile: '${tempDir.path}/saera/practiceAudio.wav');
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
      final tempDir = await getTemporaryDirectory();
      recordingPath = '${tempDir.path}/saera/practiceAudio.wav';
    }
  }


  Widget appBarSection (){
    return Container(
      //padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton.icon(
              onPressed: (){
                Navigator.pop(context);
              },
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
                  createBookmark(widget.sentenceList[widget.idx]);
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
      padding: const EdgeInsets.only(top:20.0, bottom: 20.0),
      decoration: BoxDecoration(
          color: ColorStyles.searchFillGray,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Text(
          content,
          style: TextStyles.large33TextStyle,
        ),
      ),
    );
  }

  Widget exampleSectionText(){
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/flag.svg',
          color: ColorStyles.saeraRed,
        ),
        const SizedBox(width: 9,),
        const Text(
          "이 억양을 목표로 연습해 볼까요?",
          style: TextStyles.medium00BoldTextStyle,
        )

      ],
    );
  }

  Widget exampleGraph(){
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 135,
      decoration: BoxDecoration(
        color: ColorStyles.saeraWhite,
        borderRadius: BorderRadius.circular(16), //border radius exactly to ClipRRect
        boxShadow:[
          BoxShadow(
            color: ColorStyles.black00.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8), // changes position of shadow
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(25),
        child: FutureBuilder(
            future: _isAudioReady,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      )]
                );
              }
              else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }
              else {
                return AccentLineChart(x: x, y: y, isRecord: false);
              }
            }),
      ),
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
                  //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미
                  if (snapshot.hasData == false) {
                    // return CircularProgressIndicator();
                    return Column(
                      children: [
                        before_audio_bar(),

                      ],
                    );
                  }
                  //error가 발생하게 될 경우 반환하게 되는 부분
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
                    return AudioBar(recordPath: audioPath, isRecording: false, isAccent: true);
                  }
                }),

            exampleGraph(),
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
          "현재 ${_authManager.getName()}님의 억양이에요.",
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
          height: 135,
          decoration: BoxDecoration(
            color: ColorStyles.saeraRed,
            borderRadius: BorderRadius.circular(16), //border radius exactly to ClipRRect
            boxShadow:[
              BoxShadow(
                color: ColorStyles.saeraRed.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8), // changes position of shadow
              ),
            ],
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
        getAccentEvaluation();

        setState(() {
          _isRecording = true;
          // _isPracticed = true;
          recordingState = 3;
        });
      },
      child: Container(
          margin: const EdgeInsets.only(top: 8),
          height: 135,
          decoration: BoxDecoration(
            color: ColorStyles.saeraPink,
            borderRadius: BorderRadius.circular(16), //border radius exactly to ClipRRect
            boxShadow:[
              BoxShadow(
                color: ColorStyles.saeraPink.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8), // changes position of shadow
              ),
            ],
          ),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.black,
                    size: 30,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top:11),
                    child: const Text(
                      "녹음 중이에요...\n여기를 다시 눌러 녹음을 완료할 수 있어요.",
                      style: TextStyles.small25TextStyle,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )
          )
      ),
    );
  }

  Widget analysisAccent(){
    return GestureDetector(
      onTap: (){
        // setState(() {
        //
        // });
      },
      child: Container(
          margin: const EdgeInsets.only(top: 8),
          height: 135,
          decoration: BoxDecoration(
            color: ColorStyles.saeraPink2,
            borderRadius: BorderRadius.circular(16), //border radius exactly to ClipRRect
            boxShadow:[
              BoxShadow(
                color: ColorStyles.saeraPink2.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8), // changes position of shadow
              ),
            ],
          ),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                      'assets/icons/headphones.svg',
                      fit: BoxFit.scaleDown
                  ),
                  Container(
                    margin: const EdgeInsets.only(top:15),
                    child: const Text(
                      "억양을 분석하고 있습니다...\n거의 다 되었어요!",
                      style: TextStyles.small25TextStyle,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )
          )
      ),
    );
  }

  Widget practiceGraph(){
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 135,
          decoration: BoxDecoration(
            color: ColorStyles.saeraWhite,
            borderRadius: BorderRadius.circular(16), //border radius exactly to ClipRRect
            boxShadow:[
              BoxShadow(
                color: ColorStyles.saeraRed.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8), // changes position of shadow
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            child: AccentLineChart(x: x2, y: y2, isRecord: true),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 18, right: 3),
              child: IconButton(
                  onPressed: (){
                    setState(() {
                      recordingState = 1;
                      _isRecording = false;
                      accuracyRate = 0;
                    });
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/refresh.svg',
                    fit: BoxFit.scaleDown,
                  )
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget expSection() {
    return Container(
        margin: const EdgeInsets.only(top: 8),
        height: 56,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Container(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      const Text("정확도 ",
                        style: TextStyles.medium25TextStyle,
                      ),
                      accuracyRank(accuracyRate),
                      const Text(
                        " | ",
                        style: TextStyles.mediumEFTextStyle,
                      ),
                      Text(
                        accuracyComment(accuracyRate),
                        style: TextStyles.medium25TextStyle,
                      )
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    child: const Text("학습 완료 경험치 +100xp",
                      style: TextStyles.small99TextStyle,
                    ),
                  )


                ],
              ),
            ),

            Container(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 8,),
                  rankIcon(accuracyRate),
                  // const SizedBox(
                  //   width: 16,
                  // )
                ],
              ),
            )
          ],
        )
    );
  }

  Widget expInitSection() {
    return Container(
        margin: const EdgeInsets.only(top: 13, bottom: 25),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        height: 80,
        decoration: BoxDecoration(
          color: ColorStyles.saeraWhite,
          borderRadius: BorderRadius.circular(8), //border radius exactly to ClipRRect
          boxShadow:[
            BoxShadow(
              color: ColorStyles.saeraRed.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("녹음을 완료하면\n$userName님의 억양 정확도를 알 수 있어요.",
                  style: TextStyles.regular99TextStyle,
                ),
              ],
            ),

            Row(
              children: [
                rankIcon(accuracyRate),
                const SizedBox(
                  width: 16,
                )
              ],
            )
          ],
        )
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
            icon: SvgPicture.asset('assets/icons/play.svg',
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
      margin: const EdgeInsets.only(top:31),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          practiceSectionText(),
              (){
            if(!_isRecording){
              return before_audio_bar();
            }
            else{
              return AudioBar(recordPath: recordingPath, isRecording: true, isAccent: true);
            }
          }(),
              (){
            if(recordingState == 1){
              return recordingStart();
            }
            else if(recordingState == 2){
              return recordingWidget();
            }
            else if(recordingState == 3){
              return analysisAccent();
            }
            return practiceGraph();
          }(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Stack(
      children: [
        SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: appBarSection(),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: false,
                body: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 14, right: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            (){
                              if(_isPracticed == true){
                                return todayTopBarSection(_isPracticed);
                              }
                              else{
                                return todayTopBarSection(_isPracticed);
                              }
                            }(),
                            practiceSentenceSection(),
                            exampleSection(),
                            practiceSection(),
                            SizedBox(height: 20,),
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
