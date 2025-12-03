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
      providers: [ChangeNotifierProvider(create: (_) => ChatProvider())],
      child: MyApp(startScreen: startScreen),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 앱 라이프사이클 상태 변화 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      try {
        Provider.of<ChatProvider>(context, listen: false).disposeChat();
        print(">>> App Lifecycle: WebSocket disconnected cleanly.");
      } catch (e) {
        print("Lifecycle dispose error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KHUWAP Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: widget.startScreen,
      routes: {
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),
      },
    );
  }
}
