import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:saera/style/font.dart';
import 'dart:convert';

import '../../server.dart';
import '../presentation/login_screen.dart';
import 'authentication_manager.dart';


bool check = false;

Future<void> RefreshToken(BuildContext context) async {
  final AuthenticationManager _authManager = Get.find();

  var url = Uri.parse('$serverHttp/reissue-token');

  final response = await http.get(url, headers: {'accept': 'application/json', "content-type": "application/json", "RefreshToken" : "Bearer ${_authManager.getRefreshToken()}" });

  if (response.statusCode == 200) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${jsonDecode(utf8.decode(response.bodyBytes))}');

    var body = jsonDecode(response.body);

    _authManager.saveToken(body["accessToken"]);
    _authManager.saveRefreshToken(body["refreshToken"]);
  }
  else if(response.statusCode == 401){
    if(context.mounted){
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            '로그인 만료',
            style: TextStyles.large00TextStyle,
          ),
          content: const Text('로그인 유효 시간이 만료되었습니다. 다시 로그인해 주세요.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text(
                  '로그인하기',
              ),
            ),
          ],
        ),
      );
    }
  }
  else {
    print(response.reasonPhrase);

  }

}