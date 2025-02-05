import 'dart:math';

import 'package:family_app_tree/controllers/auth_controller.dart';
import 'package:family_app_tree/views/family_occasions_view.dart';
import 'package:family_app_tree/views/family_tree_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../add_new_member_request/presentation/pages/request_to_add_member_screen.dart';
import 'add_new_member_request.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        backgroundColor: const Color(0xffE8D0B4),
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: const CircleWithSurroundings(),
    );
  }
}

class CircleWithSurroundings extends StatelessWidget {
  const CircleWithSurroundings({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerSize = screenWidth;
    final double centerOffset = containerSize / 2;

    final double mainCircleRadius =
        screenWidth * 0.2;
    final double surroundingCircleRadius =
        screenWidth * 0.12;

    final AuthController authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    final List<Map<String, dynamic>> landingOptions = [
      {
        "icon": "assets/family.png",
        "action": () => Get.to(() => const FamilyTree())
      },
      {
        "icon": "assets/calender.png",
        "action": () => Get.to(() => CustomCalendarScreen())
      },
      {"icon": "assets/logout.png", "action": authController.logout},
      {"icon": "assets/add_properties.png", "action": () {
        showBottomSheet(
            enableDrag: false,
            context: context, builder: (context) => RequestToAddMemberScreen(),





        );
      }},

    ];

    return Center(
      child: SizedBox(
        width: containerSize,
        height: containerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [

            Container(
              width: mainCircleRadius * 1.8,
              height: mainCircleRadius * 1.8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amberAccent,
              ),
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.fill,
              ),
            ),

            ...landingOptions.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> option = entry.value;
              double angle =
                  (index * pi / (landingOptions.length / 2));
              return Positioned(
                left: centerOffset +
                    (mainCircleRadius + surroundingCircleRadius) * cos(angle) -
                    surroundingCircleRadius,
                top: centerOffset +
                    (mainCircleRadius + surroundingCircleRadius) * sin(angle) -
                    surroundingCircleRadius,
                child: GestureDetector(
                  onTap: () async {
                    await option["action"]();
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: surroundingCircleRadius * 2,
                        height: surroundingCircleRadius * 2,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyan,
                        ),
                        child: Center(
                          child: Image.asset(
                            option["icon"],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
