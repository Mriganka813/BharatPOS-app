import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magicstep/src/blocs/auth_cubit/auth_cubit.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/models/input/sign_up_input.dart';
import 'package:magicstep/src/pages/home.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_drop_down.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

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

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocListener<AuthCubit, AuthState>(
          bloc: _authCubit,
          listener: (context, state) {
            if (state is SignInSucces) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomePage.routeName,
                (route) => false,
              );
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: BlocBuilder<AuthCubit, AuthState>(
              bloc: _authCubit,
              buildWhen: (previous, current) => current is! AuthError,
              builder: (context, state) {
                bool isLoading = false;
                if (state is AuthLoading) {
                  isLoading = true;
                }
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Sign Up",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  ?.copyWith(
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
                          Text(
                            'Business Type',
                            style:
                                Theme.of(context).textTheme.headline6?.copyWith(
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
                              "Fashion"
                            ],
                            onSelected: (e) {
                              _signUpInput.businessType = e;
                            },
                            hintText: '',
                          ),
                          const Divider(color: Colors.transparent),
                          CustomTextField(
                            label: "Address",
                            onSave: (e) {
                              _signUpInput.address = e;
                            },
                          ),
                          const Divider(color: Colors.transparent),
                          CustomTextField(
                            inputType: TextInputType.phone,
                            label: "Phone Number",
                            onSave: (e) {
                              _signUpInput.phoneNumber = e!;
                            },
                          ),
                          const Divider(color: Colors.transparent),
                          // Align(
                          //   alignment: Alignment.centerLeft,
                          //   child: CustomButton(
                          //     title: "Verify",
                          //     onTap: () {
                          //       if ((_signUpInput.phoneNumber ?? "").length <
                          //           10) {
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //           const SnackBar(
                          //             backgroundColor: Colors.red,
                          //             content: Text(
                          //               "Please enter a valid phone number",
                          //               style: TextStyle(color: Colors.white),
                          //             ),
                          //           ),
                          //         );
                          //         return;
                          //       }
                          //       _authCubit.sendOtp(_signUpInput);
                          //     },
                          //     style: Theme.of(context)
                          //         .textTheme
                          //         .titleSmall
                          //         ?.copyWith(color: Colors.white),
                          //   ),
                          // ),
                          // const Divider(color: Colors.transparent),
                          // CustomTextField(
                          //   label: "Verification Code",
                          //   onSave: (e) {
                          //     _signUpInput.verificationCode;
                          //   },
                          // ),
                          // const Divider(color: Colors.transparent),
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
                            onSave: (e) {
                              _signUpInput.password = e!;
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
                            validator: (e) {
                              if (e == null || e.isEmpty) {
                                return "Please confirm password";
                              }
                              if (_signUpInput.password != e) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const Divider(color: Colors.transparent),
                          const SizedBox(height: 5),
                          CustomButton(
                            onTap: () {
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
                              _authCubit.signUp(_signUpInput);
                            },
                            title: 'Create Account',
                          ),
                          const SizedBox(height: 15),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),

                    /// Loader
                    if (isLoading)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
