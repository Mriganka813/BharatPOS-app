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
                        inputFormatters: [LengthLimitingTextInputFormatter(6)],
                        label: "Verification Code",
                        inputType: TextInputType.phone,
                        value: code,
                        validator: (e) {
                          if (e == null || e.isEmpty || e.length < 6) {
                            return "Please enter a valid verification code";
                          }
                          return null;
                        },
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
                          isPasswordchanged =
                              await auth.ForgotPasswordChangeRequest(
                                  newPassword, confirmNewPassword, phoneNumber);
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
                        })
                  ],
                ),
        ),
      ),
    );
  }

  final _authInstace = fb.FirebaseAuth.instance;
  verifyPhoneNumber(String phoneNumber) async {
    await _authInstace.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        print(credential.smsCode);
        setState(() {
          code = credential.smsCode!;
        });
      },
      verificationFailed: (fb.FirebaseAuthException e) {
        locator<GlobalServices>().errorSnackBar("Verification Failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        locator<GlobalServices>().infoSnackBar("Code sent");
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  verifyOtp() async {
    fb.PhoneAuthCredential credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: code);

    try {
      await _authInstace.signInWithCredential(credential).then((value) {
        print("You are logged in successfully");
        setState(() {
          isVerification = false;
        });
      });
    } catch (e) {
      setState(() {
        phoneNumber = "";
        code = "";
        isSubmitVisible = false;
      });
      locator<GlobalServices>().errorSnackBar("Reverify your number");
    }
  }
}
