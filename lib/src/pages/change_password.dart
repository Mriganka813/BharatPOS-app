import 'package:flutter/material.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';

class ChangePassword extends StatefulWidget {
  static const String routeName = 'changepassword';
  final User? user;
  ChangePassword({Key? key, this.user}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.user == null
                ? CustomTextField(
                    label: "Email",
                  )
                : CustomTextField(
                    label: "Email",
                    initialValue: widget.user!.email,
                  ),
            Divider(),
            CustomTextField(
              label: "Current Password",
              obsecureText: true,
            ),
            Divider(),
            CustomTextField(
              label: "New Password",
              obsecureText: true,
            ),
            Divider(),
            CustomTextField(
              label: "Confirm New Password",
              obsecureText: true,
            ),
            Spacer(),
            CustomButton(
                title: "Reset",
                onTap: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
}
