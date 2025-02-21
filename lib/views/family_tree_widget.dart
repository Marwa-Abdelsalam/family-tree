import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';
import 'package:get/get.dart' as getx;
import 'package:intl/intl.dart' as intl;
import 'package:jhijri/jHijri.dart';
import '../controllers/family_member_controller.dart'; // Ensure this path is correct
import '../models/family_member_firestore.dart';
import 'editMemberDetails.dart';
import 'memberDetailsScreen.dart';
import 'admin_requests_screen.dart';

class FamilyTree extends StatefulWidget {
  const FamilyTree({super.key});

  @override
  _FamilyTreeState createState() => _FamilyTreeState();
}

class _FamilyTreeState extends State<FamilyTree> {
  final FamilyMemberController controller =
      getx.Get.isRegistered<FamilyMemberController>()
          ? getx.Get.find<FamilyMemberController>()
          : getx.Get.put(FamilyMemberController());

  final TransformationController _transformationController =
      TransformationController();
  final TextEditingController searchController = TextEditingController();

  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration()
    ..siblingSeparation = 10
    ..levelSeparation = 15
    ..subtreeSeparation = 10
    ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT;

  List<Edge> highlightedEdges = [];
  List<FamilyMemberFirestore> highlightedPath = [];
  Timer? _debounce;
  Graph graph = Graph();
  bool _isSearching = false;
  bool _treeLoaded = false;

  @override
  void initState() {
    super.initState();
    controller.getUser();
    _zoomLevel = 1.0;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _zoomOutToFitAllNodes());
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _zoomOutToFitAllNodes() {
    final nodeCount = controller.graph.nodeCount();
    if (nodeCount == 0) return;

    final scale = nodeCount < 20
        ? 1.0
        : (nodeCount < 50
            ? 0.8
            : (nodeCount < 100 ? 0.6 : (nodeCount < 200 ? 0.2 : 0.1)));
    _transformationController.value = Matrix4.identity()..scale(scale);
  }

  void _performSearch(String query) {
    final results = controller.searchFamilyMemberLocally(query);
    if (results.isNotEmpty) {
      _showSearchResultsDialog(results);
    }
  }

  void _showSearchResultsDialog(List<FamilyMemberFirestore> results) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('نتائج البحث'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final member = results[index];
                return ListTile(
                  title: Text(controller.generateDisplayName(member)),
                  onTap: () {
                    controller.highlightPathToRoot(member);
                    _centerOnNode(member);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('تم'),
            ),
          ],
        ),
      ),
    );
  }

  FamilyMemberFirestore? _findMember(
      FamilyMemberFirestore member, int memberId) {
    if (member.memberId == memberId) return member;
    for (final child in member.children) {
      final result = _findMember(child, memberId);
      if (result != null) return result;
    }
    return null;
  }

  void _centerOnNode(FamilyMemberFirestore member) {
    final node = controller.graph.nodes.firstWhere((node) =>
        (node.key!.value as FamilyMemberFirestore).memberId == member.memberId);
    final matrix = Matrix4.identity();
    final x = node.position.dx ?? 0.0;
    final y = node.position.dy ?? 0.0;
    matrix.translate(-x + MediaQuery.of(context).size.width / 2 - 75,
        -y + MediaQuery.of(context).size.height / 2);
    _transformationController.value = matrix;
  }

  void _checkAndLoadMoreNodes() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final translation = _transformationController.value.getTranslation();
      if (translation.y.abs() < 100) {
        await controller.fetchMembers(limit: 100);
        controller.addNodesToGraph(controller.members);
      }
    });
  }

  void _showAddChildrenDialog(FamilyMemberFirestore member) {
    final sonController = TextEditingController();
    final daughterController = TextEditingController();
    final sons = <String>[];
    final daughters = <String>[];

    getx.Get.back();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void addChild(String childName, List<String> childList,
              TextEditingController controller) {
            if (childName.trim().isNotEmpty) {
              setState(() {
                childList.add(childName.trim());
                controller.clear();
              });
            }
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('اضافة ابناء'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sonController,
                    decoration: const InputDecoration(labelText: 'إضافة ابن'),
                    onSubmitted: (value) =>
                        addChild(value, sons, sonController),
                    onChanged: (value) {
                      if (value.endsWith(' ')) {
                        addChild(value, sons, sonController);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: _buildChips(sons)),
                  TextField(
                    controller: daughterController,
                    decoration: const InputDecoration(labelText: 'إضافة ابنة'),
                    onSubmitted: (value) =>
                        addChild(value, daughters, daughterController),
                    onChanged: (value) {
                      if (value.endsWith(' ')) {
                        addChild(value, daughters, daughterController);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: _buildChips(
                        daughters,
                      )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Future.wait([
                      for (final son in sons)
                        controller.addChild(member, son, 'ذكر'),
                      for (final daughter in daughters)
                        controller.addChild(member, daughter, 'انثي')
                    ]);
                    print("Children added successfully. $sons $daughters");
                    Navigator.of(context).pop();
                  },
                  child: const Text('حفظ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Chip> _buildChips(
    List<String> names,
  ) {
    return names.map((name) {
      return Chip(
        label: Text(name),
        onDeleted: () => setState(() => names.remove(name)),
      );
    }).toList();
  }

// screen ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        children: [
          IconButton(
              onPressed: () => _zoomOutToFitAllNodes(),
              icon: const Icon(Icons.zoom_out)),
        ],
      ),
      backgroundColor: const Color(0xffE8D0B4),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: getx.GetBuilder<FamilyMemberController>(
              builder: (controller) {
                if (controller.members.isEmpty ||
                    controller.graph.edges.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!_treeLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _zoomOutToFitAllNodes();
                    _treeLoaded = true;
                    _centerNode(controller);
                  });
                }

                return _buildGraphView(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching ? _buildSearchField() : const Text('شجرة الأسرة'),
      centerTitle: true,
      backgroundColor: const Color(0xffE8D0B4),
      elevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      actions: [
        if (controller.userModel?.auth == 'admin')
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => getx.Get.to(() => AdminRequestsScreen()),
          ),
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search,
              color: Colors.black),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              searchController.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'ابحث عن عضو...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _performSearch(searchController.text.trim()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _centerOnSpecificNode(FamilyMemberController controller) {
    FamilyMemberFirestore? memberToCenter;
    for (var member in controller.members) {
      memberToCenter = _findMember(member, member.memberId);
      if (memberToCenter != null) {
        _centerOnNode(memberToCenter);
        break;
      }
    }
  }

  void _centerNode(FamilyMemberController controller) {
    FamilyMemberFirestore? memberToCenter;
    for (var member in controller.members) {
      memberToCenter = _findMember(member, 1000);
      if (memberToCenter != null) {
        _centerOnNode(memberToCenter);
        break;
      }
    }
  }

  Widget _buildGraphView(FamilyMemberController controller) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        _checkAndLoadMoreNodes();
        return true;
      },
      child: Consumer(builder: (context, ref, child) {
        return Center(
          child: InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(10),
            minScale: 0.4,
            maxScale: .99,
            transformationController: _transformationController,
            child: GraphView(
              graph: controller.graph,
              algorithm: BuchheimWalkerAlgorithm(builder, null),
              paint: Paint()
                ..color = const Color(0xffc18d51)
                ..strokeWidth = 2,
              builder: (Node node) {
                final familyMember = node.key!.value as FamilyMemberFirestore;
                return GestureDetector(
                  onTap: () => _showInfoDialog(context, familyMember),
                  child: _buildMemberWidget(familyMember),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMemberWidget(FamilyMemberFirestore familyMember) {
    final isHighlighted = highlightedPath.contains(familyMember);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: _getMemberColor(familyMember),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              familyMember.image ==
                          'https://firebasestorage.googleapis.com/v0/b/alabdelmohsen-family-app.appspot.com/o/profile_images%2FmemberDefault.png?alt=media&token=d8bc32df-8908-4380-b4e6-aa7c91879773' &&
                      familyMember.sex == Enum.EMPTY
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.green.shade900,
                    )
                  : const SizedBox(),
              const SizedBox(
                width: 1,
              ),
              Text(
                familyMember.memberName + getMemberAge(familyMember),
                style: TextStyle(
                  color:
                      isHighlighted ? Colors.red : _getTextColor(familyMember),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getMemberAge(FamilyMemberFirestore member) {
    if (member.birthdateHijri != null &&
        member.birthdateHijri.isNotEmpty &&
        member.lifeStatus == FamilyMemberFirestoreEnum.PURPLE) {
      String dateStr = member.birthdateHijri.split('/').reversed.join('-');
      List<String> parts = dateStr.split('-');
      if (parts.length == 3) {
        String year = parts[2];
        int y = int.parse(year);
        return "-${HijriDate.now().year - y}";
      }
      return "";
    } else if (member.birthdateHijri != null &&
        member.birthdateHijri.isNotEmpty &&
        member.deathDateHijri != null &&
        member.deathDateHijri.isNotEmpty &&
        member.lifeStatus == FamilyMemberFirestoreEnum.EMPTY) {
      String dateStr = member.birthdateHijri.split('/').reversed.join('-');
      String deathDate = member.deathDateHijri.split('/').reversed.join('-');
      List<String> parts = dateStr.split('-');
      List<String> parts2 = deathDate.split('-');
      if (parts.length == 3 && parts2.length == 3) {
        String year = parts[2];
        String deathYear = parts2[2];
        int y = int.parse(year);
        int y2 = int.parse(deathYear);
        return "-${y2 - y}";
      }
      return "";
    } else {
      return "";
    }
  }

  Color _getTextColor(FamilyMemberFirestore member) {
    if (member.lifeStatus == FamilyMemberFirestoreEnum.PURPLE) {
      return member.sex == Enum.EMPTY ? Colors.green : Colors.white;
    }
    return Colors.black;
  }

  Color _getMemberColor(FamilyMemberFirestore member) {
    if (member.lifeStatus == FamilyMemberFirestoreEnum.PURPLE &&
        member.sex == Enum.EMPTY) {
      return Colors.white;
    } else if (member.lifeStatus == FamilyMemberFirestoreEnum.PURPLE &&
        member.sex == Enum.PURPLE) {
      return const Color(0xfffcb3f0);
    } else if (member.lifeStatus == FamilyMemberFirestoreEnum.EMPTY) {
      return Colors.grey;
    } else if (member.lifeStatus == FamilyMemberFirestoreEnum.EMPTY &&
        member.sex == Enum.EMPTY) {
      return Colors.red.shade900;
    } else if (member.lifeStatus == FamilyMemberFirestoreEnum.EMPTY &&
        member.sex == Enum.PURPLE) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  void _showInfoDialog(BuildContext context, FamilyMemberFirestore member) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.only(top: 20),
          content: SingleChildScrollView(
            child: getx.GetBuilder<FamilyMemberController>(
              builder: (famCtrl) =>
                  _buildDialogContent(context, member, famCtrl),
            ),
          ),
        ),
      ),
    );
  }

  Column _buildDialogContent(BuildContext context, FamilyMemberFirestore member,
      FamilyMemberController famCtrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDialogHeader(member, famCtrl),
        _buildDialogButton(
            context, 'إحصائيات', Icons.bar_chart, _showStatisticsDialog),
        _buildDialogButton(context, 'عرض البيانات', Icons.info,
            () => _navigateToMemberDetails(member)),
        if (famCtrl.userModel!.auth == 'admin') ...[
          _buildDialogButton(context, 'تعديل البيانات', Icons.edit,
              () => _navigateToEditMemberDetails(member)),
          _buildDialogButton(context, 'اضافة ابناء', Icons.person_add,
              () => _showAddChildrenDialog(member)),
          _buildDialogButton(context, 'اضافة زوجة', Icons.family_restroom,
              () => _showAddWifeDialog(member)),
        ],
        if (famCtrl.userModel!.auth != 'admin') ...[
          _buildDialogButton(context, ' طلب تعديل البيانات', Icons.edit,
              () => _showRequestEditDialog(member)),
          _buildDialogButton(context, ' طلب اضافة ابناء', Icons.person_add,
              () => _showRequestAddChildrenDialog(member)),
          _buildDialogButton(context, ' طلب اضافة زوجة', Icons.family_restroom,
              () => _showRequestAddWifeDialog(member)),
        ],
        _buildDialogButton(context, 'عرض المسار للجذر', Icons.alt_route, () {
          famCtrl.highlightPathToRoot(member);
          Navigator.of(context).pop();
        }),
        if (famCtrl.userModel!.auth == 'admin')
          _buildDialogButton(context, 'حذف', Icons.delete,
              () => _showDeleteMemberDialog(member),
              color: Colors.red),
        if (famCtrl.userModel!.auth != 'admin')
          _buildDialogButton(context, ' طلب حذف', Icons.delete,
              () => _showRequestDeleteDialog(member),
              color: Colors.red),
      ],
    );
  }

  Container _buildDialogHeader(
      FamilyMemberFirestore member, FamilyMemberController famCtrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              member.image != null
                  ? Image.network(member.image, width: 80, height: 80)
                  : const SizedBox.shrink(),
              if (famCtrl.userModel!.auth == 'admin')
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                  width: 50,
                  height: 50,
                  child: IconButton(
                    onPressed: () {
                      controller.updateImage(context, member.memberId, member);
                      getx.Get.back();
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            member.memberName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton(
      BuildContext context, String text, IconData icon, VoidCallback onTap,
      {Color color = Colors.brown}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(text,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showStatisticsDialog() async {
    getx.Get.back();
    getx.Get.dialog(const Center(child: CircularProgressIndicator()));
    await controller.fetchAllMembersAndShowStatistics();
  }

  void _showAddWifeDialog(FamilyMemberFirestore member) {
    final wifeNameController = TextEditingController();
    final wifeAgeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('اضافة زوجة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wifeNameController,
                decoration: const InputDecoration(labelText: 'اسم الزوجة'),
              ),
              TextField(
                controller: wifeAgeController,
                decoration: const InputDecoration(labelText: 'عمر الزوجة'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final wifeName = wifeNameController.text;
                final wifeAge = wifeAgeController.text;
                if (wifeName.isNotEmpty && wifeAge.isNotEmpty) {
                  await controller.addWife(member, wifeName, wifeAge);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يرجى ملء جميع الحقول')));
                }
              },
              child: const Text('اضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteMemberDialog(FamilyMemberFirestore member) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف عضو'),
          content: const Text('هل أنت متأكد من أنك تريد حذف هذا العضو؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                await controller.deleteMember(member);
                Navigator.of(context).pop();
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMemberDetails(FamilyMemberFirestore member) {
    getx.Get.to(MemberDetailsScreen(member: member));
  }

  void _navigateToEditMemberDetails(FamilyMemberFirestore member) {
    getx.Get.to(EditMemberDetails(member: member));
  }

  void _showRequestEditDialog(FamilyMemberFirestore member) {
    final reasonController = TextEditingController();

    getx.Get.back();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('طلب تعديل البيانات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                    labelText: 'سبب طلب التعديل',
                    hintText: 'يرجى ذكر سبب طلب التعديل والتعديلات المطلوبة'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                if (reasonController.text.trim().isNotEmpty) {
                  await controller.submitEditRequest(
                      member, reasonController.text.trim());
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('تم إرسال طلب التعديل بنجاح')));
                }
              },
              child: const Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestAddChildrenDialog(FamilyMemberFirestore member) {
    final childrenController = TextEditingController();
    final reasonController = TextEditingController();

    getx.Get.back();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('طلب إضافة أبناء'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: childrenController,
                decoration: const InputDecoration(
                    labelText: 'أسماء الأبناء',
                    hintText: 'اكتب أسماء الأبناء مفصولة بفواصل'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                    labelText: 'معلومات إضافية',
                    hintText: 'أي معلومات إضافية عن الأبناء'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                if (childrenController.text.trim().isNotEmpty) {
                  await controller.submitAddChildrenRequest(
                      member,
                      childrenController.text.trim(),
                      reasonController.text.trim());
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('تم إرسال طلب إضافة الأبناء بنجاح')));
                }
              },
              child: const Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestAddWifeDialog(FamilyMemberFirestore member) {
    final wifeNameController = TextEditingController();
    final reasonController = TextEditingController();

    getx.Get.back();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('طلب إضافة زوجة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wifeNameController,
                decoration: const InputDecoration(
                    labelText: 'اسم الزوجة', hintText: 'اكتب اسم الزوجة'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                    labelText: 'معلومات إضافية',
                    hintText: 'أي معلومات إضافية عن الزوجة'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                if (wifeNameController.text.trim().isNotEmpty) {
                  await controller.submitAddWifeRequest(
                      member,
                      wifeNameController.text.trim(),
                      reasonController.text.trim());
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('تم إرسال طلب إضافة الزوجة بنجاح')));
                }
              },
              child: const Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDeleteDialog(FamilyMemberFirestore member) {
    final reasonController = TextEditingController();

    getx.Get.back();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('طلب حذف عضو'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                    labelText: 'سبب طلب الحذف',
                    hintText: 'يرجى ذكر سبب طلب حذف العضو'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                if (reasonController.text.trim().isNotEmpty) {
                  await controller.submitDeleteRequest(
                      member, reasonController.text.trim());
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('تم إرسال طلب الحذف بنجاح')));
                }
              },
              child: const Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}

double _zoomLevel = 1.0;
