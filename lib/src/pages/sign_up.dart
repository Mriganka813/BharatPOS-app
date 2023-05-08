/*import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopos/src/blocs/auth/auth_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/input/sign_up_input.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_drop_down.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:slidable_button/slidable_button.dart';
import 'package:switcher/core/switcher_size.dart';
import 'package:switcher/switcher.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  static const routeName = '/sign-up';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final AuthCubit _authCubit;
  bool _hasAgreed = false;
  final _formKey = GlobalKey<FormState>();
  final SignUpInput _signUpInput = SignUpInput();
  late final ImagePicker _picker;
  String locality = "";
  String city = "";
  String statee = "";
  String country = "";
  String upiId = "";
  String type = "monthly";
  bool gstApprov = false;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit();
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, elevation: 0),
      body: BlocListener<AuthCubit, AuthState>(
        bloc: _authCubit,
        listener: (context, state) {
          if (state is AuthError) {
            locator<GlobalServices>().errorSnackBar(state.message);
          }
          if (state is GstApprov) {
            if (gstApprov) {
              setState(() {
                gstApprov = false;
                // _signUpInput.isGstApprove = false;
              });
            } else {
              setState(() {
                gstApprov = true;
                // _signUpInput.isGstApprove = true;
              });
            }
          }
          if (state is SignInSucces) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              HomePage.routeName,
              (route) => false,
            );
          }
        },
        child: Form(
          key: _formKey,
          child: BlocBuilder<AuthCubit, AuthState>(
            bloc: _authCubit,
            builder: (context, state) {
              bool isLoading = false;
              // _signUpInput.isGstApprove = false;
              if (state is AuthLoading) {
                isLoading = true;
              }

              if (state is GstApprov) {
                if (gstApprov)
                  _signUpInput.isGstApprove = false;
                else
                  _signUpInput.isGstApprove = true;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
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
                        "Set up your profile to enjoy our services",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          _showImagePickerOptions();
                        },
                        child: Container(
                          height: 160,
                          // color: Colors.amber,
                          child: _signUpInput.imageFile == null
                              ? Column(
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 100,
                                    ),
                                    Text(
                                      "Add Image",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              // Image.asset(
                              //     'assets/images/image_placeholder.png',
                              //     height: 80,
                              //     width: 80,
                              //   )
                              : Image.file(
                                  File(_signUpInput.imageFile!.path),
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      label: "Business Name",
                      onSave: (e) {
                        _signUpInput.businessName = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    Text(
                      'Business Type',
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    const SizedBox(height: 5),
                    CustomDropDownField(
                      items: const [
                        "Food",
                        "Grocery",
                        "Medical",
                        "Fashion",
                        "Staionery",
                        "Electrical"
                      ],
                      onSelected: (e) {
                        _signUpInput.businessType = e;
                      },
                      hintText: '',
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Locality",
                      onChanged: (e) {
                        locality = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "City",
                      onChanged: (e) {
                        city = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "State",
                      onChanged: (e) {
                        statee = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Country",
                      onChanged: (e) {
                        country = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "UPI ID (Optional)",
                      onChanged: (e) {
                        upiId = e;
                      },
                      bypassValidator: true, // new optional parameter
                    ),
                    const Divider(color: Colors.transparent),
                    Row(
                      children: [
                        Switcher(
                          value: gstApprov,
                          size: SwitcherSize.small,
                          switcherButtonRadius: 50,
                          enabledSwitcherButtonRotate: true,
                          colorOff: Colors.black12,
                          colorOn: Colors.blue,
                          onChanged: (bool gststate) {
                            _authCubit.gst();
                          },
                        ),
                        VerticalDivider(),
                        Text(
                          "Have GSTIN ?",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                    const Divider(color: Colors.transparent),
                    Visibility(
                      visible: !gstApprov,
                      child: Column(
                        children: [
                          CustomTextField(
                            label: "GSTIN",
                            inputType: TextInputType.emailAddress,
                            onSave: (e) {
                              _signUpInput.gstIN = e;
                            },
                            onChanged: (e) {
                              _signUpInput.gstIN = e;
                            },
                          ),
                          const Divider(color: Colors.transparent),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Type",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                              ),
                              SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.black38)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Radio(
                                            value: "monthly",
                                            groupValue: type,
                                            onChanged: (e) {
                                              setState(() {
                                                type = e.toString();
                                                _signUpInput.type =
                                                    e.toString();
                                              });
                                            }),
                                        Text("Monthly")
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                            value: "quarterly",
                                            groupValue: type,
                                            onChanged: (e) {
                                              setState(() {
                                                type = e.toString();
                                                _signUpInput.type =
                                                    e.toString();
                                              });
                                            }),
                                        Text("Quarterly")
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Email",
                      inputType: TextInputType.emailAddress,
                      onSave: (e) {
                        _signUpInput.email = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Password",
                      obsecureText: true,
                      onSave: (e) {
                        _signUpInput.password = e!;
                      },
                      validator: (e) {
                        if (_signUpInput.password!.length < 8) {
                          return "Password should have minimum 8 character";
                        }
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Confirm Password",
                      obsecureText: true,
                      onSave: (e) {
                        _signUpInput.confirmPassword = e;
                      },
                      validator: (e) {
                        if (e == null || e.isEmpty) {
                          return "Please confirm password";
                        }
                        if (_signUpInput.password != e) {
                          return "Passwords do not match";
                        }
                        if (_signUpInput.password!.length < 8) {
                          return "Password contain minimum 8 character";
                        }
                        return null;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      label: "Referral (If any)",
                      onChanged: (e) {
                        _signUpInput.referral = e;
                      },
                      validator: (e) {
                        return null;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      inputType: TextInputType.phone,
                      label: "Phone Number",
                      inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      onChanged: (e) {
                        setState(() {
                          _signUpInput.phoneNumber = e;
                        });
                      },
                      onSave: (e) {
                        _signUpInput.phoneNumber = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomButton(
                        title: "Verify",
                        isDisabled: _signUpInput.phoneNumber?.length != 10,
                        onTap: () {
                          if ((_signUpInput.phoneNumber ?? "").length < 10) {
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
                          _authCubit.verifyPhoneNumber(
                            _signUpInput.phoneNumber!,
                          );
                        },
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      value: state is OtpRetrieved ? state.otp : null,
                      inputFormatters: [LengthLimitingTextInputFormatter(6)],
                      label: "Verification Code",
                      inputType: TextInputType.phone,
                      validator: (e) {
                        if (e == null || e.isEmpty || e.length < 6) {
                          return "Please enter a valid verification code";
                        }
                        return null;
                      },
                      onSave: (e) {
                        _signUpInput.verificationCode = e;
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "By signing up, you agree to our",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    child: Text(
                                      "Terms of Service",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                    onTap: () async {
                                      await launchUrl(
                                        Uri.parse(
                                            'http://64.227.172.99:5000/privacy-policy'),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                  Text(
                                    " and ",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  GestureDetector(
                                    child: Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                    onTap: () async {
                                      await launchUrl(
                                        Uri.parse(
                                            'http://64.227.172.99:5000/terms-and-condition'),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.transparent),
                    const SizedBox(height: 5),
                    CustomButton(
                      isDisabled: isLoading,
                      onTap: () {
                        _signUpInput.address = locality +
                            ", " +
                            city +
                            ", " +
                            statee +
                            ", " +
                            country;
                        _formKey.currentState?.save();
                        final isValid =
                            _formKey.currentState?.validate() ?? false;
                        if (!isValid) {
                          return;
                        }
                        if (!_hasAgreed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                "Please agree to our terms and conditions",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                          return;
                        }
                        if (_signUpInput.imageFile == null) {
                          locator<GlobalServices>().errorSnackBar("Add Image");
                          return;
                        }
                        _authCubit.signUp(_signUpInput);
                      },
                      title: 'Create Account',
                    ),
                    const SizedBox(height: 15),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (cntxt) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(cntxt);
                        _pickImage(ImageSource.camera);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Center(
                            child: Icon(
                              Icons.camera,
                              size: 60,
                            ),
                          ),
                          Divider(color: Colors.transparent),
                          Text('Camera')
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(cntxt);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Center(
                            child: Icon(
                              Icons.photo_rounded,
                              size: 60,
                            ),
                          ),
                          Divider(color: Colors.transparent),
                          Text('Album')
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.transparent),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source) async {
    final XFile? image =
        await _picker.pickImage(source: source, imageQuality: 20);
    if (image == null) {
      return;
    }
    setState(() {
      _signUpInput.imageFile = image;
    });
  }
}
*/