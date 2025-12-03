import 'package:flutter/material.dart';
import '../services/exchange_service.dart';
import '../models/request_item.dart';
import '../models/exchange_item.dart';
import '../widgets/exchange_card.dart';
import 'exchange_detail_screen.dart';

class MyRequestScreen extends StatelessWidget {
  final String userId;

  const MyRequestScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        title: const Text(
          "Sent Requests",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF3E2A25),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: FutureBuilder<List<RequestItem>>(
        future: ExchangeService.fetchSentRequests(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text("에러: ${snapshot.error}");
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("데이터를 불러오지 못했습니다."));
          }

          final requestItems = snapshot.data!;

          if (requestItems.isEmpty) {
            return const Center(child: Text("보낸 요청이 없습니다."));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 10),
            itemCount: requestItems.length,
            itemBuilder: (context, index) {
              final req = requestItems[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                child: FutureBuilder<ExchangeItem?>(
                  future: ExchangeService.requestItemToExchangeItem(req),

                  builder: (context, postSnapshot) {
                    if (postSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        height: 140,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!postSnapshot.hasData) {
                      return const Text("게시글 정보를 불러오지 못했습니다.");
                    }

                    final post = postSnapshot.data!;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExchangeDetailScreen(
                              ownedTitle: post.ownedTitle,
                              ownedProfessor: post.ownedProfessor,
                              ownedDay: post.ownedDay,
                              ownedStart: post.ownedStart,
                              ownedEnd: post.ownedEnd,
                              ownedCourseCode: post.ownedCourseCode,
                              ownedRoom: post.ownedRoom,
                              ownedCredit: post.ownedCredit.toString(),
                              desiredTitle: post.desiredTitle,
                              desiredProfessor: post.desiredProfessor,
                              desiredDay: post.desiredDay,
                              desiredStart: post.desiredStart,
                              desiredEnd: post.desiredEnd,
                              desiredCourseCode: post.desiredCourseCode,
                              desiredRoom: post.desiredRoom,
                              desiredCredit: post.desiredCredit.toString(),
                              note: post.note,
                              postUUID: req.postUUID,
                              authorId: post.authorId,
                              requesterId: req.requesterId,
                              requestUUID: req.requestUUID,
                              requestStatus: req.status,
                            ),
                          ),
                        );
                      },

                      child: buildExchangeCard(item: post, context: context),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
