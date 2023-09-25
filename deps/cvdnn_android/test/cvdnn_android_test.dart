import 'package:flutter_test/flutter_test.dart';
import 'package:cvdnn_android/cvdnn_android.dart';
import 'package:cvdnn_android/cvdnn_android_platform_interface.dart';
import 'package:cvdnn_android/cvdnn_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCvdnnAndroidPlatform
    with MockPlatformInterfaceMixin
    implements CvdnnAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CvdnnAndroidPlatform initialPlatform = CvdnnAndroidPlatform.instance;

  test('$MethodChannelCvdnnAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCvdnnAndroid>());
  });

  test('getPlatformVersion', () async {
    CvdnnAndroid cvdnnAndroidPlugin = CvdnnAndroid();
    MockCvdnnAndroidPlatform fakePlatform = MockCvdnnAndroidPlatform();
    CvdnnAndroidPlatform.instance = fakePlatform;

    expect(await cvdnnAndroidPlugin.getPlatformVersion(), '42');
  });
}
