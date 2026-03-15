import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../main.dart';
import 'login_screen.dart';
import '../user_session.dart';

class CheckLoginScreen extends StatefulWidget {
  const CheckLoginScreen({super.key});

  @override
  State<CheckLoginScreen> createState() => _CheckLoginScreenState();
}

class _CheckLoginScreenState extends State<CheckLoginScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    bool isLogin = prefs.getBool("isLogin") ?? false;

    if (isLogin) {
      String userString = prefs.getString("user") ?? "";
      String token = prefs.getString("token") ?? "";

      if (userString.isNotEmpty) {
        UserSession.user = jsonDecode(userString);
      }

      if (token.isNotEmpty) {
        UserSession.token = token;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
