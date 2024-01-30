import 'package:ai/view/home.dart';
import 'package:ai/view/styles/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ai App',
      theme: ThemeData.light(useMaterial3: true)
          .copyWith(scaffoldBackgroundColor: AppColors.whiteColor),
      home: HomePage(),
    );
  }
}
