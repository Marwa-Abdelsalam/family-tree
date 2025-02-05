import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  String auth;
  Timestamp created_at;
  String username;
  String img;
  String phone;

  AppUserModel({required this.auth, required this.created_at,required this.img,required this.username, required this.phone});

}