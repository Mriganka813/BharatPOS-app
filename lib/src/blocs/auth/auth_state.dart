part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SignUpSucess extends AuthState {}

class PhoneVerified extends AuthState {}

class OtpRetrieved extends AuthState {
  final String otp;
  OtpRetrieved(this.otp);
}

class OtpVerified extends AuthState {}

class SignInSucces extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class CodeVerified extends AuthState {}

class GstApprov extends AuthState {}
