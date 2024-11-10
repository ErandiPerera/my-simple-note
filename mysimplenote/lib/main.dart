import 'package:flutter/material.dart';
import 'view/splash_screen.dart';

void main(){
  runApp(MySimpleNote());
}

class MySimpleNote extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}