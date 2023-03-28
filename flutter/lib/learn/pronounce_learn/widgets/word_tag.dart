import 'package:flutter/cupertino.dart';

String WordTip(int idx){
  //구개음화
  if(idx == 10){
    return "‘ㄷ’, ‘ㅌ’ 뒤에 ‘ㅣ’가 올 때 ‘ㅈ’, ‘ㅊ’로 발음하도록 신경써야\n 합니다.";
  }
  //두음법칙
  else if(idx == 11){
    return "단어 말머리의 ‘ㄴ’, ‘ㄹ’이 다른 소리로 바뀝니다.";
  }
  //치조마찰음화
  else if(idx == 12){
    return "‘ㅅ’와 ‘ㅆ’의 올바른 발음을 연습합니다.";
  }
  //ㄴ첨가
  else if(idx == 13){
    return "두 단어가 합쳐진 단어에서 ‘ㄴ’을 추가해 발음하도록\n신경써야 합니다.";
  }
  //ㄹ첨가
  else if(idx == 14){
    return "받침 'ㄹ'뒤에 '이,야,여,요,유'가 오는 경우, 'ㄹ'을 첨가하여 \n발음해야 합니다.";
  }
  // 여=>애
  else if(idx == 15){
    return "'ㅕ' 발음을 'ㅐ' 처럼 발음하지 않도록 신경써야 합니다.";
  }
  //단모음화
  else if(idx == 16){
    return "이중모음을 단모음처럼 발음하지 않도록 신경써야 합니다.";
  }
  //으=>우
  else if(idx == 17){
    return "'ㅡ' 발음을 'ㅜ' 처럼 발음하지 않도록 신경써야 합니다.";
  }
  //어=>오
  else if(idx == 18){
    return "‘ㅓ' 발음을 ‘ㅗ' 처럼 발음하지 않도록 신경써야 합니다.";
  }
  //오=>어
  else if(idx == 19){
    return "‘ㅗ' 발음을 ‘ㅓ' 처럼 발음하지 않도록 신경써야 합니다.";
  }
  //모음조화
  else if(idx == 20){
    return "뒤 음절의 모음이 앞 음절 모음의 영향을 받아 아주 같거나\n그에 가까운 성질의 모음이 어울리는 현상입니다";
  }
  return "\n";
}