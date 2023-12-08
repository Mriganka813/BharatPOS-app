import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class ForgotPassWordOTPPage extends StatefulWidget {
  @override
  State<ForgotPassWordOTPPage> createState() => _ForgotPassWordOTPPageState();
}

class _ForgotPassWordOTPPageState extends State<ForgotPassWordOTPPage> {

    String code = "";
      String phoneNumber = "";
  String _verificationId = "";

  bool isSubmitVisible = false;
  bool isVerification = true;
  bool isPasswordchanged = false;
  String newPassword = "";
  String confirmNewPassword = "";
  AuthService auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text("Forgot Password"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Verify",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text("Please enter the code we sent you to email"),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Container(
                      width: 300,
                      child: OTPTextField(
                        onChanged: (value){
                  
                          setState(() {
                                    code=value;
                          });
                        },
                        length: 4,
                        width: MediaQuery.of(context).size.width,
                        fieldWidth: 50,
                        style: TextStyle(fontSize: 17),
                        textFieldAlignment: MainAxisAlignment.spaceAround,
                        fieldStyle: FieldStyle.box,
                        outlineBorderRadius: 10,
                        onCompleted: (pin) {
                          print("Completed: " + pin);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text("Didn’t Receive the Code ?"),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Recieve code",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(child: CustomButton(title: "Verify", onTap: () {     verifyOtp();}))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  final _authInstace = fb.FirebaseAuth.instance;
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
