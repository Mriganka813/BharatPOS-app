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

  /// Check for app updates
  Future<void> checkUpdates() async {}
}
