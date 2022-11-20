import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utilities {
  Utilities._();

  static doubleBack(BuildContext context) {
    Utilities.closeActivity(context);
    Utilities.closeActivity(context);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static double screenWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth;
  }

  static double screenHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return screenHeight;
  }

  static getSnackBar({required BuildContext context, required SnackBar snackBar}) {
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<dynamic> openActivity(context, object, {bool fullscreenDialog = false}) async {
    return await Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: fullscreenDialog,
        transitionDuration: const Duration(milliseconds: 50),
        reverseTransitionDuration: const Duration(milliseconds: 50),
        pageBuilder: (BuildContext context, _, __) {
          return object;
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static Future<dynamic> fadeOpenActivity(context, object) async {
    return await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 50),
        reverseTransitionDuration: const Duration(milliseconds: 50),
        pageBuilder: (BuildContext context, _, __) {
          return object;
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static Future<dynamic> fadeReplaceActivity(context, object) async {
    return await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 50),
        reverseTransitionDuration: const Duration(milliseconds: 50),
        pageBuilder: (BuildContext context, _, __) {
          return object;
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static Future<dynamic> replaceActivity(context, object) async {
    return await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 50),
        reverseTransitionDuration: const Duration(milliseconds: 50),
        pageBuilder: (BuildContext context, _, __) {
          return object;
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static void unfocus(context) {
    return FocusScope.of(context).unfocus();
  }

  static Future<dynamic> replaceNamedActivity(context, routeName, {Object? arguments}) async {
    return await Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static Future<dynamic> openNamedActivity(context, routeName, {Object? arguments}) async {
    return await Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void removeStackActivity(context, object) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => object), (r) => false);
  }

  static void removeNamedStackActivity(context, routeName, {Object? arguments}) {
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false, arguments: arguments);
  }

  static void closeActivity(context) {
    Navigator.pop(context);
  }

  static void returnDataCloseActivity(context, object) {
    Navigator.pop(context, object);
  }

  static String encodeJson(dynamic jsonData) {
    return json.encode(jsonData);
  }

  static dynamic decodeJson(String jsonString) {
    return json.decode(jsonString);
  }

  static bool isIOS() {
    return Platform.isIOS;
  }

  static fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // Shared Pref data
  static Future<bool?> getSessionStatus() async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getBool('sessionStatus') ?? false;
  }

  static setSessionStatus({required bool sessionStatus}) async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setBool('sessionStatus', sessionStatus);
  }

  static setIsConnected(bool isConnected) async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setBool('isConnected', isConnected);
  }

  static getIsConnected() async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getBool('isConnected');
  }

  static setAccessToken({String? accessToken}) async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setString('accessToken', accessToken ?? "");
  }

  static getAccessToken() async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString('accessToken');
  }

  static setSessionToken({String? sessionToken}) async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setString('sessionToken', sessionToken ?? "");
  }

  static getSessionToken() async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString('sessionToken');
  }

  static setUserId(String userId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("userId", userId);
  }

  static getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("userId");
  }

  static setUserName(String name) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("name", name);
  }

  static getUserName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("name");
  }
}
