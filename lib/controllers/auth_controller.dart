import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_app_tree/models/app_user_model.dart';
import 'package:family_app_tree/views/sign_in_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../feature/home_age/presentation/pages/landing_page.dart';
import '../views/otp_sign_in_view.dart';

class AuthController extends GetxController {
  var verificationId = ''.obs;
  var isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  AppUserModel? appUserModel;

  Future<void> signUpWithPhoneNumber(String phoneNumber, String name, File? profileImage) async {
    isLoading.value = true;
    try {
      // Check if the phone number already exists in the users collection
      QuerySnapshot snapshot = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).get();
      if (snapshot.docs.isNotEmpty) {
        isLoading.value = false;
        Get.snackbar('Error', 'رقم الجوال مسجل بالفعل');
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          String imageUrl = await _uploadProfileImage(profileImage);
          await _saveUserToFirestore(phoneNumber, name, imageUrl);
          isLoading.value = false;
          Get.offAll(() => LandingPage());
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          Get.snackbar('Error', e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId.value = verificationId;
          isLoading.value = false;
          Get.to(() => OtpSignInScreen(phoneNumber: phoneNumber, isSignUp: true, name: name, profileImage: profileImage));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId.value = verificationId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to sign up');
    }
  }

  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    isLoading.value = true;
    final box = GetStorage();
    try {
      // Check if the phone number exists in the users collection
      QuerySnapshot snapshot = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).get();
      if (snapshot.docs.isEmpty) {
        isLoading.value = false;
        Get.snackbar('Error', 'رقم الجوال غير مسجل');
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          isLoading.value = false;
          Get.offAll(() => LandingPage());
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          Get.snackbar('Error', e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId.value = verificationId;
          isLoading.value = false;
          Get.to(() => OtpSignInScreen(phoneNumber: phoneNumber));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId.value = verificationId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to sign in');
    }
  }

  Future<void> verifyOtpForSignUp(String smsCode, String phoneNumber, String name, File? profileImage) async {
    isLoading.value = true;
    final box = GetStorage();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId.value, smsCode: smsCode);
      await _auth.signInWithCredential(credential);
      String imageUrl = await _uploadProfileImage(profileImage);
      await _saveUserToFirestore(phoneNumber, name, imageUrl);
      box.write("signedIn", true);
      box.write('phone',phoneNumber);
      print("Sign in: ${box.read("signedIn")}");
      Get.offAll(() => LandingPage());
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Invalid OTP');
    }
  }

  Future<void> verifyOtpForSignIn(String smsCode, String phoneNumber) async {
    isLoading.value = true;
    try {
      final box = GetStorage();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId.value, smsCode: smsCode);
      await _auth.signInWithCredential(credential);
      box.write("signedIn", true);
      box.write('phone', phoneNumber);
      final store = FirebaseFirestore.instance;
      final col = await store.collection('users').get();
      final doc = col.docs.where((element) => element['phone'] == phoneNumber,).first;
      appUserModel = AppUserModel(auth: doc['auth'], created_at: doc['created_at'], img: doc['image_url'], username: doc['name'], phone: doc['phone']);
      print("Sign in: ${box.read("signedIn")}");
      update();
      isLoading.value = false;
      Get.offAll(() => LandingPage());
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Invalid OTP');
    }
  }

  logout()async{
    try{
      final box = GetStorage();
      await _auth.signOut();
      Get.offAll(() => SignInScreen());
      box.write("signedIn", false);
    }catch(e){
      Get.snackbar('Error', 'Can\'t logout');
    }
  }

  Future<String> _uploadProfileImage(File? profileImage) async {
    if (profileImage == null) return '';
    Reference storageRef = _storage.ref().child('profile_images/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = storageRef.putFile(profileImage);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _saveUserToFirestore(String phoneNumber, String name, String imageUrl) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
      'phone': phoneNumber,
      'name': name,
      'image_url': imageUrl,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
