import 'package:flutter/material.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

class CreatePartyPage extends StatefulWidget {
  static const String routeName = '/create_party';
  const CreatePartyPage({Key? key}) : super(key: key);

  @override
  State<CreatePartyPage> createState() => _CreatePartyPageState();
}

class _CreatePartyPageState extends State<CreatePartyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Party'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CustomTextField(
              label: 'Name',
            ),
            const Divider(color: Colors.transparent),
            const CustomTextField(
              label: 'Phone Number',
            ),
            const Divider(color: Colors.transparent),
            const CustomTextField(
              label: 'Address',
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                title: "Save",
                onTap: () {},
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
