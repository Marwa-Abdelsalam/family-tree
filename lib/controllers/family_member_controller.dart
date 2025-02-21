import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:family_app_tree/models/app_user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphview/GraphView.dart' as gr;
import 'package:image_picker/image_picker.dart';
import 'package:jhijri/jHijri.dart';
import 'package:path_provider/path_provider.dart';
import '../models/family_member_firestore.dart'; // Ensure this path is correct

class FamilyMemberController extends GetxController {
  var members = <FamilyMemberFirestore>[].obs;
  var allMembers =
      <FamilyMemberFirestore>[].obs; // To hold all members for statistics
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  gr.Graph graph = gr.Graph();
  List<gr.Edge> highlightedEdges = [];
  List<FamilyMemberFirestore> highlightedPath = [];
  DocumentSnapshot? lastDocument;
  bool isFetchingMore = false;
  AppUserModel? userModel;

  @override
  void onInit() {
    super.onInit();
    fetchMembers(initialFetch: true).then((_) {
      print("Initial members fetched successfully, building graph.");
      buildGraph();
    });
    getUser();
    //setAllMembersImage();
  }

  getUser() async {
    GetStorage box = GetStorage();
    bool logged = box.read('signedIn');
    String phone = logged ? box.read('phone') : "";
    final col = await firestore.collection('users').get();
    final doc = col.docs
        .where(
          (element) => element['phone'] == phone,
        )
        .first;
    userModel = AppUserModel(
        auth: doc['auth'],
        created_at: doc['created_at'],
        img: doc['image_url'],
        username: doc['name'],
        phone: doc['phone'],
        uid: doc['uid']);
    update();
  }

  Future<void> updateImage(
      BuildContext context, int memberId, FamilyMemberFirestore member) async {
    try {
      // Pick an image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Upload the image to Firebase Storage
        String fileName = 'profile_images/$memberId.png';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(File(image.path));

        // Wait for the upload to complete
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        FirebaseFirestore.instance
            .collection('latestMembers')
            .where('الرقم', isEqualTo: memberId)
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({'الصورة': downloadUrl});
          }
        });
        member.image = downloadUrl;
        update();

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تم تحديث الصورة بنجاح')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('لم يتم اختيار صورة')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
  }

  void setAllMembersImage() async {
    String defaultImageUrl =
        'https://firebasestorage.googleapis.com/v0/b/alabdelmohsen-family-app.appspot.com/o/profile_images%2FmemberDefault.png?alt=media&token=d8bc32df-8908-4380-b4e6-aa7c91879773';

    // Reference to the Firestore collection
    CollectionReference members =
        FirebaseFirestore.instance.collection('latestMembers');

    // Fetch all members
    QuerySnapshot querySnapshot = await members.get();

    // Loop through each member document and update the "الصورة" field
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.update({'الصورة': defaultImageUrl});
    }

    print("All members' images have been updated.");
  }

  Future<void> fetchMembers(
      {int limit = 100, bool initialFetch = false}) async {
    try {
      if (isFetchingMore) return;

      if (!initialFetch) {
        _showLoadingDialog();
      }

      isFetchingMore = true;
      Query query = firestore.collection('latestMembers').orderBy('الرقم');
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        var memberList = snapshot.docs.map((doc) {
          return FamilyMemberFirestore.fromJson(
              doc.data() as Map<String, dynamic>);
        }).toList();
        allMembers.value = memberList;
        update();
        Map<int, FamilyMemberFirestore> memberMap = {
          for (var member in memberList) member.memberId: member
        };
        for (var member in memberList) {
          if (member.fatherId != 0 && memberMap.containsKey(member.fatherId)) {
            memberMap[member.fatherId]!.children.add(member);
          }
        }

        if (members.isEmpty && memberList.isNotEmpty) {
          members.add(memberList.firstWhere((m) => m.fatherId == 0));
        } else {
          members.addAll(memberList);
        }

        print("Members loaded: ${members.length}");
        for (var member in members) {
          print(
              "Member: ${member.memberName}, ID: ${member.memberId}, Children: ${member.children.length}");
        }
        update();
      }
      isFetchingMore = false;
      if (!initialFetch) {
        Get.back(); // Dismiss the loading dialog
      }
    } catch (e) {
      print('Error fetching members: $e');
      isFetchingMore = false;
      if (!initialFetch) {
        Get.back(); // Dismiss the loading dialog in case of an error
      }
    }
  }

  void _showLoadingDialog() {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
  }

  void buildGraph() {
    graph = gr.Graph();
    if (members.isNotEmpty) {
      _addMemberToGraph(members.first);
    }
    update();
  }

  void _addMemberToGraph(FamilyMemberFirestore member) {
    final node = gr.Node.Id(member);
    graph.addNode(node);
    if (member.fatherId != 0) {
      final parentNode = graph.nodes.firstWhere(
        (n) =>
            (n.key!.value as FamilyMemberFirestore).memberId == member.fatherId,
        orElse: () => gr.Node.Id(null),
      );
      if (parentNode.key!.value != null) {
        graph.addEdge(parentNode, node);
      }
    }
    for (var child in member.children) {
      _addMemberToGraph(child);
    }
  }

  void addNodesToGraph(List<FamilyMemberFirestore> members) {
    for (var member in members) {
      if (!graph.nodes.any((node) =>
          (node.key!.value as FamilyMemberFirestore).memberId ==
          member.memberId)) {
        _addMemberToGraph(member);
      }
    }
    update();
  }

  void highlightPathToRoot(FamilyMemberFirestore member) {
    highlightedPath.clear();
    highlightedEdges.clear();
    FamilyMemberFirestore? current = member;

    while (current != null) {
      highlightedPath.add(current);
      if (current.fatherId == 0) {
        break;
      }

      final parentNode = graph.nodes
          .firstWhere(
              (n) =>
                  (n.key!.value as FamilyMemberFirestore).memberId ==
                  current!.fatherId,
              orElse: () => gr.Node.Id(null))
          .key;

      if (parentNode != null && parentNode.value != null) {
        final parent = parentNode.value as FamilyMemberFirestore?;
        if (parent != null) {
          final currentEdge = gr.Edge(
            graph.nodes.firstWhere((n) => n.key!.value == current),
            graph.nodes.firstWhere((n) => n.key!.value == parent),
          );
          highlightedEdges.add(currentEdge);
          log("${highlightedPath.length} ${highlightedEdges.length}");
          current = parent;
        } else {
          current = null;
        }
      } else {
        current = null;
      }
    }

    update();
  }

  List<FamilyMemberFirestore> searchFamilyMemberLocally(String query) {
    if (query.isEmpty) {
      highlightedPath.clear();
      highlightedEdges.clear();
      update();
      return [];
    }

    final matchingMembers = graph.nodes
        .where((node) {
          final member = node.key!.value as FamilyMemberFirestore;
          String fullName = member.memberName + " " + member.fatherName;
          return fullName.contains(query);
        })
        .map((node) => node.key!.value as FamilyMemberFirestore)
        .toList();

    if (matchingMembers.isNotEmpty) {
      highlightPathToRoot(matchingMembers.first);
    }

    return matchingMembers;
  }

  String generateDisplayName(FamilyMemberFirestore member) {
    String displayName = member.memberName;
    FamilyMemberFirestore? current = member;
    int generation = 0;

    while (current != null && generation < 3) {
      if (current.fatherId != 0) {
        final parent = graph.nodes
            .firstWhereOrNull((n) =>
                (n.key!.value as FamilyMemberFirestore).memberId ==
                current!.fatherId)
            ?.key
            ?.value as FamilyMemberFirestore?;

        if (parent != null) {
          displayName += member.sex == Enum.EMPTY
              ? "بن${parent.memberName}"
              : " بنت ${parent.memberName}";
          current = parent;
          generation++;
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return displayName;
  }

  Future<void> exportMembersToJsonFile() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection('members').get();
      List<Map<String, dynamic>> membersList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      String jsonContent = jsonEncode(membersList);

      Directory directory = await getApplicationDocumentsDirectory();
      String path = '${directory.path}/members.json';

      File file = File(path);
      await file.writeAsString(jsonContent);
      print('Data exported successfully to $path');
    } catch (e) {
      print('Error exporting data: $e');
    }
  }

  Future<void> uploadJsonDataToFirestore() async {
    String jsonString = await rootBundle.loadString('assets/isa6.json');
    List<dynamic> jsonData = jsonDecode(jsonString);

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('latestMembers');

    for (var member in jsonData) {
      await collectionRef.add(member);
    }
    print('Data uploaded to Firestore successfully');
  }

  Future<void> addChild(
      FamilyMemberFirestore parent, String name, String gender) async {
    try {
      final newChild = FamilyMemberFirestore(
          memberId: DateTime.now().millisecondsSinceEpoch, // Unique ID
          memberName: name,
          image:
              'https://firebasestorage.googleapis.com/v0/b/alabdelmohsen-family-app.appspot.com/o/profile_images%2FmemberDefault.png?alt=media&token=d8bc32df-8908-4380-b4e6-aa7c91879773',
          fatherId: parent.memberId, // Parent ID
          fatherName: parent.memberName, // Parent Name
          phoneNumber: 0, // Phone Number (or other details)
          education: Empty.UNAVAILABLE, // Education (example value)
          fromFamily: Indigo.UNAVAILABLE, // From Family (example value)
          motherId: parent.wifeId, // Mother ID (example value)
          motherName: parent.wifeName, // Mother Name (example value)
          notes: '', // Notes (example value)

          deathLocation: Sticky.UNAVAILABLE, // Place of death (example value)
          work: Purple.UNAVAILABLE, // Job (example value)
          lifeStatus: FamilyMemberFirestoreEnum.PURPLE, // Alive (example value)
          sex: gender == 'ذكر' ? Enum.EMPTY : Enum.PURPLE, // Gender
          wifeLifeStatus: FamilyMemberFirestoreEnum
              .UNAVAILABLE, // Life status of spouse (example value)
          husbandLifeStatus: FamilyMemberFirestoreEnum
              .UNAVAILABLE, // Life status (example value)
          marrigeTime: Tentacled.EMPTY, // Marriage duration (example value)
          marrigeStatus: Fluffy.UNAVAILABLE, // Marriage status (example value)
          associatedDisease: AssociatedDisease.Empty, // Disease (example value)
          classification:
              Classification.EMPTY, // Classification (example value)
          diseaseName: DiseaseName.EMPTY, // Disease name (example value)
          dnaChange: DnaChange.EMPTY, // DNA change (example value)
          medicalGene: MedicalGene.Empty, // Medical gene (example value)
          inheritance: Inheritance.Empty, // Inheritance (example value)
          proteinChange: ProteinChange.EMPTY, // Protein change (example value)
          zygosity: Zygosity.EMPTY, // Zygosity (example value)
          creationDate: HijriDate.now(), // Creation date (example value)
          editDate: HijriDate.now()
          // Modification date (example value),
          );

      // Add the new child to Firebase
      await FirebaseFirestore.instance
          .collection('latestMembers')
          .add(newChild.toJson());

      // Update the local members list and graph
      parent.children.add(newChild);
      addNodesToGraph([newChild]);
    } catch (e) {
      print('Error adding child: $e');
    }
  }

  Future<void> addWife(
      FamilyMemberFirestore husband, String wifeName, String wifeAge) async {
    try {
      final newWife = FamilyMemberFirestore(
        memberId:
            DateTime.now().millisecondsSinceEpoch, // Unique ID for the wife
        memberName: wifeName,
        image:
            'https://firebasestorage.googleapis.com/v0/b/alabdelmohsen-family-app.appspot.com/o/profile_images%2FmemberDefault.png?alt=media&token=d8bc32df-8908-4380-b4e6-aa7c91879773',
        natId: 0,
        fatherId: 0, // Husband's ID
        fatherName: 0,
        motherId: null,
        motherName: null,
        phoneNumber: null,
        userEmail: null,
        education: Empty.UNAVAILABLE,
        fromFamily: Indigo.UNAVAILABLE,
        familyNumber: null,
        notes: '',
        hijriBirthDate: null,
        birthLocation: null,
        birthNotes: '',
        deathLocation: Sticky.UNAVAILABLE,
        deathNotes: '',
        work: Purple.EMPTY,
        job: '',
        lifeStatus: FamilyMemberFirestoreEnum.PURPLE, // Assuming wife is living
        sex: Enum.PURPLE, // Female
        hobbies: '',
        wifeName: husband.memberName,
        wifeId: null,
        university: '',
        marrigeId: husband.marrigeId,
        marrigeHijriDate: husband.marrigeHijriDate,
        wifeShortName: null,
        wifeHijriBirthdate: null,
        wifeHijriDeathDate: null,
        wifeLifeStatus: FamilyMemberFirestoreEnum.PURPLE,
        birthdateHijri: '',
        deathDateHijri: '',
        endMarrige: '',
        husbandLifeStatus: husband.lifeStatus,
        husbandName: husband.memberName,
        husbandShortName: "",
        husbandId: husband.memberId,
        marrigeTime: "",
        marrigeStatus: husband.marrigeStatus,
        marrigeStart: husband.marrigeStart,
        wifeName2: '',
        associatedDisease: AssociatedDisease.Empty,
        classification: Classification.EMPTY,
        diseaseArabicName: '',
        diseaseDetails: '',
        diseaseLink: '',
        diseaseName: DiseaseName.EMPTY,
        diseaseNumber: 0,
        dnaChange: DnaChange.EMPTY,
        exonIntron: '',
        medicalGene: MedicalGene.Empty,
        inheritance: Inheritance.Empty,
        omim: 0,
        proteinChange: ProteinChange.EMPTY,
        zygosity: Zygosity.EMPTY,
        creationDate: HijriDate.now(),
        editDate: HijriDate.now(),
      );

      // Add to Firestore
      await firestore.collection('latestMembers').add(newWife.toJson());

      // Add to local list and graph
      husband.children.add(newWife);
      _addMemberToGraph(newWife);

      // Update UI
      update();
    } catch (e) {
      print('Error adding wife: $e');
    }
  }

  Future<void> fetchAllMembersAndShowStatistics() async {
    try {
      int maleCount = 0;
      int femaleCount = 0;
      int livingCount = 0;
      int deceasedCount = 0;
      int livingMales = 0;
      int deceasedMales = 0;
      int livingFemales = 0;
      int deceasedFemales = 0;

      void countMembers(FamilyMemberFirestore member) {
        if (member.sex == Enum.EMPTY) {
          maleCount++;
          if (member.lifeStatus == FamilyMemberFirestoreEnum.PURPLE) {
            livingCount++;
            livingMales++;
          } else if (member.lifeStatus == FamilyMemberFirestoreEnum.EMPTY) {
            deceasedCount++;
            deceasedMales++;
          }
        } else if (member.sex == Enum.PURPLE) {
          femaleCount++;
          if (member.lifeStatus == FamilyMemberFirestoreEnum.PURPLE) {
            livingCount++;
            livingFemales++;
          } else if (member.lifeStatus == FamilyMemberFirestoreEnum.EMPTY) {
            deceasedCount++;
            deceasedFemales++;
          }
        }
        // for (var child in member.children) {
        //   countMembers(child);
        // }
      }

      for (var member in allMembers.value) {
        countMembers(member);
      }
      Get.back();

      Get.dialog(
        Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('احصائيات'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('عدد الذكور: $maleCount'),
                Text('عدد الإناث: $femaleCount'),
                Text('عدد الأحياء: $livingCount'),
                Text('عدد المتوفين: $deceasedCount'),
                Text('عدد الذكور الأحياء: $livingMales'),
                Text('عدد الذكور المتوفين: $deceasedMales'),
                Text('عدد الإناث الأحياء: $livingFemales'),
                Text('عدد الإناث المتوفين: $deceasedFemales'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('تم'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error fetching all members: $e');
    }
  }

  Future<void> deleteMember(FamilyMemberFirestore member) async {
    try {
      if (member.children.isEmpty) {
        // Delete member from Firestore
        QuerySnapshot snapshot = await firestore
            .collection('latestMembers')
            .where('الرقم', isEqualTo: member.memberId)
            .get();

        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }

        // Remove member from local list and graph
        members.remove(member);
        graph.removeNode(graph.nodes.firstWhere((n) => n.key!.value == member));

        print("Member deleted: ${member.memberName}");
      } else {
        // If the member has children, just update the name
        QuerySnapshot snapshot = await firestore
            .collection('latestMembers')
            .where('الرقم', isEqualTo: member.memberId)
            .get();

        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.update({'memberName': 'Deleted'});
        }

        member.memberName = 'Deleted';
      }

      update();
    } catch (e) {
      print('Error deleting member: $e');
    }
  }

  Enum setGender(String? gender) {
    switch (gender) {
      case 'ذكر':
        return Enum.EMPTY;
      case 'أنثى':
        return Enum.PURPLE;
      default:
        return Enum.EMPTY;
    }
  }

  FamilyMemberFirestoreEnum setLifeStatus(String? status) {
    switch (status) {
      case 'حي يرزق':
        return FamilyMemberFirestoreEnum.PURPLE;
      case 'متوفي':
        return FamilyMemberFirestoreEnum.EMPTY;
      default:
        return FamilyMemberFirestoreEnum.UNAVAILABLE;
    }
  }

  Indigo setFromFamilyStatus(String? status) {
    switch (status) {
      case 'لا':
        return Indigo.EMPTY;
      case 'نعم':
        return Indigo.PURPLE;
      default:
        return Indigo.EMPTY;
    }
  }

  Future<void> editMember(
      FamilyMemberFirestore member, Map<String, dynamic> updatedFields) async {
    log("   member.sex = ${member.sex} ${updatedFields['sex']}  ${setGender(updatedFields['sex'])}");

    try {
      // Update member data locally
      updatedFields.forEach((key, value) {
        switch (key) {
          case 'memberName':
            member.memberName = value;
            break;
          case 'natId':
            member.natId = value;
            break;
          case 'fatherId':
            member.fatherId = value;
            break;
          case 'fatherName':
            member.fatherName = value;
            break;
          case 'motherId':
            member.motherId = value;
            break;
          case 'motherName':
            member.motherName = value;
            break;
          case 'phoneNumber':
            member.phoneNumber = value;
            break;
          case 'userEmail':
            member.userEmail = value;
            break;
          case 'education':
            member.education = emptyValues.reverse[value];
            break;
          case 'fromFamily':
            member.fromFamily = setFromFamilyStatus(value);
            break;
          case 'familyNumber':
            member.familyNumber = value;
            break;
          case 'notes':
            member.notes = value;
            break;
          case 'hijriBirthDate':
            member.hijriBirthDate = value;
            break;
          case 'birthLocation':
            member.birthLocation = value;
            break;
          case 'birthNotes':
            member.birthNotes = value;
            break;
          case 'deathLocation':
            member.deathLocation = stickyValues.reverse[value];
            break;
          case 'deathNotes':
            member.deathNotes = value;
            break;
          case 'work':
            member.work = purpleValues.reverse[value];
            break;
          case 'job':
            member.job = value;
            break;
          case 'lifeStatus':
            member.lifeStatus = setLifeStatus(value);
            break;
          case 'sex':
            member.sex = setGender(value);
            break;
          case 'hobbies':
            member.hobbies = value;
            break;
          case 'wifeName':
            member.wifeName = value;
            break;
          case 'wifeId':
            member.wifeId = value;
            break;
          case 'university':
            member.university = value;
            break;
          case 'marrigeId':
            member.marrigeId = value;
            break;
          case 'marrigeHijriDate':
            member.marrigeHijriDate = value;
            break;
          case 'wifeShortName':
            member.wifeShortName = value;
            break;
          case 'wifeHijriBirthdate':
            member.wifeHijriBirthdate = value;
            break;
          case 'wifeHijriDeathDate':
            member.wifeHijriDeathDate = value;
            break;
          case 'wifeLifeStatus':
            member.wifeLifeStatus = setLifeStatus(value);
            break;
          case 'birthdateHijri':
            member.birthdateHijri = value;
            break;
          case 'deathDateHijri':
            member.deathDateHijri = value;
            break;
          case 'endMarrige':
            member.endMarrige = value;
            break;
          case 'husbandLifeStatus':
            member.husbandLifeStatus = setLifeStatus(value);

            break;
          case 'husbandName':
            member.husbandName = value;
            break;
          case 'husbandShortName':
            member.husbandShortName = value;
            break;
          case 'husbandId':
            member.husbandId = value;
            break;
          case 'marrigeTime':
            member.marrigeTime = tentacledValues.reverse[value];
            break;
          case 'marrigeStatus':
            member.marrigeStatus = fluffyValues.reverse[value];
            break;
          case 'marrigeStart':
            member.marrigeStart = value;
            break;
          case 'wifeName2':
            member.wifeName2 = value;
            break;
          case 'associatedDisease':
            member.associatedDisease = associatedDiseaseValues.reverse[value];
            break;
          case 'classification':
            member.classification = classificationValues.reverse[value];
            break;
          case 'diseaseArabicName':
            member.diseaseArabicName = value;
            break;
          case 'diseaseDetails':
            member.diseaseDetails = value;
            break;
          case 'diseaseLink':
            member.diseaseLink = value;
            break;
          case 'diseaseName':
            member.diseaseName = diseaseNameValues.reverse[value];
            break;
          case 'diseaseNumber':
            member.diseaseNumber = value;
            break;
          case 'dnaChange':
            member.dnaChange = dnaChangeValues.reverse[value];
            break;
          case 'exonIntron':
            member.exonIntron = value;
            break;
          case 'medicalGene':
            member.medicalGene = medicalGeneValues.reverse[value];
            break;
          case 'inheritance':
            member.inheritance = inheritanceValues.reverse[value];
            break;
          case 'omim':
            member.omim = value;
            break;
          case 'proteinChange':
            member.proteinChange = proteinChangeValues.reverse[value];
            break;
          case 'zygosity':
            member.zygosity = zygosityValues.reverse[value];
            break;
          case 'creationDate':
            member.creationDate = value;
            break;
          case 'editDate':
            member.editDate = value;
            break;
          // Add more cases if there are additional fields
          default:
            print("Unknown field: $key");
        }
      });

      // Update member in Firestore
      try {
        // Fetch documents from Firestore
        QuerySnapshot snapshot = await firestore
            .collection('latestMembers')
            .where('الرقم', isEqualTo: member.memberId)
            .get();

        log("Number of matching documents: ${snapshot.docs.length}");

        // تحقق إذا كانت المستندات موجودة
        if (snapshot.docs.isEmpty) {
          log("No documents found for memberId: ${member.memberId}");
          return;
        }

        // استعراض أول مستند للتحقق من القيم
        log("First matching document - الرقم: ${snapshot.docs.first.get('الرقم')}");

        // تحديث كل مستند
        for (DocumentSnapshot doc in snapshot.docs) {
          log("Updating document with ID: ${doc.id}");

          // تنفيذ عملية التحديث
          await doc.reference.update({'الجنس': updatedFields['sex']}).then((v) {
            log("Document ${doc.id} updated successfully with fields: ${updatedFields}");
          }).catchError((e) {
            log("Failed to update document ${doc.id}. Error: $e");
          });

          DocumentSnapshot updatedDoc = await doc.reference.get();
          log("Updated document data: ${updatedDoc.data()}");
        }

        log("All documents updated successfully.");
      } catch (e) {
        log("Error occurred during Firestore update: $e");
      }

      // Refresh the UI
      update();
      print("Member updated successfully: ${member.memberName}");
    } catch (e) {
      print('Error updating member: $e');
    }
  }

  Future<void> submitEditRequest(
      FamilyMemberFirestore member, String reason) async {
    try {
      await firestore.collection('requests').add({
        'type': 'edit',
        'memberId': member.memberId,
        'memberName': member.memberName,
        'reason': reason,
        'requestedBy': userModel!.uid,
        'requestedByName': userModel!.username,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting edit request: $e');
      rethrow;
    }
  }

  Future<void> submitAddChildrenRequest(FamilyMemberFirestore member,
      String childrenNames, String additionalInfo) async {
    try {
      await firestore.collection('requests').add({
        'type': 'addChildren',
        'memberId': member.memberId,
        'memberName': member.memberName,
        'childrenNames': childrenNames,
        'additionalInfo': additionalInfo,
        'requestedBy': userModel!.uid,
        'requestedByName': userModel!.username,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting add children request: $e');
      rethrow;
    }
  }

  Future<void> submitAddWifeRequest(FamilyMemberFirestore member,
      String wifeName, String additionalInfo) async {
    try {
      await firestore.collection('requests').add({
        'type': 'addWife',
        'memberId': member.memberId,
        'memberName': member.memberName,
        'wifeName': wifeName,
        'additionalInfo': additionalInfo,
        'requestedBy': userModel!.uid,
        'requestedByName': userModel!.username,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting add wife request: $e');
      rethrow;
    }
  }

  Future<void> submitDeleteRequest(
      FamilyMemberFirestore member, String reason) async {
    try {
      await firestore.collection('requests').add({
        'type': 'delete',
        'memberId': member.memberId,
        'memberName': member.memberName,
        'reason': reason,
        'requestedBy': userModel!.uid,
        'requestedByName': userModel!.username,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting delete request: $e');
      rethrow;
    }
  }
}
