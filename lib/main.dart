import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:weatherapp/pages.dart';

void main() => runApp(MyApp());

//Klasy odpowiedzialne za wyświetlanie i zmienianie widoków/stron.
//Jest to uniwersalny kod do tego typu operacji (z małymi modyfikacjami)

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //ukrycie wstążki z napisem "DEBUG"
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _pages = [WeatherApp(), SeniorWeatherApp()];
  var _pageController = PageController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: _pages,
        onPageChanged: (index) {
          setState(() {
          });
        },
        controller: _pageController,
      ),
    );
  }
}