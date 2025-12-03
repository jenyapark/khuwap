import 'package:flutter/material.dart';
import 'package:khuwap_client/screens/home_body.dart';
import 'package:khuwap_client/screens/myrequest_screen.dart';
import 'package:khuwap_client/screens/timetable_screen.dart';
import 'package:khuwap_client/screens/mypost_screen.dart';
import 'package:khuwap_client/screens/chat_list_screen.dart';
import 'package:khuwap_client/services/auth_service.dart';
import 'package:khuwap_client/screens/myrequest_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await AuthService.getUserId();
    setState(() {
      userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    const ivory = Color(0xFFFAF8F3);
    const deepRed = Color(0xFF8B0000);
    const deepBrown = Color(0xFF4A2A25);

    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      const HomeBody(),
      TimeTableScreen(userId: userId!),
      ChatListScreen(userId: userId!),
      MyRequestScreen(userId: userId!),
      MyPostScreen(userId: userId!),
    ];

    return Scaffold(
      backgroundColor: ivory,
      body: screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: ivory,
        selectedItemColor: deepRed,
        unselectedItemColor: deepBrown.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Message",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: "Request",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: "My Post",
          ),
        ],
      ),
    );
  }
}
