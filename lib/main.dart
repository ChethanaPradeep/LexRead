import 'package:flutter/material.dart';
import 'package:lexread/pages/login_page.dart';
import 'package:lexread/pages/newdoc_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lex Read',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.amber.shade300,
          secondary: Colors.amber.shade200,
        ),
        unselectedWidgetColor: Colors.amber.shade800,
        textTheme: TextTheme(
          bodyText1: TextStyle(
              color: Colors.grey[800],
              fontFamily: "OpenDyslexic",
              fontSize: 17),
          bodyText2: TextStyle(
              color: Colors.grey[800],
              fontFamily: "OpenDyslexic",
              fontSize: 15),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
