import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:magicstep/src/models/input/sign_up_input.dart';
import 'package:magicstep/src/services/auth.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final _authService = const AuthService();
  final _authInstace = FirebaseAuth.instance;
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
    await verifyOtp(signUpInput.verificationCode!);
    final user = _authInstace.currentUser;
    if (user == null) {
      emit(AuthError("Please verify phone number first"));
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
      verificationCompleted: (PhoneAuthCredential credential) async {
        _onVerificationCompleted(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        emit(AuthError("Could not verify phone number"));
      },
      codeSent: (String verificationId, int? resendToken) {
        locator<GlobalServices>().infoSnackBar("Code sent");
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  _onVerificationCompleted(PhoneAuthCredential credential) {
    final smsCode = credential.smsCode;
    if (smsCode == null) {
      return;
    }
    emit(OtpRetrieved(smsCode));
    verifyOtp(smsCode);
  }

  ///
  verifyOtp(String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: otp);
    try {
      await _authInstace.signInWithCredential(credential);
      emit(PhoneVerified());
    } catch (err) {
      emit(
          AuthError("Could not verify phone number, please enter correct otp"));
    }
  }
}
