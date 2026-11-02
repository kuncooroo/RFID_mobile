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

  debugPrint('WanderDesa System API => ${SystemConfig.apiBaseUrl}');
  debugPrint(
    'System camera mock: dart-define MOCK_CAMERA=${SystemConfig.mockCamera}',
  );
  runApp(const WanderDesaSystemApp());
}

class WanderDesaSystemApp extends StatelessWidget {
  const WanderDesaSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WanderDesa System',
      debugShowCheckedModeBanner: false,
      theme: buildSystemTheme(),
      home: SystemSplashPage(api: SystemApi()),
    );
  }
}
