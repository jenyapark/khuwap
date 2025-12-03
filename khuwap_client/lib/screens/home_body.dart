import 'package:flutter/material.dart';
import 'package:khuwap_client/models/exchange_item.dart';
import '../services/exchange_service.dart';
import '../services/auth_service.dart';
import 'exchange_detail_screen.dart';
import '../widgets/exchange_card.dart'; 
import 'exchange_post_screen.dart';
import '../screens/home_search_list.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    const ivory = Color(0xFFFAF8F3);
    const deepRed = Color(0xFF8B0000);
    const deepBrown = Color(0xFF4A2A25);

    return Scaffold(
      backgroundColor: ivory,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              Row(
                children: [
                  Icon(Icons.school, color: deepRed, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    "khuwap",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: deepBrown,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
      onTap: () async {
        await AuthService.logout();

        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/login",
          (route) => false,
        );
      },
      child: Icon(Icons.person_outline, color: deepBrown, size: 30),
    ),
  
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- SEARCH ----------------
              const Expanded(
                child: HomeSearchList(), 
          ),
            ],
          ),
        ),
      ),
        floatingActionButton: FloatingActionButton(
        backgroundColor: deepRed,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateExchangePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
