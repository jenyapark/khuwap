import 'package:flutter/material.dart';
import 'package:khuwap_client/models/exchange_item.dart';
import '../services/exchange_service.dart';
import 'exchange_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  Icon(Icons.person_outline, color: deepBrown, size: 30),
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
                                ),
                              ),
                            );
                          },
                          child: _buildExchangeCard(item: item),
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
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ivory,
        selectedItemColor: deepRed,
        unselectedItemColor: deepBrown.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Message"),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "Request"),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: "My Post"),
        ],
      ),
    );
  }

  // ---------------- CARD ----------------
  Widget _buildExchangeCard({
    required ExchangeItem item,
  }) {
    const borderColor = Color(0xFFE2E2E2);
    const textColor = Color(0xFF3E2A25);

    String schedule(String d, String s, String e) => "$d  $s-$e";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 145,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1),
            ),
          ),

          Stack(
            alignment: Alignment.center,
            children: const [
              Icon(Icons.swap_horiz, size: 44, color: Color(0xFF4A2A25)),
              Icon(Icons.swap_horiz, size: 40, color: Color(0xFF7A0E1D)),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                // OWNED
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("owned",
                          style: TextStyle(
                              fontSize: 13, color: textColor.withOpacity(0.6))),
                      const SizedBox(height: 10),

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          item.ownedTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        item.ownedProfessor,
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.1,
                            color: textColor.withOpacity(0.8)),
                      ),
                      Text(
                        schedule(
                          item.ownedDay,
                          item.ownedStart,
                          item.ownedEnd,
                        ),
                        style: TextStyle(
                            fontSize: 12, color: textColor.withOpacity(0.65)),
                      ),
                    ],
                  ),
                ),

                // DESIRED
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("desired",
                          style: TextStyle(
                              fontSize: 13, color: textColor.withOpacity(0.6))),
                      const SizedBox(height: 10),

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(
                          item.desiredTitle,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        item.desiredProfessor,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 13,
                            color: textColor.withOpacity(0.8)),
                      ),
                      Text(
                        schedule(
                          item.desiredDay,
                          item.desiredStart,
                          item.desiredEnd,
                        ),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12, color: textColor.withOpacity(0.65)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}