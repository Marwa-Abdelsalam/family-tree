import 'package:flutter/cupertino.dart';
import 'package:form_validation/form_validation.dart';
import 'package:phone_form_field/phone_form_field.dart';

String arabicToWesternNumerals(String input) {
  const arabicToWesternDigits = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  return input.split('').map((digit) {
    return arabicToWesternDigits[digit] ?? digit;
  }).join('');
}

// name validate
String? nameValidation(String? val, {required BuildContext context}) {
  if (val!.length < 3) {
    return "الحد الادني للاسم ٣ احرف";
  } else {
    return null;
  }
}

String? descriptionValidation(String? val, {required BuildContext context}) {
  if (val!.length < 10) {
    return "الحد الادي للوصف ١٠ احرف";
  } else {
    return null;
  }
}

String? createPassWordValidation(
    {required String val, required BuildContext context}) {
  String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$';
  RegExp regExp = RegExp(pattern);

  if (!regExp.hasMatch(val)) {
    return "كلمة المرور غير صالحة"; // Use the localized message
  } else {
    return null;
  }
}

String? passWordValidation(
    {required String? val, required BuildContext context}) {
  if (val == null) {
    return "يرجي ادخال كلمه المرور";
  } else if (val.length < 8) {
    return "كلمه المرور علي الاقل ٨ احرف او ارقام";
  } else {
    return null;
  }
}

String? confirmPassWordValidation(
    {required BuildContext context,
    required String? val,
    required String password}) {
  if (val == null) {
    return "يرجي تاكيد كلمه المرور";
  } else if (val != password) {
    return "كلمه المرور غير متطابقه";
  } else {
    return null;
  }
}

String? notNullValidation(String? val, {required BuildContext context}) {
  if (val!.isEmpty) {
    return "يرجي ادخال الحقل";
  } else {
    return null;
  }
}

String? emailValidation({String? val, required BuildContext context}) {
  final validator = Validator(
    validators: [
      const RequiredValidator(),
      const EmailValidator(),
    ],
  );

  return validator.validate(
    label: "البريد الالكتروني",
    value: val,
  );
}
