import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mychat/pages/search_page.dart';
import './pages/login_page.dart';
import './pages/registration_page.dart';
import 'services/navigation_service.dart';
import './pages/home_page.dart';
import './pages/profile_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main(){
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatify',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(42, 117, 188, 1),
        accentColor: Color.fromRGBO(42, 117, 188, 1),
        backgroundColor: Color.fromRGBO(28, 27, 27, 1),
      ),
      initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => LoginPage(),
        "register": (BuildContext _context) => RegistrationPage(),
        "home": (BuildContext _context) => HomePage(),
        "profile": (BuildContext _context) => ProfilePageState(),
        "searchpage": (BuildContext _context) => SearchPage(),
      },
    );
  }
}
