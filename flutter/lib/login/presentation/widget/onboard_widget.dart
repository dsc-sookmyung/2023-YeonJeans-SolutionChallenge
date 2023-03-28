import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:saera/login/presentation/login_screen.dart';

import '../../../tabbar.dart';
import '../../data/authentication_manager.dart';

class OnBoard extends StatelessWidget {
  const OnBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthenticationManager _authManager = Get.find();

    return Obx(() {
      return _authManager.isLogged.value ? TabBarMainPage() : LoginPage();
    });
  }
}