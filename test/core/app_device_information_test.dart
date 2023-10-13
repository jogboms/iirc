import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceInfoPlatform extends Mock with MockPlatformInterfaceMixin implements DeviceInfoPlatform {}

class MockPackageInfoPlatform extends Mock with MockPlatformInterfaceMixin implements PackageInfoPlatform {}

void main() {
  group('AppDeviceInformation', () {
    final DeviceInfoPlatform deviceInfoPlatform = MockDeviceInfoPlatform();
    final MockPackageInfoPlatform packageInfoPlatform = MockPackageInfoPlatform();

    setUpAll(() {
      DeviceInfoPlatform.instance = deviceInfoPlatform;
      PackageInfoPlatform.instance = packageInfoPlatform;
    });

    setUp(() {
      when(packageInfoPlatform.getAll).thenAnswer(
        (_) async => PackageInfoData(
          appName: 'App',
          buildNumber: '1',
          packageName: 'com.example',
          version: '1.0.0',
          buildSignature: '',
        ),
      );
    });

    tearDown(() {
      reset(deviceInfoPlatform);
      reset(packageInfoPlatform);
    });

    test('should work normally for android', () async {
      when(deviceInfoPlatform.deviceInfo).thenAnswer(
        (_) async => AndroidDeviceInfo.fromMap(<String, dynamic>{
          'model': 'Nokia 2',
          'version': <String, dynamic>{
            'baseOS': '',
            'codename': '',
            'incremental': '',
            'previewSdkInt': 1,
            'release': '',
            'sdkInt': 1,
            'securityPatch': '',
          },
          'board': '',
          'bootloader': '',
          'brand': '',
          'device': '',
          'display': '',
          'fingerprint': '',
          'hardware': '',
          'host': '',
          'id': '',
          'manufacturer': '',
          'product': '',
          'tags': '',
          'type': '',
          'isPhysicalDevice': true,
          'serialNumber': '',
          'displayMetrics': <String, dynamic>{
            'widthPx': 0.0,
            'heightPx': 0.0,
            'xDpi': 0.0,
            'yDpi': 0.0,
          },
        }),
      );
      final AppDeviceInformation info = await AppDeviceInformation.initialize(
        platformOverride: DevicePlatform.android,
      );

      expect(info.appName, 'App');
      expect(info.appVersion, '1.0.0');
      expect(info.os, 'Android');
      expect(info.model, 'Nokia 2');

      final Map<String, String> infoMap = info.toMap();
      expect(infoMap.containsKey('appName'), true);
      expect(infoMap.containsKey('packageName'), true);
    });

    test('should work normally for ios', () async {
      when(deviceInfoPlatform.deviceInfo).thenAnswer(
        (_) async => IosDeviceInfo.fromMap(<String, String>{'name': 'iPhone XS Max', 'systemName': 'iPadOS'}),
      );
      final AppDeviceInformation info = await AppDeviceInformation.initialize(
        platformOverride: DevicePlatform.ios,
      );

      expect(info.appName, 'App');
      expect(info.appVersion, '1.0.0');
      expect(info.os, 'iPadOS');
      expect(info.model, 'iPhone XS Max');

      final Map<String, String> infoMap = info.toMap();
      expect(infoMap.containsKey('appName'), true);
      expect(infoMap.containsKey('packageName'), true);
    });

    test('should work normally for web', () async {
      when(deviceInfoPlatform.deviceInfo).thenAnswer(
        (_) async => WebBrowserInfo.fromMap(<String, String>{'userAgent': 'Firefox', 'vendorSub': 'Windows'}),
      );
      final AppDeviceInformation info = await AppDeviceInformation.initialize(
        platformOverride: DevicePlatform.web,
      );

      expect(info.appName, 'App');
      expect(info.appVersion, '1.0.0');
      expect(info.os, 'firefox');
      expect(info.model, 'Windows');

      final Map<String, String> infoMap = info.toMap();
      expect(infoMap.containsKey('appName'), true);
      expect(infoMap.containsKey('packageName'), true);
    });
  });
}
