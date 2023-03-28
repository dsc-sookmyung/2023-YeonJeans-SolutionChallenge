import 'package:get/get.dart';

class LineController extends GetxController {
  Rx<double> duration = 2.0.obs;
  Rx<double> position = 0.0.obs;

  Rx<double> rduration = 2.0.obs;
  Rx<double> rposition = 0.0.obs;

  void setting(double dur) {
    duration.value = dur;
  }

  void positionChanged(double pos){
    position.value = pos;
  }

  double getDuration(){
    return duration.value;
  }

  double getPosition(){
    return position.value;
  }

  void rsetting(double dur) {
    rduration.value = dur;
  }

  void rpositionChanged(double pos){
    rposition.value = pos;
  }

  double rgetDuration(){
    return rduration.value;
  }

  double rgetPosition(){
    return rposition.value;
  }
}