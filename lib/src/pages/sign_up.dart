import 'package:flutter/material.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  static const routeName = '/sign-up';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _hasAgreed = false;
  final _formKey = GlobalKey<FormState>();
  final SignUpInput _signUpInput = SignUpInput();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sign Up",
                    style: Theme.of(context).textTheme.headline3?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Set up your profile to to enjoy our services",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 60),
                CustomTextField(
                  label: "Business Name",
                  onSave: (e) {
                    _signUpInput.businessName = e;
                  },
                ),
                const Divider(color: Colors.transparent),
                CustomTextField(
                  label: "Business Type",
                  onSave: (e) {
                    _signUpInput.businessType = '';
                  },
                ),
                const Divider(color: Colors.transparent),
                CustomTextField(
                  label: "Address",
                  onSave: (e) {
                    _signUpInput.address = '';
                  },
                ),
                const Divider(color: Colors.transparent),
                CustomTextField(
                  label: "Phone Number",
                  onSave: (e) {
                    _signUpInput.phoneNumber;
                  },
                ),
                const Divider(color: Colors.transparent),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomButton(
                    title: "Verify",
                    onTap: () {},
                  ),
                ),
                const Divider(color: Colors.transparent),
                CustomTextField(
                  label: "Verification Code",
                  onSave: (e) {
                    _signUpInput.verificationCode;
                  },
                ),
                const Divider(color: Colors.transparent),
                CustomTextField(
                  label: "Email",
                  onSave: (e) {
                    _signUpInput.email = e;
                  },
                ),
                const Divider(color: Colors.transparent),
                CustomTextField(
                  label: "Password",
                  onSave: (e) {
                    _signUpInput.password = e;
                  },
                ),
                const Divider(color: Colors.transparent),
                Row(
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity.compact,
                      value: _hasAgreed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        width: 1,
                      ),
                      fillColor: MaterialStateProperty.all(
                        ColorsConst.primaryColor,
                      ),
                      onChanged: (val) {
                        if (val == null) {
                          return;
                        }
                        setState(() {
                          _hasAgreed = val;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "By signing up, you agree to our Terms of Service and Privacy Policy",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.transparent),
                CustomTextField(
                  label: "Confirm Password",
                  onSave: (e) {
                    _signUpInput.confirmPassword = e;
                  },
                ),
                const Divider(color: Colors.transparent),
                const SizedBox(height: 5),
                CustomButton(
                  onTap: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                    }
                  },
                  title: 'Create Account',
                ),
                const SizedBox(height: 15),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpInput {
  SignUpInput({
    this.businessName,
    this.businessType,
    this.address,
    this.phoneNumber,
    this.verificationCode,
    this.email,
    this.password,
    this.confirmPassword,
  });

  String? businessName;
  String? businessType;
  String? address;
  String? phoneNumber;
  String? verificationCode;
  String? email;
  String? password;
  String? confirmPassword;
}
