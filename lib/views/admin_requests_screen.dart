import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../controllers/family_member_controller.dart';

class AdminRequestsScreen extends StatelessWidget {
  final FamilyMemberController familyController = Get.find();

  AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('إدارة الطلبات'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'تعديل'),
                Tab(text: 'إضافة أبناء'),
                Tab(text: 'إضافة زوجة'),
                Tab(text: 'حذف'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildRequestsList('edit'),
              _buildRequestsList('addChildren'),
              _buildRequestsList('addWife'),
              _buildRequestsList('delete'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList(String requestType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('type', isEqualTo: requestType)
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('لا توجد طلبات'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('لا توجد طلبات'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final request = snapshot.data!.docs[index];
            return _buildRequestCard(context, request);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, DocumentSnapshot request) {
    final data = request.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مقدم الطلب: ${data['requestedByName']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('العضو: ${data['memberName']}'),
            const SizedBox(height: 8),
            if (data['type'] == 'edit' || data['type'] == 'delete')
              Text('السبب: ${data['reason']}')
            else if (data['type'] == 'addChildren')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الأبناء: ${data['childrenNames']}'),
                  if (data['additionalInfo']?.isNotEmpty ?? false)
                    Text('معلومات إضافية: ${data['additionalInfo']}'),
                ],
              )
            else if (data['type'] == 'addWife')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اسم الزوجة: ${data['wifeName']}'),
                  if (data['additionalInfo']?.isNotEmpty ?? false)
                    Text('معلومات إضافية: ${data['additionalInfo']}'),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _handleApprove(context, request, data),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('قبول'),
                ),
                ElevatedButton(
                  onPressed: () => _handleReject(context, request.reference),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('رفض'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context, DocumentSnapshot request,
      Map<String, dynamic> data) async {
    try {
      // Get the member
      final QuerySnapshot memberSnapshot = await FirebaseFirestore.instance
          .collection('latestMembers')
          .where('الرقم', isEqualTo: data['memberId'])
          .get();

      if (memberSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على العضو')),
        );
        return;
      }

      final member = memberSnapshot.docs.first;

      switch (data['type']) {
        case 'edit':
          // Navigate to edit screen with the member data
          Get.back();
          Get.toNamed('/edit-member', arguments: member.data());
          break;

        case 'addChildren':
          final childrenNames = (data['childrenNames'] as String).split(',');
          for (String name in childrenNames) {
            if (name.trim().isNotEmpty) {
              await familyController.addChild(
                  member.data() as dynamic, name.trim(), 'ذكر');
            }
          }
          break;

        case 'addWife':
          await familyController.addWife(
              member.data() as dynamic, data['wifeName'], '');
          break;

        case 'delete':
          await familyController.deleteMember(member.data() as dynamic);
          break;
      }

      // Update request status
      await request.reference.update({'status': 'approved'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول الطلب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  Future<void> _handleReject(
      BuildContext context, DocumentReference reference) async {
    try {
      await reference.update({'status': 'rejected'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض الطلب')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }
}
