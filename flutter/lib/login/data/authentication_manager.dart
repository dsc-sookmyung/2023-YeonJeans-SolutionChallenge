import 'package:get/get.dart';
import 'cache_manager.dart';

class AuthenticationManager extends GetxController with CacheManager {
  final isLogged = false.obs;

  void logOut() {
    isLogged.value = false;
    removeToken();
    removeRefreshToken();
  }

  void login(String? token, String? refreshToken) async {
    isLogged.value = true;
    //Token is cached
    await saveToken(token);
    await saveRefreshToken(refreshToken);
  }

  void checkLoginStatus() {
    final token = getToken();
    if (token != null) {
      isLogged.value = true;
    }
  }
}