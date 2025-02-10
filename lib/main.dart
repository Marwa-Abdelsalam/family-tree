import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_app_tree/controllers/binding.dart';
import 'package:family_app_tree/controllers/family_member_controller.dart';

import 'package:family_app_tree/views/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
//family tree
    Get.put(FamilyMemberController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Family Tree',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        primaryColor: Colors.brown,
      ),
      home: SplashScreen(),
      initialBinding: Binding(),
    );
  }
}
