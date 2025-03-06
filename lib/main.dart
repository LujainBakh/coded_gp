import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:coded_gp/features/navigation/views/screens/main_navigation_screen.dart';  
// Import other necessary controllers and utilities

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Coded GP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainNavigationScreen(),
    );
  }
}