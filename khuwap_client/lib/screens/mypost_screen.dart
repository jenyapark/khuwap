import 'package:flutter/material.dart';
import '../services/exchange_service.dart';
import '../models/exchange_item.dart';
import '../widgets/exchange_card.dart';
import 'exchange_detail_screen.dart';

class MyPostScreen extends StatelessWidget {
  final String userId;
  const MyPostScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExchangeItem>>(
      future: ExchangeService.fetchMyPosts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("에러 발생"));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("데이터를 불러오지 못했습니다."));
        }

        final items = snapshot.data!;

        if (items.isEmpty) {
          return const Center(child: Text("작성한 교환 글이 없습니다."));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
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

              ),
            );
          },
        );
      },
    );
  }
}
