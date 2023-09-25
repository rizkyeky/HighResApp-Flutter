import 'dart:io';

import 'package:path_provider/path_provider.dart' as pthp;
import 'package:path/path.dart' as pth;

import 'cvdnn_ios_platform_interface.dart';

class CvdnnIos {
  Future<String?> getPlatformVersion() {
    return CvdnnIosPlatform.instance.getPlatformVersion();
  }
  
  Future<String> get _appCachePath async => pthp.getApplicationCacheDirectory().then((value) => value.path);

  final String _libName = 'cvdnn_ios';
  String get _modelPath {
    final appPath = Directory(Platform.resolvedExecutable).parent.path;
    return pth.join(appPath, 'Frameworks', '$_libName.framework', 'animesr.onnx');
  }

  Future<String?> initModel() async {
    final file = File(_modelPath);
    final isFile = await file.exists();
    return isFile ? CvdnnIosPlatform.instance.initModel(_modelPath) : null;
  }

  Future<String?> generateImage(String imagePath) async {
    final baseName = pth.basename(imagePath);
    final outputPath = '${(await _appCachePath)}/$baseName';
    await CvdnnIosPlatform.instance.generateImage(imagePath, outputPath);
    return outputPath;
  }
}
