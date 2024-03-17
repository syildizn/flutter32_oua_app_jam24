import 'package:flutter/material.dart';
import 'package:flutter32_oua_app_jam24/screens/DetailPage.dart';
import 'package:flutter32_oua_app_jam24/screens/addLocationPage.dart';
import 'package:flutter32_oua_app_jam24/screens/homePage.dart';
import 'package:flutter32_oua_app_jam24/screens/signInPage.dart';
import 'package:flutter32_oua_app_jam24/screens/signUpPage.dart';
import 'package:flutter32_oua_app_jam24/screens/widgets/wrapper.dart';

Map<String,WidgetBuilder> routes = <String, WidgetBuilder>{
  HomePage.routeName: (context) => const HomePage(),
  SignInPage.routeName:(context) => SignInPage(),
  SignUpPage.routeName:(context) => SignUpPage(),
  Wrapper.routeName:(context) => const Wrapper(),
  DetailPage.routeName:(context) => const DetailPage(data: {},documaIdsi: ""),
  AddLocationPage.routeName:(context) => AddLocationPage(),
};