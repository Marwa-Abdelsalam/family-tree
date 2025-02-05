import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class OtpSignInScreen extends StatelessWidget {
  final TextEditingController _otpController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  final String phoneNumber;
  final bool isSignUp;
  final String? name;
  final File? profileImage;

  OtpSignInScreen({
    required this.phoneNumber,
    this.isSignUp = false,
    this.name,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أدخل رمز التحقق'),
        centerTitle: true,
        backgroundColor: Color(0xffE8D0B4),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رمز التحقق',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,

                  fillColor: Colors.white,

                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
              ),
              SizedBox(height: 20),
              Obx(() {
                if (authController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      if (isSignUp) {
                        authController.verifyOtpForSignUp(
                          _otpController.text,
                          phoneNumber,
                          name!,
                          profileImage,
                        );
                      } else {
                        authController.verifyOtpForSignIn(
                          _otpController.text,
                          phoneNumber,
                        );
                      }
                    },
                    child: Text('تحقق', style: TextStyle(color: Colors.black, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffE8D0B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
