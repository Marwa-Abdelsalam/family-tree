//
//
// import 'package:flutter/material.dart';
// import 'package:phone_form_field/phone_form_field.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import '../../app_const/text_validator.dart';
//
// // Define input type enum
// enum InputType { phone, email }
//
// class PhoneEmailFormField extends StatefulWidget {
//   final TextEditingController emailController;
//   final PhoneController phoneController;
//   final bool enabled;
//
//   const PhoneEmailFormField({
//     super.key,
//     required this.emailController,
//     required this.phoneController,
//     required this.enabled,
//   });
//
//   @override
//   PhoneEmailFormFieldState createState() => PhoneEmailFormFieldState();
// }
//
// class PhoneEmailFormFieldState extends State<PhoneEmailFormField> {
//   InputType inputType = InputType.email;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Toggle button to switch between phone and email input
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ChoiceChip(
//               label: Text(AppLocalizations.of(context)!.contactPhone),
//               selected: inputType == InputType.phone,
//               onSelected: (bool selected) {
//                 setState(() {
//                   inputType = InputType.phone;
//                 });
//               },
//             ),
//             const SizedBox(width: 10),
//             ChoiceChip(
//               label: Text(AppLocalizations.of(context)!.contactEmail),
//               selected: inputType == InputType.email,
//               onSelected: (bool selected) {
//                 setState(() {
//                   inputType = InputType.email;
//                 });
//               },
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         // Conditional rendering of input field based on selected type
//         if (inputType == InputType.email)
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextFormField(
//               controller: widget.emailController,
//               keyboardType: TextInputType.emailAddress,
//               enabled: widget.enabled,
//               validator: (value) => emailValidation(val: value, context: context),
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 prefixIcon: const Icon(Icons.email),
//                 labelText: AppLocalizations.of(context)!.enterEmail,
//               ),
//             ),
//           )
//         else
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: PhoneFormField(
//               controller: widget.phoneController,
//               validator: phoneValidation(context),
//               countrySelectorNavigator: const CountrySelectorNavigator.page(),
//               enabled: widget.enabled,
//               isCountrySelectionEnabled: true,
//               isCountryButtonPersistent: true,
//               countryButtonStyle: const CountryButtonStyle(
//                 showDialCode: true,
//                 showFlag: true,
//                 flagSize: 16,
//               ),
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 labelText: AppLocalizations.of(context)!.enterPhoneNumber,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
