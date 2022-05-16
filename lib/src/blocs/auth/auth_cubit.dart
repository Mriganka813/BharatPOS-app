import 'package:bloc/bloc.dart';
import 'package:magicstep/src/models/input/sign_up_input.dart';
import 'package:magicstep/src/services/auth.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final _authService = const AuthService();

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
  sendOtp(SignUpInput input) {}
}
