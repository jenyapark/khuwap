import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'providers/chat_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Widget startScreen;

  if (kIsWeb) {
    // 웹에서는 자동로그인 사용 불가
    startScreen = const LoginScreen();
  } else {
    // 모바일: secureStorage 기반 자동 로그인
    const storage = FlutterSecureStorage();
    final userId = await storage.read(key: "user_id");

    if (userId != null) {
      startScreen = const HomeScreen();
    } else {
      startScreen = const LoginScreen();
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(startScreen: startScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHUWAP Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: startScreen,
    );
  }
}
