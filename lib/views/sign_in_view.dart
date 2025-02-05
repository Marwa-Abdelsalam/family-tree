import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../controllers/auth_controller.dart';
import '../feature/home_age/presentation/pages/landing_page.dart';
import 'sign_up_view.dart';

class SignInScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الدخول'),
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: size.height * 0.005),
              Center(
                child: Image.asset(
                  'assets/logo.png',  // Make sure the logo image is in this path
                  height: 250,
                ),
              ),
              SizedBox(height: size.height * 0.005),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  //     height: 60,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(20),
                  //       color: Colors.grey[200],
                  //     ),
                    child:IntlPhoneField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration( //decoration for Input Field
                        labelText: "رقم الجوال".tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      initialCountryCode: 'SA', //default contry code, NP for Nepal
                      onChanged: (phone) {
                        //when phone number country code is changed
                        // _phoneNumberController.text = phone.completeNumber;
                        _countryCodeController.text = phone.countryCode;
                        _phoneNumberController.text = phone.number;
                        print("Phone num${_phoneNumberController.text}"); //get complete number
                        print(phone.countryCode); // get country code only
                        print(phone.number); // only phone number
                      },
                    )
                ),
              ),

              SizedBox(height: 30),
              Obx(() {
                if (authController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print("${_countryCodeController.text}${_phoneNumberController.text}");
                        authController.signInWithPhoneNumber("${_countryCodeController.text}${_phoneNumberController.text}",);
                      }
                    },
                    child: Text('تسجيل الدخول', style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.w500),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffE8D0B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }
              }),
              SizedBox(height: 20,),

              Center(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب ؟',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: () {
                          Get.offAll(() => SignupScreen());
                        },
                        child: Text(
                          'تسجيل جديد',
                          style: TextStyle(
                            color:  Colors.blue,
                            // 0xffE8D0B4 //
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 50,),
              Text("فكرة و تنفيذ : السيد اسماعيل سلمان العبدالمحسن",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),),
              SizedBox(height: 15,),
              Text("جميع الحقوق الفكرية و الملكية محفوظة لإسرة العبدالمحسن",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),),
              SizedBox(height: 15,),
              Text(" الإصدار رقم :  1.0 - محرم 1446 هجري ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green [600],
                  fontWeight: FontWeight.bold,
                ),),
            ],
          ),
        ),
      ),
    );
  }
}

