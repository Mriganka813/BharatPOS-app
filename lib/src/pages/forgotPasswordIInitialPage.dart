import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopos/src/pages/ForgotPasswordOTPPage.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
class ForgotpassWordInitialPage extends StatefulWidget {
  @override
  State<ForgotpassWordInitialPage> createState() =>
      _ForgotpassWordInitialPageState();
}

class _ForgotpassWordInitialPageState extends State<ForgotpassWordInitialPage> {
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
      body: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Forgot Password ?",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Image.asset(
                  "assets/images/forgot.png",
                  height: 200,
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                    width: 250,
                    child: Text(
                      "Where would you like to receive a Verification Code ?",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )),
                SizedBox(
                  height: 40,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      side: BorderSide(color: Colors.black, width: 2)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/message.png",
                          height: 30,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "via SMS",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextField(
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10)
                                ],
                                onChanged: (e) {
                                  setState(() {
                                    phoneNumber = e;
                                  });
                                },
                                decoration: InputDecoration(
                                    hintText: "Phone Number",
                                    border: InputBorder.none),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      side: BorderSide(color: Colors.black, width: 2)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/down.png",
                          height: 30,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "via Email",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    hintText: "Email",
                                    border: InputBorder.none),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Expanded(
                        child: CustomButton(
                      title: "Next",
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPassWordOTPPage()));
                      },
                    )),
                  ],
                )
              ],
            ),
          )),
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
}


