import 'package:flutter/material.dart';

class LandmarkScreen extends StatelessWidget {
  const LandmarkScreen({super.key});

  /* 
  The line `final List<Map<String, dynamic>> landmarks = const [];` is declaring a final variable
  named `landmarks` which is a list of maps. Each map in the list can have keys of type String and
  values of type dynamic. The `const` keyword is used to create a constant list, meaning that the list
  cannot be modified after it is initialized. 
  */

  /* 
  MOCK DATA (for now, since we are gonna be 
  pulling some data from a database)
  */
  final List<Map<String, dynamic>> landmarks = const [
    {
      "title": "University Library",
      "subtitle": "The library houses over 50,000 physical...",
      "isUnlocked": true,
      "points": "",
    },
    {
      "title": "CCJC Building",
      "subtitle": "Scan QR at location to unlock trivia.",
      "isUnlocked": false,
      "points": "+100 pts",
    },
    {
      "title": "Campus Bike Station",
      "subtitle": "Scan QR at location to unlock trivia.",
      "isUnlocked": false,
      "points": "+30 pts",
    },
    {
      "title": "AEC Theater",
      "subtitle": "Scan QR at location to unlock trivia.",
      "isUnlocked": false,
      "points": "+40 pts",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Campus Landmarks",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                itemCount: landmarks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = landmarks[index];
                  final bool isUnlocked = item["isUnlocked"];

                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isUnlocked
                            ? Colors.green.shade200
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isUnlocked
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          radius: 24,
                          child: Icon(
                            isUnlocked ? Icons.check_circle : Icons.location_on,
                            color: isUnlocked
                                ? Colors.green
                                : Colors.grey.shade500,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item["subtitle"],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isUnlocked ? "Unlocked" : item["points"],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked
                                    ? Colors.green
                                    : Colors.grey.shade500,
                              ),
                            ),
                            if (!isUnlocked) ...[
                              const SizedBox(height: 4),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
