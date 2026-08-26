import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/system_config.dart';
import 'screens/splash_page.dart';
import 'services/system_api.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  debugPrint('TapGo System API => ${SystemConfig.apiBaseUrl}');
  debugPrint(
    'System camera mock: dart-define MOCK_CAMERA=${SystemConfig.mockCamera}',
  );
  runApp(const TapGoSystemApp());
}

class TapGoSystemApp extends StatelessWidget {
  const TapGoSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapGo System',
      debugShowCheckedModeBanner: false,
      theme: buildSystemTheme(),
      home: SystemSplashPage(api: SystemApi()),
    );
  }
}
