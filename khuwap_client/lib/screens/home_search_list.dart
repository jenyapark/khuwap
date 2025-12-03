import 'package:flutter/material.dart';
import 'package:khuwap_client/models/exchange_item.dart';
import 'package:khuwap_client/widgets/exchange_card.dart';
import 'package:khuwap_client/services/exchange_service.dart';
import '../screens/exchange_detail_screen.dart';

class HomeSearchList extends StatefulWidget {
  const HomeSearchList({super.key});

  @override
  State<HomeSearchList> createState() => _HomeSearchListState();
}

class _HomeSearchListState extends State<HomeSearchList> {
  List<ExchangeItem> originalList = [];
  List<ExchangeItem> filteredList = [];
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    const deepBrown = Color(0xFF4A2A25);

    return FutureBuilder<List<ExchangeItem>>(
      future: ExchangeService.fetchComposedList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (originalList.isEmpty) {
          originalList = snapshot.data!;
          filteredList = originalList;
        }

        return Column(
          children: [
            // ------------------ SEARCH ------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: deepBrown.withOpacity(0.25),
                  width: 1.2,
                ),
              ),
              child: TextField(
                style: TextStyle(color: deepBrown, fontSize: 15),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: deepBrown.withOpacity(0.6)),
                  border: InputBorder.none,
                  hintText: "Search for subjects...",
                  hintStyle: TextStyle(color: deepBrown.withOpacity(0.45)),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                    filteredList = originalList.where((item) {
                      return item.ownedTitle.toLowerCase().contains(
                            searchQuery,
                          ) ||
                          item.ownedProfessor.toLowerCase().contains(
                            searchQuery,
                          ) ||
                          item.ownedCourseCode.toLowerCase().contains(
                            searchQuery,
                          ) ||
                          item.desiredTitle.toLowerCase().contains(
                            searchQuery,
                          ) ||
                          item.note.toLowerCase().contains(searchQuery);
                    }).toList();
                  });
                },
              ),
            ),

            // ------------------ LIST VIEW ------------------
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Text(
                        "검색 결과가 없습니다.",
                        style: TextStyle(fontSize: 16, color: deepBrown),
                      ),
                    )
                  : ListView.builder(
                    reverse: true,
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];

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
                          child: buildExchangeCard(
                            item: item,
                            context: context,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
