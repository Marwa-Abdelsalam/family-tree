import 'package:flutter/material.dart';

import '../../../../core/text_form_filed/text_form_filed.dart';
import '../../../../core/text_form_filed/text_validator.dart';

class RequestToAddMemberScreen extends StatelessWidget {
  const RequestToAddMemberScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height / 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Text(
                'طلب اضافة عضو جديد',
                style: Theme.of(context).textTheme.headlineMedium,
              )),
              EnterDataTextFormFiled(
                labelText: 'اسم العضو',
                controller: TextEditingController(),
                enabled: true,
                textInputType: TextInputType.name,
                validator: (String? value) {
                  return notNullValidation(value, context: context);
                },
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Add new member logic
                      Navigator.of(context).pop();
                    },
                    child: const Text('نعم'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('لا'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
