import 'package:flutter_test/flutter_test.dart';
import 'package:cvdnn_ios/cvdnn_ios.dart';
import 'package:cvdnn_ios/cvdnn_ios_platform_interface.dart';
import 'package:cvdnn_ios/cvdnn_ios_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCvdnnIosPlatform
    with MockPlatformInterfaceMixin
    implements CvdnnIosPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
  
  @override
  Future<String?> initModel(String path) => Future.value('100');

  @override
  Future<String?> generateImage(String inputPath, String outputPath) => Future.value('100');
}

void main() {
  final CvdnnIosPlatform initialPlatform = CvdnnIosPlatform.instance;

  test('$MethodChannelCvdnnIos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCvdnnIos>());
  });

  test('getPlatformVersion', () async {
    CvdnnIos cvdnnIosPlugin = CvdnnIos();
    MockCvdnnIosPlatform fakePlatform = MockCvdnnIosPlatform();
    CvdnnIosPlatform.instance = fakePlatform;

    expect(await cvdnnIosPlugin.getPlatformVersion(), '42');
  });
}
