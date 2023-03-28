import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:saera/login/data/login_platform.dart';
import 'package:saera/login/data/user_info_controller.dart';
import 'package:saera/server.dart';
import 'package:saera/style/font.dart';
import 'package:saera/tabbar.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../style/color.dart';
import '../data/authentication_manager.dart';
import 'package:http/http.dart' as http;


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthenticationManager _authManager;
  LoginPlatform _loginPlatform = LoginPlatform.none;

  final UserInfoController _userController = Get.find();

  Future<dynamic> getToken(String ?serverAuthCode) async {

    var url = Uri.parse('$serverHttp/auth/google/callback?code=$serverAuthCode');

    final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json"});

    if (response.statusCode == 200) {

      var body = jsonDecode(utf8.decode(response.bodyBytes));

      String accessToken = body["accessToken"];
      String refreshToken = body["refreshToken"];

      _authManager.login(accessToken, refreshToken);
      return true;
    }
    else{
      return false;
    }
  }

  @override
  void initState(){
    super.initState();
    _authManager = Get.find();
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

      Get.offAll(() => TabBarMainPage());

    }
    else{
      print(jsonDecode(utf8.decode(response.bodyBytes)));
    }
  }

  void signInWithGoogle() async {
    if(Platform.isAndroid){
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
          serverClientId: serverClientId
      ).signIn();

      if (googleUser != null) {
        _authManager.saveEmail(googleUser.email);
        _authManager.saveName(googleUser.displayName);
        _authManager.savePhoto(googleUser.photoUrl);
        getToken(googleUser.serverAuthCode);

        setState(() {
          _loginPlatform = LoginPlatform.google;
        });

        getUserExp();
      }
    }
    else{
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
          clientId: googleClientId,
          serverClientId: serverClientId
      ).signIn();

      if (googleUser != null) {
        _authManager.saveEmail(googleUser.email);
        _authManager.saveName(googleUser.displayName);
        _authManager.savePhoto(googleUser.photoUrl);
        getToken(googleUser.serverAuthCode);

        setState(() {
          _loginPlatform = LoginPlatform.google;
        });

        Get.offAll(() => TabBarMainPage());

      }
    }

  }

  Widget googleLoginBtn (){
    return GestureDetector(
      onTap: () {
        signInWithGoogle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: ColorStyles.saeraWhite,
          borderRadius: BorderRadius.circular(2), //border radius exactly to ClipRRect
          boxShadow:[
            BoxShadow(
              color: const Color(0xff000000).withOpacity(0.3),
              spreadRadius: 0.2,
              blurRadius: 8,
              offset: const Offset(2, 4), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Container(
              child: Image(
                image: AssetImage('assets/icons/google_logo.png'),
                width: 18,
                height: 18,
              ),
            ),
            // Image(
            //   image: AssetImage('assets/icons/google_logo.png'),
            //   width: 18,
            //   height: 18,
            // ),
            SizedBox(width: 24,),
            Text(
              "Google 계정으로 로그인",
              style: TextStyles.medium25400TextStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget appleLoginBtn (){
    return GestureDetector(
      onTap: () => Get.to(() => TabBarMainPage()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(2), //border radius exactly to ClipRRect
          boxShadow:[
            BoxShadow(
              color: const Color(0xff663e68a8).withOpacity(0.3),
              spreadRadius: 0.2,
              blurRadius: 8,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Image(
              image: AssetImage('assets/icons/google_logo.png'),
              width: 18,
              height: 18,
            ),
            SizedBox(width: 24,),
            Text(
              "Apple로 로그인",
              style: TextStyles.medium25TextStyle,
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              SvgPicture.asset(
                'assets/images/saera_splash.svg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                // width: MediaQuery.of(context).size.width,
              ),
              Container(
                // width: MediaQuery.of(context).size.width,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/saera_title.svg',
                    alignment: Alignment.center,
                  ),
                ),
              ),

              Container(
                  padding: const EdgeInsets.only(left: 21, right: 21, bottom: 180),
                  child: Column(
                    children: [
                      const Spacer(),
                      googleLoginBtn(),
                      // appleLoginBtn()
                    ],
                  )
              ),
            ],
          )
        ],
      )
    );
  }
}
