import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cvdnn_android_platform_interface.dart';

/// An implementation of [CvdnnAndroidPlatform] that uses method channels.
class MethodChannelCvdnnAndroid extends CvdnnAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cvdnn_android');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
