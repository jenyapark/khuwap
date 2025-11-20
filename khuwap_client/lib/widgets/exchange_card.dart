import 'package:flutter/material.dart';
import 'package:khuwap_client/models/exchange_item.dart';

// ---------------- 교환 글 카드 ----------------
  Widget buildExchangeCard({
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
