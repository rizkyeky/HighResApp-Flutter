import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cvdnn_ios/cvdnn_ios_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelCvdnnIos platform = MethodChannelCvdnnIos();
  const MethodChannel channel = MethodChannel('cvdnn_ios');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
