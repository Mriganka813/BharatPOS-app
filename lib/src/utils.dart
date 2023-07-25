import 'package:in_app_update/in_app_update.dart';

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
  // Future<void> () async {
  //   final update = await InAppUpdate.checkForUpdate();
  //   if (update.updateAvailability < 0) {
  //     return;
  //   }
  //   if (update.immediateUpdateAllowed) {
  //     await InAppUpdate.startFlexibleUpdate();
  //     await InAppUpdate.completeFlexibleUpdate();
  //     return;
  //   }
  //   await InAppUpdate.performImmediateUpdate();
  // }
}
