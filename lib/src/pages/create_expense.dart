import 'package:flutter/material.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_drop_down.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

class CreateExpensePage extends StatefulWidget {
  static const String routeName = '/create_expense';
  const CreateExpensePage({Key? key}) : super(key: key);

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Header',
              onSave: (e) {},
            ),
            const Divider(color: Colors.transparent),
            CustomTextField(
              label: 'Amount',
              onSave: (e) {},
            ),
            const Divider(color: Colors.transparent),
            CustomTextField(
              label: 'Description',
              hintText: "Optional",
              onSave: (e) {},
            ),
            const Divider(color: Colors.transparent, height: 20),
            CustomDropDownField(
              items: const ['Cash', 'Bank Transfer'],
              onSelected: (e) {},
              hintText: 'Mode of Payment',
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                title: 'Save',
                onTap: () {},
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
