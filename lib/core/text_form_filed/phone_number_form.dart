import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

class PhoneNumberForm extends StatelessWidget {
  const PhoneNumberForm(
      {super.key, required this.phoneController, required this.enabled});
  final PhoneController phoneController;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: PhoneFormField(
        controller: phoneController,
        validator: phoneValidation(context),
        countrySelectorNavigator: const CountrySelectorNavigator.page(),
        enabled: enabled,
        isCountrySelectionEnabled: true,
        isCountryButtonPersistent: true,
        countryButtonStyle: const CountryButtonStyle(
            showDialCode: true, showFlag: true, flagSize: 16),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: "ادخل رقم الهاتف",
        ),
      ),
    );
  }
}

PhoneNumberInputValidator? phoneValidation(BuildContext context) {
  List<PhoneNumberInputValidator> validators = [];

  validators
      .add(PhoneValidator.validMobile(context, errorText: "الرقم غير صالح"));

  return validators.isNotEmpty ? PhoneValidator.compose(validators) : null;
}
