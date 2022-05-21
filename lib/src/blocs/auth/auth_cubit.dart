import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:magicstep/src/models/input/sign_up_input.dart';
import 'package:magicstep/src/services/auth.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final _authService = const AuthService();
  final _authInstace = fb.FirebaseAuth.instance;
  String? _verificationId;

  ///
  signIn(String email, String password, [bool rememberMe = false]) async {
    emit(AuthLoading());

    try {
      final user = await _authService.signInRequest(email, password);
      if (user == null) {
        emit(AuthError('Invalid email or password'));
        return;
      }
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
      emit(AuthError("Please verify phone number first"));
      return;
    }
    try {
      final user = await _authService.signUpRequest(signUpInput);
      if (user == null) {
        emit(AuthError('Invalid email or password'));
        return;
      }
      emit(SignInSucces());
    } catch (err) {
      emit(AuthError('Invalid email or password'));
    }
  }

  ///
  verifyPhoneNumber(String phoneNumber) async {
    await _authInstace.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        _onVerificationCompleted(credential);
      },
      verificationFailed: (fb.FirebaseAuthException e) {
        emit(AuthError("Could not verify phone number"));
      },
      codeSent: (String verificationId, int? resendToken) {
        locator<GlobalServices>().infoSnackBar("Code sent");
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
    _verifyOtp(smsCode);
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
}
