import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../controllers/auth_controller.dart';
import 'sign_in_view.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();
  final AuthController authController = Get.put(AuthController());

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل جديد'),
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
              SizedBox(height: 50),
              Center(
                child: Image.asset(
                  'assets/logo.png',  // Make sure the logo image is in this path
                  height: 250,
                ),
              ),
              SizedBox(height: 50),
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'الاسم رباعي',border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم رباعي';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
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
                        labelText: "رقم الحوال".tr,
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
              SizedBox(height: 50),
              GestureDetector(
                onTap: () async {
                  await _showImageSourceDialog();
                },
                child: _profileImage == null
                    ? Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: Colors.grey[700],
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _profileImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Obx(() {
                if (authController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _profileImage != null) {
                        authController.signUpWithPhoneNumber(
                          "${_countryCodeController.text}${_phoneNumberController.text}",
                          _nameController.text,
                          _profileImage,
                        );
                      }else{

                      }
                    },
                    child: Text('تسجيل', style: TextStyle(color: Colors.black, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffE8D0B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }
              }),
              SizedBox(height: 20),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.offAll(() => SignInScreen());
                      },
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: Color(0xffE8D0B4),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختر مصدر الصورة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('المعرض'),
                onTap: () {
                  _pickImage();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('الكاميرا'),
                onTap: () {
                  _captureImage();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
