import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Ensure this path is correct
import '../models/family_member_firestore.dart';

class FamilyTree extends StatelessWidget {
  const FamilyTree({super.key});
  @override
  Widget build(BuildContext context) {
    CollectionReference users =
    FirebaseFirestore.instance.collection("latestMembers");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Family Tree"),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: users.get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              List<FamilyMemberFirestore> members = snapshot.data!.docs
                  .map((doc) => FamilyMemberFirestore.fromJson(
                  doc.data() as Map<String, dynamic>))
                  .toList();
              members.sort((a, b) => a.memberId.compareTo(b.memberId));
              return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  FamilyMemberFirestore member = members[index];
                  return Card(
                      shadowColor: Colors.amberAccent,
                      child: ListTile(
                        title: Text(member.memberName +
                            " : " +
                            member.memberId.toString()),
                        subtitle: Column(
                          children: members
                              .where(
                                (element) => element.fatherId == member.memberId,
                          )
                              .map((e) {
                            return Card(
                              child: ListTile(
                                title: Text(e.memberName),
                                trailing: Icon(
                                  e.sex == Enum.EMPTY
                                      ? Icons.male
                                      : Icons.female,
                                  color: e.sex == Enum.EMPTY
                                      ? Colors.blue
                                      : Colors.pink,
                                ),
                                subtitle: Column(
                                  children: [
                                    Text("Id: ${e.memberId}"),
                                    Text("Father Id: ${e.fatherId}"),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ));
                },
              );
            }
            return Text("No data found");
          },
        ));
  }
}
