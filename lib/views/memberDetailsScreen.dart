import 'dart:developer';

import 'package:family_app_tree/controllers/family_member_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhijri/jHijri.dart';

import '../models/family_member_firestore.dart';

class MemberDetailsScreen extends StatelessWidget {
  final FamilyMemberFirestore member;

  const MemberDetailsScreen({required this.member});

  @override
  Widget build(BuildContext context) {
    // List<String> dateParts = "1446/5/28".split("/");

    // if (dateParts.length == 3) {
    //   int year = int.parse(dateParts[0]);
    //   int month = int.parse(dateParts[1]);
    //   int day = int.parse(dateParts[2]);
    //   print("month : $month day : $day year : $year");
    //   log(" getGregorianDate date :  ${getGregorianDate(month, year, day)}");
    // }

    log(" member gender :  ${member.sex} member lifeStatus :  ${member.lifeStatus}");

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الفرد'),
        centerTitle: true,
        backgroundColor: Color(0xffE8D0B4),
        elevation: 4,
        shape: RoundedRectangleBorder(
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
            child: Column(
              children: [
                GetBuilder<FamilyMemberController>(builder: (controller) {
                  return Stack(
                    children: [
                      member.image != null
                          ? Image.network(
                              member.image,
                              width: 200,
                              height: 200,
                            )
                          : Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/alabdelmohsen-family-app.appspot.com/o/profile_images%2FmemberDefault.png?alt=media&token=d8bc32df-8908-4380-b4e6-aa7c91879773',
                              width: 200,
                              height: 200,
                            ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        width: 50,
                        height: 50,
                        child: IconButton(
                            onPressed: () => controller.updateImage(
                                context, member.memberId, member),
                            icon: Icon(Icons.edit)),
                      ),
                    ],
                  );
                }),
                Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey.shade300),
                    verticalInside: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    // defaultColumnWidth: FlexColumnWidth(2),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    _buildTableRow('الاسم', member.memberName),
                    _buildTableRow('رقم الفرد', member.memberId.toString()),
                    _buildTableRow('الجنس', getGender(member.sex)),
                    _buildTableRow('الحياة', getLifeStatus(member.lifeStatus)),
                    _buildTableRow('رقم الهوية',
                        member.natId?.toString().replaceAll(".0", "")),
                    _buildTableRow('رقم الاب',
                        member.fatherId?.toString().replaceAll(".0", "")),
                    _buildTableRow('اسم الاب', member.fatherName),
                    _buildTableRow('رقم الام',
                        member.motherId?.toString().replaceAll(".0", "")),
                    _buildTableRow('اسم الام', member.motherName),
                    _buildTableRow(
                        'رقم الجوال', member.phoneNumber?.toString()),
                    _buildTableRow('ايميل', member.userEmail),
                    _buildTableRow('التعليم', getEducation(member.education)),
                    _buildTableRow(
                        'من الاسرة؟', getFromFamilyStatus(member.fromFamily)),
                    _buildTableRow('رقم العائلة',
                        member.familyNumber?.toString().replaceAll(".0", "")),
                    _buildTableRow('ملاحظات', member.notes),
                    _buildTableRow('تاريخ الولادة هجري', member.birthdateHijri),
                    _buildTableRow('تاريخ الولادة ميلادي', () {
                      if (member.birthdateHijri != null) {
                        List<String> dateParts =
                            member.birthdateHijri.toString().split("/");

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
                            print(
                                "برجاء ادخال التاريخ الهجري بصيغة  MM/DD/YYYY");
                          }
                          return "غير متوفر";
                        }
                      } else {
                        return "غير متوفر";
                      }
                    }()),
                    _buildTableRow('مكان الولادة', member.birthLocation),
                    _buildTableRow('ملاحظات الولادة', member.birthNotes),
                    _buildTableRow('المهنة',
                        member.work != null ? getJob(member.work) : null),
                    _buildTableRow('الوظيفة', member.job),
                    _buildTableRow('هوايات', member.hobbies),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow('اسم الزوجة', member.wifeName),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow('اسم الزوج', member.husbandName),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow(
                          'حياة الزوجة',
                          member.wifeLifeStatus != null
                              ? getLifeStatus(member.wifeLifeStatus)
                              : null),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow(
                          'حياة الزوج',
                          member.husbandLifeStatus != null
                              ? getLifeStatus(member.husbandLifeStatus)
                              : null),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow(
                          'حالة الزواج',
                          member.marrigeStatus != null
                              ? getMarriageStatus(member.marrigeStatus)
                              : null),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow(
                          'مدة الزواج',
                          member.marrigeTime != null
                              ? getMarriageDuration(member.marrigeTime)
                              : null),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow('رقم الزواج',
                          member.marrigeId?.toString().replaceAll(".0", "")),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow(
                          'تاريخ الزواج هجري', member.marrigeHijriDate),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow(
                          'تاريخ الزواج ميلادي',
                          member.marrigeHijriDate != null &&
                                  member.marrigeHijriDate
                                          .toString()
                                          .split("/")
                                          .length !=
                                      1 &&
                                  member.marrigeHijriDate
                                      .toString()
                                      .split("/")
                                      .isNotEmpty
                              ? getGregorianDate(
                                  int.parse(member.marrigeHijriDate
                                      .toString()
                                      .split("/")[1]
                                      .toString()),
                                  int.parse(member.marrigeHijriDate
                                      .toString()
                                      .split("/")[0]
                                      .toString()),
                                  int.parse(member.marrigeHijriDate
                                      .toString()
                                      .split("/")[2]
                                      .toString()))
                              : null),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow('رقم الزوج',
                          member.husbandId?.toString().replaceAll(".0", "")),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow('رقم الزوجه',
                          member.wifeId?.toString().replaceAll(".0", "")),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow('بداية الزواج', member.marrigeStart),
                    if (member.marrigeStatus == Fluffy.PURPLE)
                      _buildTableRow('نهاية الزواج', member.endMarrige),
                    _buildTableRow('تاريخ الوفاة هجري', member.deathDateHijri),
                    _buildTableRow('تاريخ الوفاة ميلادي', () {
                      if (member.deathDateHijri != null) {
                        List<String> dateParts =
                            member.deathDateHijri.toString().split("/");

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
                            print(
                                "برجاء ادخال التاريخ الهجري بصيغة  MM/DD/YYYY");
                          }
                          return "غير متوفر";
                        }
                      } else {
                        return "غير متوفر";
                      }
                    }()),
                    _buildTableRow(
                        'مكان الوفاة',
                        member.deathLocation != null
                            ? getPlaceOfDeath(member.deathLocation)
                            : null),
                    _buildTableRow('ملاحظات الوفاة', member.deathNotes),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String title, String? value) {
    return TableRow(
      children: [
        Container(
          color: Color(0xffF5F5F5),
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Text(
            value ?? 'غير متوفر',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // Dummy methods for data transformation, replace with actual implementations
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
        return 'غير متوفر';
    }
  }

  String getMarriageStatus(Fluffy status) {
    switch (status) {
      case Fluffy.EMPTY:
        return 'وفاة';
      case Fluffy.FLUFFY:
        return 'طلاق';
      case Fluffy.PURPLE:
        return 'زواج';
      default:
        return '';
    }
  }

  String getMarriageDuration(Tentacled duration) {
    switch (duration) {
      case Tentacled.EMPTY:
        return 'غير محدد';
      case Tentacled.THE_2437:
        return 'مدة محددة';
      default:
        return '';
    }
  }

  String getEducation(Empty? education) {
    switch (education) {
      case Empty.AMBITIOUS:
        return 'دبلوم';
      case Empty.CUNNING:
        return 'ثانوي';
      case Empty.EMPTY:
        return 'غير متعلم';
      case Empty.FLUFFY:
        return 'تعليم غير منهجي';
      case Empty.HILARIOUS:
        return 'متوسط';
      case Empty.INDECENT:
        return 'ماجستير';
      case Empty.INDIGO:
        return 'دكتوراة';
      case Empty.PURPLE:
        return 'طفل';
      case Empty.STICKY:
        return 'ابتدائي';
      case Empty.TENTACLED:
        return 'بكالوريوس';
      default:
        return '';
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

  String getPlaceOfDeath(Sticky place) {
    switch (place) {
      case Sticky.EMPTY:
        return 'ايران - قم';
      case Sticky.FLUFFY:
        return 'المدينة المنورة - جنة البقيع';
      case Sticky.INDECENT:
        return 'العراق - النجف';
      case Sticky.INDIGO:
        return 'مقبرة البطالية';
      case Sticky.PURPLE:
        return 'مكة - مقبرة فخ';
      case Sticky.STICKY:
        return 'مقبرة القارة';
      case Sticky.TENTACLED:
        return 'ايران - مشهد';
      default:
        return '';
    }
  }

  String getJob(Purple job) {
    switch (job) {
      case Purple.EMPTY:
        return 'عالم دين';
      case Purple.FLUFFY:
        return 'التعليم';
      case Purple.HILARIOUS:
        return 'أخرى';
      case Purple.INDECENT:
        return 'موظف حكومي';
      case Purple.INDIGO:
        return 'الصحة';
      case Purple.PURPLE:
        return 'أعمال حرة';
      case Purple.STICKY:
        return 'قطاع خاص';
      case Purple.TENTACLED:
        return 'موظف أرامكو';
      default:
        return '';
    }
  }

  String getAssociatedDisease(AssociatedDisease disease) {
    switch (disease) {
      case AssociatedDisease.HEMOLYTIC_ANEMIA_6_PD_DEFICIENT_FAVISM:
        return 'Hemolytic Anemia, 6PDDeficient (Favism)';
      case AssociatedDisease.PROXIMAL_MYOPATHY_AND_OPHTHALMOPLEGIA:
        return 'Proximal myopathy and Ophthalmoplegia';
      case AssociatedDisease.SICKLE_CELL_ANEMIA_THALASSEMIA_BETA:
        return 'Sickle cell anemia; Thalassemia, beta';
      default:
        return '';
    }
  }

  String getClassification(Classification classification) {
    switch (classification) {
      case Classification.MPS_VI:
        return 'MPS VI';
      case Classification.PATHOGENIC:
        return 'Pathogenic';
      default:
        return '';
    }
  }

  String getDiseaseName(DiseaseName diseaseName) {
    switch (diseaseName) {
      case DiseaseName.CANCER:
        return 'Cancer';
      case DiseaseName.CEREBRAL_PALSY_CP:
        return 'Cerebral palsy (CP)';
      case DiseaseName.HEMOLYTIC_ANEMIA_G6_PD_DEFICIENT_FAVISM:
        return 'Hemolytic Anemia, G6PDDeficient (Favism)';
      case DiseaseName.MUCOPOLYSACCHARIDOSIS_TYPE_VI:
        return 'Mucopolysaccharidosis type VI';
      case DiseaseName.OPHTHALMOPLEGIA_AND_MYOPATHY_PROXIMAL:
        return 'Ophthalmoplegia and Myopathy Proximal';
      case DiseaseName.SICKLE_CELL_ANEMIA_THALASSEMIA_BETA:
        return 'Sickle cell anemia; Thalassemia, beta';
      default:
        return '';
    }
  }

  String getDnaChange(DnaChange dnaChange) {
    switch (dnaChange) {
      case DnaChange.C_20_A_T:
        return 'c.20A>T';
      case DnaChange.C_45371_G_A:
        return 'c.4537+1G>A';
      case DnaChange.C_563_C_T:
        return 'c.563C>T';
      default:
        return '';
    }
  }

  String getMedicalGene(MedicalGene gene) {
    switch (gene) {
      case MedicalGene.G6_PD:
        return 'G6PD';
      case MedicalGene.HBB:
        return 'HBB';
      case MedicalGene.MAROTEAUX_LAMY_SYNDROME:
        return 'Maroteaux–Lamy syndrome';
      case MedicalGene.MYH2:
        return 'MYH2';
      default:
        return '';
    }
  }

  String getInheritance(Inheritance inheritance) {
    switch (inheritance) {
      case Inheritance.AUTOSOMAL_RECESSIVE:
        return 'Autosomal Recessive';
      case Inheritance.AUTOSOMAL_RECESSIVE_AUTOSOMAL_DOMINANT:
        return 'Autosomal Recessive; Autosomal Dominant';
      case Inheritance.X_LINKED:
        return 'X- linked';
      default:
        return '';
    }
  }

  String getProteinChange(ProteinChange proteinChange) {
    switch (proteinChange) {
      case ProteinChange.EMPTY:
        return '-';
      case ProteinChange.P_GLU7_VAL:
        return 'p.Glu7Val';
      case ProteinChange.P_SER188_PHE:
        return 'p.Ser188Phe';
      default:
        return '';
    }
  }

  String getZygosity(Zygosity zygosity) {
    switch (zygosity) {
      case Zygosity.HETEROZYGOUS:
        return 'Heterozygous';
      case Zygosity.HOMOZYGOUS:
        return 'Homozygous';
      default:
        return '';
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

      return "${gDate.day} / ${gDate.month} / ${gDate.year}";
    } catch (e) {
      print("Error in date conversion: $e");
      return "Invalid date";
    }
  }
}
