import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cvdnn_ios_platform_interface.dart';

/// An implementation of [CvdnnIosPlatform] that uses method channels.
class MethodChannelCvdnnIos extends CvdnnIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cvdnn_ios');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> initModel(String path) async {
    final msg = await methodChannel.invokeMethod<String>('initModel', path);
    return msg;
  }

  @override
  Future<String?> generateImage(String inputPath, String outputPath) async {
    final msg = await methodChannel.invokeMethod<String>('generateImage', [inputPath, outputPath]);
    return msg;
  }
}
