import 'package:get/get.dart';

class UserInfoController extends GetxController {
  Rx<int> exp = 0.obs;

  void saveExp(int ex){
    exp.value = ex;
  }

  int getExp(){
    return exp.value;
  }
}