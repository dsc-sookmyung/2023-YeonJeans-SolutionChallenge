import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:saera/learn/accent_learn/data/line_controller.dart';
import 'package:saera/login/data/user_info_controller.dart';

import 'login/data/authentication_manager.dart';
import 'login/presentation/login_screen.dart';
import 'login/presentation/widget/onboard_widget.dart';

void main() async {

  await GetStorage.init();
  runApp(
    const GetMaterialApp(
      title: 'saera',
      home: SplashScreen(),
    )
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final AuthenticationManager _authmanager = Get.put(AuthenticationManager());
  final LineController _lineController = Get.put(LineController());
  final UserInfoController _userController = Get.put(UserInfoController());

  Future<void> initializeSettings() async {
    _authmanager.checkLoginStatus();

    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return FutureBuilder(
      future: initializeSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitingView();
        }
        else {
          if (snapshot.hasError) {
            return errorView(snapshot);
          }
          else {
            return OnBoard();
          }
        }
      },
    );
  }

  Scaffold errorView(AsyncSnapshot<Object?> snapshot) {
    return Scaffold(
        body: Center(child: Text('Error: ${snapshot.error}')));
  }

  Scaffold waitingView() {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SvgPicture.asset(
              'assets/images/saera_splash.svg',
              alignment: Alignment.center,
              fit: BoxFit.cover,
              //width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height,
            ),
            Container(
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/saera_title.svg',
                  alignment: Alignment.center,
                ),
              ),
            )
          ],
        )
    );
  }

}