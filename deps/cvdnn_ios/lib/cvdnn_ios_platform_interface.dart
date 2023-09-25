import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cvdnn_ios_method_channel.dart';

abstract class CvdnnIosPlatform extends PlatformInterface {
  /// Constructs a CvdnnIosPlatform.
  CvdnnIosPlatform() : super(token: _token);

  static final Object _token = Object();

  static CvdnnIosPlatform _instance = MethodChannelCvdnnIos();

  /// The default instance of [CvdnnIosPlatform] to use.
  ///
  /// Defaults to [MethodChannelCvdnnIos].
  static CvdnnIosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CvdnnIosPlatform] when
  /// they register themselves.
  static set instance(CvdnnIosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> initModel(String path) {
    throw UnimplementedError('initModel() has not been implemented.');
  }

  Future<String?> generateImage(String inputPath, String outputPath) {
    throw UnimplementedError('generateImage() has not been implemented.');
  }
}
