import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class Forgotpassword extends StatefulWidget {
  static const routeName = '/forgotPassword';
  Forgotpassword({Key? key}) : super(key: key);

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  String phoneNumber = "";
  String _verificationId = "";
  String code = "";
  bool isSubmitVisible = false;
  bool isVerification = true;
  bool isPasswordchanged = false;
  String newPassword = "";
  String confirmNewPassword = "";
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: isVerification
              ? Column(
                  children: [
                    CustomTextField(
                      inputType: TextInputType.phone,
                      label: "Phone Number",
                      inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      onChanged: (e) {
                        setState(() {
                          phoneNumber = e;
                        });
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomButton(
                      title: "Verify",
                      isDisabled: phoneNumber.toString().length != 10,
                      onTap: () {
                        if (phoneNumber.toString().length < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                "Please enter a valid phone number",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          isSubmitVisible = true;
                        });
                        verifyPhoneNumber(
                          phoneNumber.toString(),
                        );
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    Visibility(
                      visible: isSubmitVisible,
                      child: CustomTextField(
                        value: code,
                        label: "Verification Code",
                        inputType: TextInputType.phone,
                        onChanged: (e) {
                          setState(() {
                            code = e;
                          });
                        },
                      ),
                    ),
                    const Divider(color: Colors.transparent),
                    Visibility(
                      visible: isSubmitVisible,
                      child: CustomButton(
                          title: "Submit",
                          onTap: () {
                            verifyOtp();
                          }),
                    )
                  ],
                )
              : Column(
                  children: [
                    CustomTextField(
                      label: "Phone Number",
                      readonly: true,
                      initialValue: phoneNumber,
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
                          confirmNewPassword = e;
                        });
                        if (newPassword == confirmNewPassword) {
                          locator<GlobalServices>()
                              .successSnackBar("Password matched ✓");
                        }
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
                          }
                          try {
                            isPasswordchanged =
                                await auth.ForgotPasswordChangeRequest(
                                    newPassword,
                                    confirmNewPassword,
                                    phoneNumber);
                            isPasswordchanged
                                ? ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                          "Password Changed sucessfully",
                                          style: TextStyle(color: Colors.white),
                                        )))
                                : ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          "something went wrong",
                                          style: TextStyle(color: Colors.white),
                                        )));
                            Navigator.pop(context);
                          } catch (e) {
                            print(e.toString());
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  "something went wrong",
                                  style: TextStyle(color: Colors.white),
                                )));
                          }
                        })
                  ],
                ),
        ),
      ),
    );
  }

  final _authInstace = fb.FirebaseAuth.instance;
  verifyPhoneNumber(String phoneNumber) async {
    locator<GlobalServices>().infoSnackBar("Sending Code");
    await _authInstace.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        setState(() {
          code = credential.smsCode!;
        });
      },
      verificationFailed: (fb.FirebaseAuthException e) {
        locator<GlobalServices>().errorSnackBar("Verification Failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        locator<GlobalServices>().successSnackBar("Code sent");
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  verifyOtp() async {
    locator<GlobalServices>().infoSnackBar("Verifying...");
    fb.PhoneAuthCredential credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: code);

    try {
      await _authInstace.signInWithCredential(credential).then((value) {
        locator<GlobalServices>().successSnackBar("Verified ✓");
        setState(() {
          isVerification = false;
        });
      });
    } catch (e) {
      locator<GlobalServices>().errorSnackBar("Reverify your number");
      setState(() {
        phoneNumber = "";
        code = "";
        isSubmitVisible = false;
      });
    }
  }
}
