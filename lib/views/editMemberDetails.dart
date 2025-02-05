import 'dart:developer';

import 'package:family_app_tree/controllers/family_member_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhijri/_src/_jHijri.dart';

import '../models/family_member_firestore.dart';

class EditMemberDetails extends StatefulWidget {
  final FamilyMemberFirestore member;

  EditMemberDetails({required this.member});

  @override
  _EditMemberDetailsState createState() => _EditMemberDetailsState();
}

class _EditMemberDetailsState extends State<EditMemberDetails> {
  final _formKey = GlobalKey<FormState>();

  FamilyMemberController controller = Get.isRegistered<FamilyMemberController>()
      ? Get.find<FamilyMemberController>()
      : Get.put(FamilyMemberController());

  late TextEditingController _memberNameController;
  late TextEditingController _natIdController;
  late TextEditingController _fatherIdController;
  late TextEditingController _fatherNameController;
  late TextEditingController _motherIdController;
  late TextEditingController _motherNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _userEmailController;
  late TextEditingController _notesController;
  late TextEditingController _birthdateHijriController;
  late TextEditingController _birthLocationController;
  late TextEditingController _birthNotesController;
  late TextEditingController _deathLocationController;
  late TextEditingController _deathNotesController;
  late TextEditingController _jobController;
  late TextEditingController _hobbiesController;
  late TextEditingController _wifeNameController;
  late TextEditingController _husbandNameController;
  late TextEditingController _marrigeIdController;
  late TextEditingController _marrigeHijriDateController;
  late TextEditingController _marrigeStartController;
  late TextEditingController _endMarrigeController;
  late TextEditingController _deathDateHijriController;

  late TextEditingController _fromFamilyController;
  late TextEditingController _familyNoController;
  late TextEditingController _husbandLifeStatue;
  late TextEditingController _memberIdController;
  late TextEditingController _birthdateController;
  // late TextEditingController _genderController;
  // late TextEditingController _statusController;

  late String _gender =
      getGender(widget.member.sex); // Variable to store selected gender
  late String _status = getLifeStatus(
      widget.member.lifeStatus); // Variable to store selected status

  @override
  void initState() {
    super.initState();
    _memberNameController =
        TextEditingController(text: widget.member.memberName);
    _natIdController = TextEditingController(
        text: widget.member.natId?.toString().replaceAll(".0", ""));
    _fatherIdController = TextEditingController(
        text: widget.member.fatherId?.toString().replaceAll(".0", ""));
    _fatherNameController =
        TextEditingController(text: widget.member.fatherName);
    _motherIdController = TextEditingController(
        text: widget.member.motherId?.toString().replaceAll(".0", ""));
    _motherNameController =
        TextEditingController(text: widget.member.motherName);
    _phoneNumberController =
        TextEditingController(text: widget.member.phoneNumber?.toString());
    _userEmailController = TextEditingController(text: widget.member.userEmail);
    _notesController = TextEditingController(text: widget.member.notes);
    _birthdateHijriController =
        TextEditingController(text: widget.member.birthdateHijri);
    _birthLocationController =
        TextEditingController(text: widget.member.birthLocation);
    _birthNotesController =
        TextEditingController(text: widget.member.birthNotes);
    _deathLocationController =
        TextEditingController(text: widget.member.deathLocation.toString());
    _deathNotesController =
        TextEditingController(text: widget.member.deathNotes);
    _jobController = TextEditingController(text: widget.member.job);
    _hobbiesController = TextEditingController(text: widget.member.hobbies);
    _wifeNameController = TextEditingController(text: widget.member.wifeName);
    _husbandNameController =
        TextEditingController(text: widget.member.husbandName);
    _marrigeIdController = TextEditingController(
        text: widget.member.marrigeId?.toString().replaceAll(".0", ""));
    _marrigeHijriDateController =
        TextEditingController(text: widget.member.marrigeHijriDate);
    _marrigeStartController =
        TextEditingController(text: widget.member.marrigeStart);
    _endMarrigeController =
        TextEditingController(text: widget.member.endMarrige);
    _deathDateHijriController =
        TextEditingController(text: widget.member.deathDateHijri);

    _familyNoController =
        TextEditingController(text: widget.member.familyNumber.toString());
    _husbandLifeStatue = TextEditingController(
        text: getLifeStatus(widget.member.husbandLifeStatus));
    _memberIdController =
        TextEditingController(text: widget.member.memberId.toString());
    _fromFamilyController = TextEditingController(
        text: getFromFamilyStatus(widget.member.fromFamily));
    _birthdateController = TextEditingController(text: getBirthDate());

    // _genderController =
    //     TextEditingController(text: getGender(widget.member.sex));
    // _statusController =
    //     TextEditingController(text: getLifeStatus(widget.member.lifeStatus));

    // print("gender : ${widget.member.sex} status : ${widget.member.lifeStatus}");
    // print(
    //     "object ${getGender(widget.member.sex)} ${getLifeStatus(widget.member.lifeStatus)} ");

    _gender = getGender(widget.member.sex);
    _status = getLifeStatus(widget.member.lifeStatus);
    log("gender : ${_gender} status : ${_status}");
    // log("gender : ${setGender(_gender)} status : ${setLifeStatus(_status)}");
  }

  String getBirthDate() {
    if (_birthdateHijriController.text.isNotEmpty) {
      List<String> dateParts = _birthdateHijriController.text.split("/");
      log("dateParts : $dateParts");

      if (dateParts.length == 3) {
        try {
          int year = int.parse(dateParts[0]);
          int month = int.parse(dateParts[1]);
          int day = int.parse(dateParts[2]);

          return getGregorianDate(month, year, day);
        } catch (e) {
          if (kDebugMode) {
            print("Error parsing date components: $e");
          }
          return "Invalid date";
        }
      } else {
        if (kDebugMode) {
          print("برجاء ادخال التاريخ الهجري بصيغة  MM/DD/YYYY");
        }
        return "غير متوفر";
      }
    } else {
      return "غير متوفر";
    }
  }

  String getGregorianDate(int hijriMonth, int hijriYear, int hijriDay) {
    try {
      final jHijri =
          JHijri(fMonth: hijriMonth, fYear: hijriYear, fDay: hijriDay);

      // Debug prints for Hijri date
      print("Full Hijri Date: ${jHijri.fullDate}");
      print(
          "Passed Hijri Date: Month: $hijriMonth, Year: $hijriYear, Day: $hijriDay");

      // Extract Gregorian date from JHijri conversion
      final gDate = jHijri.dateTime;

      // Debug print for converted Gregorian date
      print(
          "Converted Gregorian Date: ${gDate.day} / ${gDate.month} / ${gDate.year}");
      _birthdateController.text =
          "${gDate.day} / ${gDate.month} / ${gDate.year}";
      return "${gDate.day} / ${gDate.month} / ${gDate.year}";
    } catch (e) {
      print("Error in date conversion: $e");
      return "Invalid date";
    }
  }

  String getFromFamilyStatus(Indigo? status) {
    switch (status) {
      case Indigo.EMPTY:
        return 'لا';
      case Indigo.PURPLE:
        return 'نعم';
      default:
        return '';
    }
  }

  String getLifeStatus(FamilyMemberFirestoreEnum? status) {
    switch (status) {
      case FamilyMemberFirestoreEnum.PURPLE:
        return 'حي يرزق';
      case FamilyMemberFirestoreEnum.EMPTY:
        return 'متوفي';
      default:
        return '';
    }
  }

  String getGender(Enum? gender) {
    switch (gender) {
      case Enum.EMPTY:
        return 'ذكر';
      case Enum.PURPLE:
        return 'أنثى';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _memberNameController.dispose();
    _natIdController.dispose();
    _fatherIdController.dispose();
    _fatherNameController.dispose();
    _motherIdController.dispose();
    _motherNameController.dispose();
    _phoneNumberController.dispose();
    _userEmailController.dispose();
    _notesController.dispose();
    _birthdateHijriController.dispose();
    _birthLocationController.dispose();
    _birthNotesController.dispose();
    _deathLocationController.dispose();
    _deathNotesController.dispose();
    _jobController.dispose();
    _hobbiesController.dispose();
    _wifeNameController.dispose();
    _husbandNameController.dispose();
    _marrigeIdController.dispose();
    _marrigeHijriDateController.dispose();
    _marrigeStartController.dispose();
    _endMarrigeController.dispose();
    _deathDateHijriController.dispose();
    _fromFamilyController.dispose();
    _familyNoController.dispose();
    _husbandLifeStatue.dispose();
    super.dispose();
  }

  Future<void> _saveEdits() async {
    Map<String, dynamic> updatedFields = {};
    updatedFields['memberName'] = _memberNameController.text;
    updatedFields['natId'] = _natIdController.text.isNotEmpty
        ? int.tryParse(_natIdController.text)
        : "غير متوفر";
    updatedFields['fatherId'] = _fatherIdController.text.isNotEmpty
        ? int.tryParse(_fatherIdController.text)
        : "غير متوفر";
    updatedFields['fatherName'] = _fatherNameController.text;
    updatedFields['motherId'] = _motherIdController.text.isNotEmpty
        ? int.tryParse(_motherIdController.text)
        : "غير متوفر";
    updatedFields['motherName'] = _motherNameController.text;
    updatedFields['phoneNumber'] = _phoneNumberController.text.isNotEmpty
        ? int.tryParse(_phoneNumberController.text)
        : "غير متوفر";
    updatedFields['userEmail'] = _userEmailController.text;
    updatedFields['notes'] = _notesController.text;
    updatedFields['birthdateHijri'] = _birthdateHijriController.text;
    updatedFields['birthLocation'] = _birthLocationController.text;
    updatedFields['birthNotes'] = _birthNotesController.text;
    updatedFields['deathLocation'] = _deathLocationController.text;
    updatedFields['deathNotes'] = _deathNotesController.text;
    updatedFields['job'] = _jobController.text;
    updatedFields['hobbies'] = _hobbiesController.text;
    updatedFields['wifeName'] = _wifeNameController.text;
    updatedFields['husbandName'] = _husbandNameController.text;
    updatedFields['marrigeId'] = _marrigeIdController.text.isNotEmpty
        ? int.tryParse(_marrigeIdController.text)
        : "غير متوفر";
    updatedFields['marrigeHijriDate'] = _marrigeHijriDateController.text;
    updatedFields['marrigeStart'] = _marrigeStartController.text;
    updatedFields['endMarrige'] = _endMarrigeController.text;
    updatedFields['deathDateHijri'] = _deathDateHijriController.text;

    updatedFields['fromFamily'] = _fromFamilyController.text;
    updatedFields['familyNumber'] = _familyNoController.text;
    updatedFields['husbandLifeStatus'] = _husbandLifeStatue.text;
    updatedFields['sex'] = _gender;
    updatedFields['lifeStatus'] = _status;

    // Add selected status
    await controller.editMember(widget.member, updatedFields);
    await controller.fetchMembers();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل تفاصيل الفرد'),
        centerTitle: true,
        backgroundColor: const Color(0xffE8D0B4),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField('الاسم', _memberNameController),
                  Row(
                    children: [
                      const Text('الجنس:'),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('ذكر'),
                          value: 'ذكر',
                          contentPadding: const EdgeInsets.all(0),
                          groupValue: _gender,
                          onChanged: (value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('أنثى'),
                          value: 'أنثى',
                          contentPadding: const EdgeInsets.all(0),
                          groupValue: _gender,
                          onChanged: (value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  // Status Radio Buttons
                  Row(
                    children: [
                      const Text('الحياة:'),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('حي يرزق'),
                          contentPadding: const EdgeInsets.all(0),
                          value: 'حي يرزق',
                          groupValue: _status,
                          onChanged: (value) {
                            setState(() {
                              _status = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('متوفي'),
                          value: 'متوفي',
                          groupValue: _status,
                          contentPadding: const EdgeInsets.all(0),
                          onChanged: (value) {
                            setState(() {
                              _status = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  _buildTextField('رقم الهوية', _natIdController),
                  _buildTextField('رقم الاب', _fatherIdController),
                  _buildTextField('اسم الاب', _fatherNameController),
                  _buildTextField('رقم الام', _motherIdController),
                  _buildTextField('اسم الام', _motherNameController),

                  //
                  _buildTextField('من الأسرة', _fromFamilyController),
                  _buildTextField(' رقم العائلة', _familyNoController),
                  _buildTextField('رقم الجوال', _phoneNumberController),
                  _buildTextField('ايميل', _userEmailController),
                  _buildTextField('ملاحظات', _notesController),
                  _buildTextField("رقم الفرد", _memberIdController),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _birthdateHijriController,
                      enabled: true,
                      decoration: InputDecoration(
                        labelText: "تاريخ الولاده الهجري",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        _birthdateHijriController.text = value;
                        getBirthDate();
                        setState(() {});
                      },
                      onSaved: (value) {
                        _birthdateHijriController.text = value!;
                        getBirthDate();
                        setState(() {});
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _birthdateController,
                      enabled: true,
                      decoration: InputDecoration(
                        labelText: "تاريخ الولاده الميلادي",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  _buildTextField('مكان الولادة', _birthLocationController),
                  _buildTextField('ملاحظات الولادة', _birthNotesController),
                  _buildTextField('الوظيفة', _jobController),
                  _buildTextField('هوايات', _hobbiesController),
                  _buildTextField('اسم الزوجة', _wifeNameController),
                  _buildTextField('اسم الزوج', _husbandNameController),
                  _buildTextField('حياة الزوج ', _husbandLifeStatue),
                  _buildTextField('رقم الزواج', _marrigeIdController),
                  _buildTextField(
                      'تاريخ الزواج هجري', _marrigeHijriDateController),
                  _buildTextField('بداية الزواج', _marrigeStartController),
                  _buildTextField('نهاية الزواج', _endMarrigeController),

                  if (_status == "متوفي")
                    Column(
                      children: [
                        _buildTextField(
                            'تاريخ الوفاة هجري', _deathDateHijriController),
                        _buildTextField(
                            'مكان الوفاة', _deathLocationController),
                        _buildTextField(
                            'ملاحظات الوفاة', _deathNotesController),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Gender Radio Buttons

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveEdits,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffE8D0B4),
                    ),
                    child: const Text('حفظ التعديلات'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال $label';
          }
          return null;
        },
      ),
    );
  }
}
