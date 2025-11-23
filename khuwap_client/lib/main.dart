import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'providers/chat_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web은 자동 로그인 비활성화 → 바로 LoginScreen 띄우기
  if (kIsWeb) {
    runApp(const MyApp(startScreen: LoginScreen()));
    return;
  }

  // 모바일은 secureStorage로 자동 로그인 사용
  const storage = FlutterSecureStorage();
  final userId = await storage.read(key: "user_id");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),   // 🔥 등록
      ],
      child: MyApp(
        startScreen: userId != null ? const HomeScreen() : const LoginScreen(),
      ),
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

