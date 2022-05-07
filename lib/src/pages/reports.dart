import 'package:flutter/material.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

class ReportsPage extends StatefulWidget {
  static const String routeName = '/reports_page';
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Reports')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(0),
                onChanged: (value) {},
                title: const Text("Sale Report"),
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onChanged: (value) {},
                contentPadding: const EdgeInsets.all(0),
                title: const Text("Purchase Report"),
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(0),
                onChanged: (value) {},
                title: const Text("Income Report"),
              ),
              CheckboxListTile(
                contentPadding: const EdgeInsets.all(0),
                controlAffinity: ListTileControlAffinity.leading,
                value: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onChanged: (value) {},
                title: const Text("Expense Report"),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                label: "Start Date",
                onChanged: (value) {},
                hintText: "dd/mm/yyyy",
              ),
              const Divider(color: Colors.transparent),
              CustomTextField(
                label: "End Date",
                hintText: "dd/mm/yyyy",
                onChanged: (value) {},
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      title: "View",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Colors.white, fontSize: 18),
                      onTap: () {},
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: CustomButton(
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white, fontSize: 18),
                      title: "Download",
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
