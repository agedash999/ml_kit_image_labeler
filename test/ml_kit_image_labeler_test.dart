import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ml_kit_image_labeler/ml_kit_image_labeler.dart';

void main() {
  const MethodChannel channel = MethodChannel('ml_kit_image_labeler');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await MlKitImageLabeler.platformVersion, '42');
  });
}
