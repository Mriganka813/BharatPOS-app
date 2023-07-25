import 'package:flutter/material.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
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
  AuthService auth = AuthService();
  String oldPassword = "";
  String newPassword = "";
  String confirmPassword = "";
  bool isPasswordchanged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          reverse: true,
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
                      readonly: true,
                      initialValue: widget.user!.email,
                    ),
              Divider(color: Colors.transparent),
              CustomTextField(
                label: "Current Password",
                obsecureText: true,
                onChanged: (e) {
                  setState(() {
                    oldPassword = e;
                  });
                },
              ),
              Divider(color: Colors.transparent),
              CustomTextField(
                label: "New Password",
                obsecureText: true,
                onChanged: (e) {
                  setState(() {
                    newPassword = e;
                  });
                },
              ),
              Divider(color: Colors.transparent),
              CustomTextField(
                label: "Confirm New Password",
                obsecureText: true,
                onChanged: (e) {
                  setState(() {
                    confirmPassword = e;
                  });
                },
              ),
              Divider(
                color: Colors.transparent,
              ),
              Divider(
                color: Colors.transparent,
              ),
              CustomButton(
                  title: "Change",
                  onTap: () async {
                    if (newPassword.length < 8) {
                      locator<GlobalServices>().errorSnackBar(
                          "Password should have minimum 8 character");
                      return;
                    } else if (newPassword != confirmPassword) {
                      locator<GlobalServices>()
                          .errorSnackBar("Password not matched");
                      return;
                    }
                    isPasswordchanged = await auth.PasswordChangeRequest(
                        oldPassword, newPassword, confirmPassword);
                    isPasswordchanged
                        ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              "Password Changed sucessfully",
                              style: TextStyle(color: Colors.white),
                            )))
                        : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "something went wrong",
                              style: TextStyle(color: Colors.white),
                            )));
                    Navigator.pop(context);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
