
import 'package:family_app_tree/controllers/family_member_controller.dart';
import 'package:get/get.dart';

class Binding extends Bindings{
  @override
  void dependencies() {

    Get.lazyPut(() => FamilyMemberController());

  }
}