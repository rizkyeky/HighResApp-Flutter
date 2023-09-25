
import 'cvdnn_android_platform_interface.dart';

class CvdnnAndroid {
  Future<String?> getPlatformVersion() {
    return CvdnnAndroidPlatform.instance.getPlatformVersion();
  }
}
