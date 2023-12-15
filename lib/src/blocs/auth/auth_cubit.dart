import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/models/input/sign_up_input.dart';
import 'package:shopos/src/services/auth.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final _authService = const AuthService();
  final _authInstace = fb.FirebaseAuth.instance;
  String? _verificationId;
  void saveAccount(String email,String pass)async
  {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(email, pass);
  }
  ///
  signIn(String email, String password, [bool rememberMe = false]) async {
    emit(AuthLoading());

    try {
      final user = await _authService.signInRequest(email, password);
      if (user == null) {
        emit(AuthError('Invalid email or password'));
        return;
      }

      saveAccount(email, password);
      emit(SignInSucces());
    } catch (err) {
      emit(AuthError('Invalid email or password'));
    }
  }

  ///
  signUp(SignUpInput signUpInput) async {
    emit(AuthLoading());
    final user = await _verifyOtp(signUpInput.verificationCode!);
    if (user == null) {
      emit(AuthError("OTP verification failed"));
      return;
    }
    try {
      final user = await _authService.signUpRequest(signUpInput);
      if (user == null) {
        emit(AuthError('Try again later'));
        return;
      }
      emit(SignInSucces());
    } catch (err) {
      print(err.toString());
      emit(AuthError('Email already exists'));
    }
  }

  ///
  verifyPhoneNumber(String phoneNumber) async {
    locator<GlobalServices>().infoSnackBar("Sending Code");
    await _authInstace.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        _onVerificationCompleted(credential);
      },
      verificationFailed: (fb.FirebaseAuthException e) {
        emit(AuthError("Could not verify phone number"));
      },
      codeSent: (String verificationId, int? resendToken) {
        locator<GlobalServices>().successSnackBar("Code sent");
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  ///
  _onVerificationCompleted(fb.PhoneAuthCredential credential) {
    final smsCode = credential.smsCode;
    if (smsCode == null) {
      return;
    }
    emit(OtpRetrieved(smsCode));
  }

  ///
  Future<fb.UserCredential?> _verifyOtp(String otp) async {
    if (_verificationId == null) {
      return null;
    }
    final creds = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: otp);
    try {
      final user = await _authInstace.signInWithCredential(creds);
      return user;
    } catch (_) {
      return null;
    }
  }

  void gst() {
    emit(GstApprov());
  }
}
