import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/kiosk_config.dart';
import 'screens/splash_page.dart';
import 'services/kiosk_api.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  debugPrint('Kiosk API => ${KioskConfig.apiBaseUrl}');
  debugPrint(
    'Kiosk camera mock: dart-define MOCK_CAMERA=${KioskConfig.mockCamera} '
    '(web debug also auto-mocks)',
  );
  runApp(const KioskApp());
}

class KioskApp extends StatelessWidget {
  const KioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapGo Kiosk',
      debugShowCheckedModeBanner: false,
      theme: buildKioskTheme(),
      home: KioskSplashPage(api: KioskApi()),
    );
  }
}
