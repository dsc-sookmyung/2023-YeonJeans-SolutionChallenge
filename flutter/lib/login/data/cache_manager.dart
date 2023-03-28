import 'package:get_storage/get_storage.dart';

mixin CacheManager {
  Future<bool> saveToken(String? token) async {
    final box = GetStorage();
    await box.write(CacheManagerKey.TOKEN.toString(), token);
    return true;
  }

  Future<bool> saveRefreshToken(String? token) async {
    final box = GetStorage();
    await box.write(CacheManagerKey.REFRESHTOKEN.toString(), token);
    return true;
  }

  Future<bool> saveName(String? name) async {
    final box = GetStorage();
    await box.write(CacheManagerKey.NAME.toString(), name);
    return true;
  }

  Future<bool> saveEmail(String? email) async {
    final box = GetStorage();
    await box.write(CacheManagerKey.EMAIL.toString(), email);
    return true;
  }

  Future<bool> savePhoto(String? photo) async {
    final box = GetStorage();
    await box.write(CacheManagerKey.PHOTO.toString(), photo);
    return true;
  }

  Future<bool> saveTodayWordIdx(int? idx) async {
    final box = GetStorage();
    await box.write(CacheManagerKey.TODAYWORDIDX.toString(), idx);
    return true;
  }

  Future<bool> saveTodayStatementIdx(int? idx) async {
    final box = GetStorage();
    await box.write(CacheManagerKey.TODAYSTATEMENTIDX.toString(), idx);
    return true;
  }

  String? getToken() {
    final box = GetStorage();
    return box.read(CacheManagerKey.TOKEN.toString());
  }

  String? getRefreshToken() {
    final box = GetStorage();
    return box.read(CacheManagerKey.REFRESHTOKEN.toString());
  }

  String? getName() {
    final box = GetStorage();
    return box.read(CacheManagerKey.NAME.toString());
  }

  String? getEmail() {
    final box = GetStorage();
    return box.read(CacheManagerKey.EMAIL.toString());
  }

  String? getPhoto() {
    final box = GetStorage();
    return box.read(CacheManagerKey.PHOTO.toString());
  }

  int? getTodayWordIdx() {
    final box = GetStorage();
    return box.read(CacheManagerKey.TODAYWORDIDX.toString());
  }

  int? getTodayStatementIdx() {
    final box = GetStorage();
    return box.read(CacheManagerKey.TODAYSTATEMENTIDX.toString());
  }

  Future<void> removeToken() async {
    final box = GetStorage();
    await box.remove(CacheManagerKey.TOKEN.toString());
  }

  Future<void> removeRefreshToken() async {
    final box = GetStorage();
    await box.remove(CacheManagerKey.REFRESHTOKEN.toString());
  }
}

enum CacheManagerKey {
  TOKEN,
  REFRESHTOKEN,
  NAME,
  EMAIL,
  PHOTO,
  TODAYWORDIDX,
  TODAYSTATEMENTIDX
}