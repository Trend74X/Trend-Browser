// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:trend_browser/controllers/app_controller.dart';
import 'package:trend_browser/views/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  final AppController _con = Get.put(AppController());

  @override
  void initState() {
    super.initState();
    _con.getHistoryList();
    Timer(
      const Duration(seconds: 1),
      () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const HomePage(),
          transitionDuration: const Duration(seconds: 0)
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          width: MediaQuery.of(context).size.width * 0.75,
          child: Image.asset('assets/img/splash.png')
        )
      )
    );
  }
}