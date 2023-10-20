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
    return pth.join(appPath, 'Frameworks', 'App.framework', 'flutter_assets', 'assets', 'animesr.onnx');
  }

  Future<String?> initModel() async {
    final file = File(_modelPath);
    final isFile = await file.exists();
    if (isFile) print('Found $_modelPath');
    return isFile ? CvdnnIosPlatform.instance.initModel(_modelPath) : null;
  }

  Future<String?> generateImage(String imagePath) async {
    final baseName = pth.basename(imagePath);
    final outputPath = '${(await _appCachePath)}/$baseName';
    await CvdnnIosPlatform.instance.generateImage(imagePath, outputPath);
    final file = File(outputPath);
    final isFile = await file.exists();
    if (isFile) print('Found $outputPath');
    else print('Not Found');
    return outputPath;
  }
}
