import 'dart:convert';

List<FamilyMemberFirestore> familyMemberFirestoreFromJson(String str) =>
    List<FamilyMemberFirestore>.from(
        json.decode(str).map((x) => FamilyMemberFirestore.fromJson(x)));

String familyMemberFirestoreToJson(List<FamilyMemberFirestore> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FamilyMemberFirestore {
  int memberId;
  var memberName;
  var natId;
  dynamic fatherId;
  var fatherName;
  var image;
  var motherId;
  var motherName;
  var phoneNumber;
  var userEmail;
  var education;
  var fromFamily;
  var familyNumber;
  var notes;
  var hijriBirthDate;
  var birthLocation;
  var birthNotes;
  var deathLocation;
  var deathNotes;
  var work;
  var job;
  var lifeStatus;
  var sex;
  var hobbies;
  var wifeName;
  var wifeId;
  var university;
  var marrigeId;
  var marrigeHijriDate;
  var wifeShortName;
  var wifeHijriBirthdate;
  var wifeHijriDeathDate;
  var wifeLifeStatus;
  var birthdateHijri;
  var deathDateHijri;
  var endMarrige;
  var husbandLifeStatus;
  var husbandName;
  var husbandShortName;
  var husbandId;
  var marrigeTime;
  var marrigeStatus;
  var marrigeStart;
  var wifeName2;
  var associatedDisease;
  var classification;
  var diseaseArabicName;
  var diseaseDetails;
  var diseaseLink;
  var diseaseName;
  var diseaseNumber;
  var dnaChange;
  var exonIntron;
  var medicalGene;
  var inheritance;
  var omim;
  var proteinChange;
  var zygosity;
  var creationDate;
  var editDate;
  List<FamilyMemberFirestore> children = [];

  FamilyMemberFirestore({
    required this.memberId,
    required this.memberName,
    this.natId = 0,
    required this.fatherId,
    required this.fatherName,
    this.motherId = 0,
    this.motherName = '',
    required this.phoneNumber,
    this.userEmail = '',
    required this.education,
    required this.fromFamily,
    this.familyNumber = 0,
    this.notes = '',
    this.hijriBirthDate = '',
    this.birthLocation = '',
    this.birthNotes = '',
    required this.deathLocation,
    this.deathNotes = '',
    required this.work,
    this.job = '',
    required this.lifeStatus,
    required this.sex,
    this.image,
    this.hobbies = '',
    this.wifeName = '',
    this.wifeId = '',
    this.university = '',
    this.marrigeId = 0,
    this.marrigeHijriDate = '',
    this.wifeShortName = '',
    this.wifeHijriBirthdate = '',
    this.wifeHijriDeathDate = '',
    required this.wifeLifeStatus,
    this.birthdateHijri = '',
    this.deathDateHijri = '',
    this.endMarrige = '',
    required this.husbandLifeStatus,
    this.husbandName = '',
    this.husbandShortName = '',
    this.husbandId = 0,
    required this.marrigeTime,
    required this.marrigeStatus,
    this.marrigeStart = '',
    this.wifeName2 = '',
    required this.associatedDisease,
    required this.classification,
    this.diseaseArabicName = '',
    this.diseaseDetails = '',
    this.diseaseLink = '',
    required this.diseaseName,
    this.diseaseNumber = 0,
    required this.dnaChange,
    this.exonIntron = '',
    required this.medicalGene,
    required this.inheritance,
    this.omim = 0,
    required this.proteinChange,
    required this.zygosity,
    required this.creationDate,
    required this.editDate,
  });

  factory FamilyMemberFirestore.fromJson(Map<String, dynamic> json) =>
      FamilyMemberFirestore(
        memberId: json["الرقم"],
        memberName: json["الاسم"],
        natId: json["رقم الهوية"],
        fatherId: json["رقم الاب"],
        fatherName: json["اسم الاب"],
        motherId: json["رقم الام"],
        motherName: json["اسم الام"],
        image: json['الصورة'],
        phoneNumber: json["رقم الجوال"],
        userEmail: json["ايميل"],
        education: emptyValues.map[json["التعليم"]],
        fromFamily: indigoValues.map[json["من الاسرة؟"]],
        familyNumber: json["رقم العائلة"],
        notes: json["ملاحظات"],
        hijriBirthDate: json["تاريخ الولادة ميلادي"],
        birthLocation: json["مكان الولادة"],
        birthNotes: json["ملاحظات الولادة"],
        deathLocation: stickyValues.map[json["مكان الوفاة"]],
        deathNotes: json["ملاحظات الوفاة"],
        work: purpleValues.map[json["المهنة"]],
        job: json["الوظيفة"],
        lifeStatus: familyMemberFirestoreEnumValues.map[json["الحياة"]],
        sex: enumValues.map[json["الجنس"]],
        hobbies: json["هوايات"],
        wifeName: json["اسم الزوجة"],
        wifeId: json["رقم الزوجة"],
        university: json["الجامعة"],
        marrigeId: json["رقم الزواج"],
        marrigeHijriDate: json["تاريخ الزواج هجري"],
        wifeShortName: json["اسم الزوجه القصير"],
        wifeHijriBirthdate: json["تاريخ ميلاد الزوجه هجري"],
        wifeHijriDeathDate: json["تاريخ وفاة الزوجه هجري"],
        wifeLifeStatus:
            familyMemberFirestoreEnumValues.map[json["حياة الزوجة"]],
        birthdateHijri: json["تاريخ الولادة هجري"],
        deathDateHijri: json["تاريخ الوفاة هجري"],
        endMarrige: json["نهاية الزواج"],
        husbandLifeStatus:
            familyMemberFirestoreEnumValues.map[json["حياة الزوج"]],
        husbandName: json["اسم الزوج"],
        husbandShortName: json["اسم الزوج القصير"],
        husbandId: json["رقم الزوج"],
        marrigeTime: tentacledValues.map[json["مدة الزواج"]],
        marrigeStatus: fluffyValues.map[json["حالة الزواج"]],
        marrigeStart: json["بداية الزواج"],
        wifeName2: json["اسم الزوجه"],
        associatedDisease:
            associatedDiseaseValues.map[json["Associated Disease"]],
        classification: classificationValues.map[json["Classification"]],
        diseaseArabicName: json["Disease Arabic Name"],
        diseaseDetails: json["Disease Details"],
        diseaseLink: json["Disease Link"],
        diseaseName: diseaseNameValues.map[json["Disease Name"]],
        diseaseNumber: json["Disease Number"],
        dnaChange: dnaChangeValues.map[json["DNA Change"]],
        exonIntron: json["Exon Intron"],
        medicalGene: medicalGeneValues.map[json["MedicalGene"]],
        inheritance: inheritanceValues.map[json["Inheritance"]],
        omim: json["OMIM"],
        proteinChange: proteinChangeValues.map[json["Protein Change"]],
        zygosity: zygosityValues.map[json["Zygosity"]],
        creationDate: json["تاريخ الإنشاء"],
        editDate: json["تاريخ التعديل"],
      );

  Map<String, dynamic> toJson() => {
        "الرقم": memberId,
        "الاسم": memberName,
        "رقم الهوية": natId,
        "الصورة": image,
        "رقم الاب": fatherId,
        "اسم الاب": fatherName,
        "رقم الام": motherId,
        "اسم الام": motherName,
        "رقم الجوال": phoneNumber,
        "ايميل": userEmail,
        "التعليم": emptyValues.reverse[education],
        "من الاسرة؟": indigoValues.reverse[fromFamily],
        "رقم العائلة": familyNumber,
        "ملاحظات": notes,
        "تاريخ الولادة ميلادي": hijriBirthDate,
        "مكان الولادة": birthLocation,
        "ملاحظات الولادة": birthNotes,
        "مكان الوفاة": stickyValues.reverse[deathLocation],
        "ملاحظات الوفاة": deathNotes,
        "المهنة": purpleValues.reverse[work],
        "الوظيفة": job,
        "الحياة": familyMemberFirestoreEnumValues.reverse[lifeStatus],
        "الجنس": enumValues.reverse[sex],
        "هوايات": hobbies,
        "اسم الزوجة": wifeName,
        "رقم الزوجة": wifeId,
        "الجامعة": university,
        "رقم الزواج": marrigeId,
        "تاريخ الزواج هجري": marrigeHijriDate,
        "اسم الزوجه القصير": wifeShortName,
        "تاريخ ميلاد الزوجه هجري": wifeHijriBirthdate,
        "تاريخ وفاة الزوجه هجري": wifeHijriDeathDate,
        "حياة الزوجة": familyMemberFirestoreEnumValues.reverse[wifeLifeStatus],
        "تاريخ الولادة هجري": birthdateHijri,
        "تاريخ الوفاة هجري": deathDateHijri,
        "نهاية الزواج": endMarrige,
        "حياة الزوج":
            familyMemberFirestoreEnumValues.reverse[husbandLifeStatus],
        "اسم الزوج": husbandName,
        "اسم الزوج القصير": husbandShortName,
        "رقم الزوج": husbandId,
        "رقم الزوجه": wifeId,
        "مدة الزواج": tentacledValues.reverse[marrigeTime],
        "حالة الزواج": fluffyValues.reverse[marrigeStatus],
        "بداية الزواج": marrigeStart,
        "اسم الزوجه": wifeName2,
        "Associated Disease":
            associatedDiseaseValues.reverse[associatedDisease],
        "Classification": classificationValues.reverse[classification],
        "Disease Arabic Name": diseaseArabicName,
        "Disease Details": diseaseDetails,
        "Disease Link": diseaseLink,
        "Disease Name": diseaseNameValues.reverse[diseaseName],
        "Disease Number": diseaseNumber,
        "DNA Change": dnaChangeValues.reverse[dnaChange],
        "Exon Intron": exonIntron,
        "MedicalGene": medicalGeneValues.reverse[medicalGene],
        "Inheritance": inheritanceValues.reverse[inheritance],
        "OMIM": omim,
        "Protein Change": proteinChangeValues.reverse[proteinChange],
        "Zygosity": zygosityValues.reverse[zygosity],
        "تاريخ الإنشاء": creationDate,
        "تاريخ التعديل": editDate,
        "children": List<dynamic>.from(children.map((x) => x.toJson())),
      };
}

enum AssociatedDisease {
  Empty,
  HEMOLYTIC_ANEMIA_6_PD_DEFICIENT_FAVISM,
  PROXIMAL_MYOPATHY_AND_OPHTHALMOPLEGIA,
  SICKLE_CELL_ANEMIA_THALASSEMIA_BETA
}

final associatedDiseaseValues = EnumValues({
  "": AssociatedDisease.Empty,
  "Hemolytic Anemia, 6PDDeficient (Favism)":
      AssociatedDisease.HEMOLYTIC_ANEMIA_6_PD_DEFICIENT_FAVISM,
  "Proximal myopathy and Ophthalmoplegia":
      AssociatedDisease.PROXIMAL_MYOPATHY_AND_OPHTHALMOPLEGIA,
  "Sickle cell anemia; Thalassemia, beta":
      AssociatedDisease.SICKLE_CELL_ANEMIA_THALASSEMIA_BETA
});

enum Classification { EMPTY, MPS_VI, PATHOGENIC }

final classificationValues = EnumValues({
  "Empty": Classification.EMPTY,
  "MPS VI": Classification.MPS_VI,
  "Pathogenic": Classification.PATHOGENIC
});

enum Enum { EMPTY, PURPLE }

final enumValues = EnumValues({"ذكر": Enum.EMPTY, "أنثى": Enum.PURPLE});

enum DiseaseName {
  EMPTY,
  CANCER,
  CEREBRAL_PALSY_CP,
  HEMOLYTIC_ANEMIA_G6_PD_DEFICIENT_FAVISM,
  MUCOPOLYSACCHARIDOSIS_TYPE_VI,
  OPHTHALMOPLEGIA_AND_MYOPATHY_PROXIMAL,
  SICKLE_CELL_ANEMIA_THALASSEMIA_BETA
}

final diseaseNameValues = EnumValues({
  "": DiseaseName.EMPTY,
  "Cancer": DiseaseName.CANCER,
  "Cerebral palsy (CP)": DiseaseName.CEREBRAL_PALSY_CP,
  "Hemolytic Anemia, G6PDDeficient (Favism)":
      DiseaseName.HEMOLYTIC_ANEMIA_G6_PD_DEFICIENT_FAVISM,
  "Mucopolysaccharidosis type VI": DiseaseName.MUCOPOLYSACCHARIDOSIS_TYPE_VI,
  "Ophthalmoplegia and Myopathy Proximal":
      DiseaseName.OPHTHALMOPLEGIA_AND_MYOPATHY_PROXIMAL,
  "Sickle cell anemia; Thalassemia, beta":
      DiseaseName.SICKLE_CELL_ANEMIA_THALASSEMIA_BETA
});

enum DnaChange { C_20_A_T, C_45371_G_A, C_563_C_T, EMPTY }

final dnaChangeValues = EnumValues({
  "": DnaChange.EMPTY,
  "c.20A>T\n": DnaChange.C_20_A_T,
  "c.4537+1G>A": DnaChange.C_45371_G_A,
  "c.563C>T": DnaChange.C_563_C_T
});

enum Empty {
  AMBITIOUS,
  CUNNING,
  EMPTY,
  FLUFFY,
  HILARIOUS,
  INDECENT,
  INDIGO,
  PURPLE,
  STICKY,
  TENTACLED,
  UNAVAILABLE
}

final emptyValues = EnumValues({
  "غير متوفر": Empty.UNAVAILABLE,
  "دبلوم": Empty.AMBITIOUS,
  "ثانوي": Empty.CUNNING,
  "غير متعلم": Empty.EMPTY,
  "تعليم غير منهجي": Empty.FLUFFY,
  "متوسط": Empty.HILARIOUS,
  "ماجستير": Empty.INDECENT,
  "دكتوراة": Empty.INDIGO,
  "طفل": Empty.PURPLE,
  "ابتدائي": Empty.STICKY,
  "بكالوريوس": Empty.TENTACLED
});

enum Inheritance {
  AUTOSOMAL_RECESSIVE,
  AUTOSOMAL_RECESSIVE_AUTOSOMAL_DOMINANT,
  X_LINKED,
  Empty
}

final inheritanceValues = EnumValues({
  "Autosomal Recessive": Inheritance.AUTOSOMAL_RECESSIVE,
  "Autosomal Recessive; Autosomal Dominant":
      Inheritance.AUTOSOMAL_RECESSIVE_AUTOSOMAL_DOMINANT,
  "X- linked": Inheritance.X_LINKED,
  "غير متوفر": Inheritance.Empty
});

enum FamilyMemberFirestoreEnum { EMPTY, PURPLE, UNAVAILABLE }

final familyMemberFirestoreEnumValues = EnumValues({
  "غير متوفر": FamilyMemberFirestoreEnum.UNAVAILABLE,
  "متوفي": FamilyMemberFirestoreEnum.EMPTY,
  "حي يرزق": FamilyMemberFirestoreEnum.PURPLE
});

enum MedicalGene { G6_PD, HBB, MAROTEAUX_LAMY_SYNDROME, MYH2, Empty }

final medicalGeneValues = EnumValues({
  "": MedicalGene.Empty,
  "G6PD": MedicalGene.G6_PD,
  "HBB": MedicalGene.HBB,
  "Maroteaux–Lamy syndrome": MedicalGene.MAROTEAUX_LAMY_SYNDROME,
  "MYH2": MedicalGene.MYH2
});

enum Purple {
  EMPTY,
  FLUFFY,
  HILARIOUS,
  INDECENT,
  INDIGO,
  PURPLE,
  STICKY,
  TENTACLED,
  UNAVAILABLE
}

final purpleValues = EnumValues({
  "غير متوفر": Purple.UNAVAILABLE,
  "عالم دين": Purple.EMPTY,
  "التعليم": Purple.FLUFFY,
  "أخرى": Purple.HILARIOUS,
  "موظف حكومي": Purple.INDECENT,
  "الصحة": Purple.INDIGO,
  "أعمال حرة": Purple.PURPLE,
  "قطاع خاص": Purple.STICKY,
  "موظف أرامكو": Purple.TENTACLED
});

enum ProteinChange { EMPTY, P_GLU7_VAL, P_SER188_PHE }

final proteinChangeValues = EnumValues({
  "-": ProteinChange.EMPTY,
  "p.Glu7Val": ProteinChange.P_GLU7_VAL,
  "p.Ser188Phe": ProteinChange.P_SER188_PHE
});

enum Fluffy { EMPTY, FLUFFY, PURPLE, UNAVAILABLE }

final fluffyValues = EnumValues({
  "وفاة": Fluffy.EMPTY,
  "طلاق": Fluffy.FLUFFY,
  "زواج": Fluffy.PURPLE,
  " ": Fluffy.UNAVAILABLE
});

enum Tentacled {
  EMPTY,
  THE_101036,
  THE_11927,
  THE_12,
  THE_12353,
  THE_15633,
  THE_15638,
  THE_15639,
  THE_15640,
  THE_15641,
  THE_15644,
  THE_15649,
  THE_15654,
  THE_15659,
  THE_15661,
  THE_15664,
  THE_15673,
  THE_15675,
  THE_19839,
  THE_22934,
  THE_2437,
  THE_25137,
  THE_25412,
  THE_26222,
  THE_26942,
  THE_28617,
  THE_3238,
  THE_4,
  THE_521,
  THE_5547,
  THE_559,
  THE_819
}

final tentacledValues = EnumValues({
  "?    ?    --": Tentacled.EMPTY,
  "10    10    36": Tentacled.THE_101036,
  "11    9    27": Tentacled.THE_11927,
  "----    ----    12": Tentacled.THE_12,
  "12    3    53": Tentacled.THE_12353,
  "15    6    33": Tentacled.THE_15633,
  "15    6    38": Tentacled.THE_15638,
  "15    6    39": Tentacled.THE_15639,
  "15    6    40": Tentacled.THE_15640,
  "15    6    41": Tentacled.THE_15641,
  "15    6    44": Tentacled.THE_15644,
  "15    6    49": Tentacled.THE_15649,
  "15    6    54": Tentacled.THE_15654,
  "15    6    59": Tentacled.THE_15659,
  "15    6    61": Tentacled.THE_15661,
  "15    6    64": Tentacled.THE_15664,
  "15    6    73": Tentacled.THE_15673,
  "15    6    75": Tentacled.THE_15675,
  "19    8    39": Tentacled.THE_19839,
  "22    9    34": Tentacled.THE_22934,
  "24    ----    37": Tentacled.THE_2437,
  "25    1    37": Tentacled.THE_25137,
  "25    4    12": Tentacled.THE_25412,
  "26    2    22": Tentacled.THE_26222,
  "26    9    42": Tentacled.THE_26942,
  "28    6    17": Tentacled.THE_28617,
  "3    2    38": Tentacled.THE_3238,
  "----    4    --": Tentacled.THE_4,
  "5    ----    21": Tentacled.THE_521,
  "5    5    47": Tentacled.THE_5547,
  "5    ----    59": Tentacled.THE_559,
  "----    8    19": Tentacled.THE_819
});

enum Sticky {
  EMPTY,
  FLUFFY,
  INDECENT,
  INDIGO,
  PURPLE,
  STICKY,
  TENTACLED,
  ZYGOSITY,
  UNAVAILABLE,
}

final stickyValues = EnumValues({
  "غير متوفر": Sticky.UNAVAILABLE,
  "ايران - قم": Sticky.EMPTY,
  "المدينة المنورة - جنة البقيع": Sticky.FLUFFY,
  "العراق - النجف": Sticky.INDECENT,
  "مقبرة البطالية": Sticky.INDIGO,
  "مكة - مقبرة فخ": Sticky.PURPLE,
  "مقبرة القارة": Sticky.STICKY,
  "ايران - مشهد": Sticky.TENTACLED
});

enum Indigo { EMPTY, PURPLE, UNAVAILABLE }

final indigoValues = EnumValues(
    {"لا": Indigo.EMPTY, "نعم": Indigo.PURPLE, " ": Indigo.UNAVAILABLE});

enum Zygosity { EMPTY, HETEROZYGOUS, HOMOZYGOUS }

final zygosityValues = EnumValues({
  "": Empty,
  "Heterozygous": Zygosity.HETEROZYGOUS,
  "Homozygous": Zygosity.HOMOZYGOUS
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
