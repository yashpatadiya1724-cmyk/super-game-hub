import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Storage
  await StorageService.init();

  runApp(const SuperGameHub());
}

class SuperGameHub extends StatelessWidget {
  const SuperGameHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Game Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
