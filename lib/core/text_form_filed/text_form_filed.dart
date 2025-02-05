import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class EnterDataTextFormFiled extends StatelessWidget {
  final TextEditingController controller;
  final IconData? icon;
  final Widget? iconWidget;
  final String? labelText;
  final TextInputType textInputType;
  final FormFieldValidator<String> validator;
  final bool enabled;
  final  Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters ;
  final InputBorder? inputBorder ;
  final int? maxLength;
  final TextStyle? textStyle;
  const EnterDataTextFormFiled({
    super.key,
    required this.enabled,
     this.labelText,
    required this.controller,
     this.icon,
    required this.textInputType,
    required this.validator, this.onChanged, this.inputFormatters, this.inputBorder, this.iconWidget, this.maxLength, this.textStyle,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return TextFormField(
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            enabled: enabled,
            maxLines: maxLength,
            keyboardType: textInputType,
            validator: validator,
            controller: controller,
            style: textStyle,

            decoration: InputDecoration(
              border:inputBorder?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              prefixIcon:icon==null? iconWidget:Icon(icon),
              labelText: labelText,
            ),
          );
        },
      ),
    );
  }
}
