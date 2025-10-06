import 'package:flutter/foundation.dart';

class ProfileState {
  static final ValueNotifier<String?> profileImageUrl = ValueNotifier<String?>(null);

  static void setImageUrl(String? url) => profileImageUrl.value = url;

}
