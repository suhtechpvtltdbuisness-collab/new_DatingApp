import 'package:flutter/material.dart';
import 'First_Date_Advice_Screen.dart';
import 'Conversation_Starter_Screen.dart';
import 'Red_Flag_Screen.dart';
import 'Improved_Profile_Screen.dart';

class DatingTipsScreen extends StatelessWidget {
  const DatingTipsScreen({super.key});

  Widget buildCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFF04D8C)),
          ),

          const SizedBox(height: 12),

          /// TITLE
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

          const SizedBox(height: 6),

          /// SUBTITLE
          Expanded(
            child: Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ✅ GRADIENT LIKE YOUR DESIGN
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFD3DC), Color(0xFFD6C4F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              /// APP BAR
              Row(
                children: const [
                  BackButton(color: Colors.black),
                  Text(
                    "Dating Tips",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              /// GRID
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: 4,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,

                          /// ✅ FIXED RATIO (VERY IMPORTANT)
                          childAspectRatio: 0.75,
                        ),
                    itemBuilder: (context, index) {
                      final data = [
                        [
                          Icons.favorite,
                          "First date advice",
                          "Tips to make a strong first impression.",
                        ],
                        [
                          Icons.chat_bubble_outline,
                          "Conversation starters",
                          "Ways to keep conversations flowing easily.",
                        ],
                        [
                          Icons.flag,
                          "Red flags to watch",
                          "Notice warning signs before things get serious.",
                        ],
                        [
                          Icons.flash_on,
                          "Improve your profile",
                          "Tips to boost matches and interest.",
                        ],
                      ];

                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FirstDateAdviceScreen(),
                              ),
                            );
                          } else if (index == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ConversationStarterScreen(),
                              ),
                            );
                          }
                            else if (index == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RedFlagScreen(),
                                ),
                              );
                            } else {
                              // For "Improve your profile", you can add another screen or action here.
                               Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ImprovedProfileScreen(),
                                ),
                              );
                            }
                        },
                        child: buildCard(
                          data[index][0] as IconData,
                          data[index][1] as String,
                          data[index][2] as String,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
