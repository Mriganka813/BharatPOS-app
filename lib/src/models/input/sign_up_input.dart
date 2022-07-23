import 'package:image_picker/image_picker.dart';

class SignUpInput {
  SignUpInput(
      {this.email,
      this.password,
      this.businessName,
      this.businessType,
      this.address,
      this.verificationCode,
      this.phoneNumber,
      this.confirmPassword,
      this.referral,
      this.imageFile});

  String? email;
  String? password;
  String? confirmPassword;
  String? businessName;
  String? businessType;
  String? address;
  String? phoneNumber;
  String? verificationCode;
  String? referral;
  XFile? imageFile;

  Map<String, dynamic> toMap() => {
        "email": email,
        "password": password,
        "businessName": businessName,
        "businessType": businessType,
        "address": address,
        "phoneNumber": phoneNumber,
        "verificationcode": verificationCode,
        "referredBy": referral
      };
}
