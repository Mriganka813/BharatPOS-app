class Utils {
  const Utils();

  ///
  static bool isValidPhoneNumber(String? phoneNumber) {
    if ((phoneNumber ?? "").isEmpty) {
      return false;
    }
    if (phoneNumber?.length != 10) {
      return false;
    }
    return true;
  }
}
