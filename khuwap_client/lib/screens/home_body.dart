import 'package:flutter/material.dart';
import 'package:khuwap_client/models/exchange_item.dart';
import '../services/exchange_service.dart';
import '../services/auth_service.dart';
import 'exchange_detail_screen.dart';
import '../widgets/exchange_card.dart'; 
import 'exchange_post_screen.dart';


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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: deepBrown.withOpacity(0.25), width: 1.2),
                ),
                child: TextField(
                  style: TextStyle(color: deepBrown, fontSize: 15),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: deepBrown.withOpacity(0.6)),
                    border: InputBorder.none,
                    hintText: "Search for subjects...",
                    hintStyle: TextStyle(color: deepBrown.withOpacity(0.45)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- LIST VIEW ----------------
              Expanded(
                child: FutureBuilder<List<ExchangeItem>>(
                  future: ExchangeService.fetchComposedList(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final list = snapshot.data!;

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExchangeDetailScreen(
                                  ownedTitle: item.ownedTitle,
                                  ownedProfessor: item.ownedProfessor,
                                  ownedDay: item.ownedDay,
                                  ownedStart: item.ownedStart,
                                  ownedEnd: item.ownedEnd,
                                  ownedCourseCode: item.ownedCourseCode,
                                  ownedRoom: item.ownedRoom,
                                  ownedCredit: item.ownedCredit.toString(),
                                  desiredTitle: item.desiredTitle,
                                  desiredProfessor: item.desiredProfessor,
                                  desiredDay: item.desiredDay,
                                  desiredStart: item.desiredStart,
                                  desiredEnd: item.desiredEnd,
                                  desiredCourseCode: item.desiredCourseCode,
                                  desiredRoom: item.desiredRoom,
                                  desiredCredit: item.desiredCredit.toString(),
                                  note: item.note,
                                  postUUID: item.postUUID,
                                  authorId: item.authorId,
                                ),
                              ),
                            );
                          },

                          child: buildExchangeCard(item: item, context: context)
);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: deepRed,
        shape: const CircleBorder(),
        onPressed: () {Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateExchangePostScreen(),
      ),
    );},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}