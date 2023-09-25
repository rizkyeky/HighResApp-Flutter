import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cvdnn_android_method_channel.dart';

abstract class CvdnnAndroidPlatform extends PlatformInterface {
  /// Constructs a CvdnnAndroidPlatform.
  CvdnnAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static CvdnnAndroidPlatform _instance = MethodChannelCvdnnAndroid();

  /// The default instance of [CvdnnAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelCvdnnAndroid].
  static CvdnnAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CvdnnAndroidPlatform] when
  /// they register themselves.
  static set instance(CvdnnAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
