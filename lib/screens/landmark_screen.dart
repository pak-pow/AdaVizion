import 'package:flutter/material.dart';

/* 
Defines a new widget called LandmarkScreen.
It extends StatelessWidget because the UI does not need to change its
internal state dynamically after it is built (the mock data is static).
*/
class LandmarkScreen extends StatelessWidget {
  // The constructor for LandmarkScreen. The 'super.key' helps Flutter
  // identify this widget in the widget tree for efficient updates.
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

  // The build method is called every time Flutter needs to render this widget.
  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic visual structure for a screen (background, app bars, etc.)
    return Scaffold(
      // Sets a very light grey background color for the whole screen
      backgroundColor: Colors.grey[50],

      // Padding adds empty space around its child widget
      body: Padding(
        // Applies 16 pixels of horizontal padding (left and right)
        padding: const EdgeInsets.symmetric(horizontal: 16),

        // Column lays out its children vertically from top to bottom
        child: Column(
          // Aligns the children to the start (left side) of the cross-axis
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adds 20 pixels of vertical blank space at the top
            const SizedBox(height: 20),

            // Displays the main header text for the screen
            const Text(
              "Campus Landmarks",
              style: TextStyle(
                fontSize: 24, // Size of the font
                fontWeight: FontWeight.bold, // Makes the text bold
                color: Color(0xFF1E293B), // Dark slate/navy color
              ),
            ),

            // Adds 16 pixels of vertical blank space below the header
            const SizedBox(height: 16),

            // Expanded forces its child to fill the remaining available vertical space.
            // This is required here because a ListView needs to know its boundaries.
            Expanded(
              // ListView.separated creates a scrollable list of items with dividers between them
              child: ListView.separated(
                // Tells the list how many total items it needs to build
                itemCount: landmarks.length,

                // Builds the separator (gap) between each list item
                separatorBuilder: (context, index) => const SizedBox(
                  height: 12,
                ), // 12 pixels of space between items
                // Builds the actual UI for each item in the list based on its index
                itemBuilder: (context, index) {
                  // Extracts the specific map/dictionary for this row
                  final item = landmarks[index];
                  // Extracts the boolean to check if the landmark is unlocked
                  final bool isUnlocked = item["isUnlocked"];

                  // Container acts as a visually styled box for the list item
                  return Container(
                    // Adds space inside the box around the content
                    padding: const EdgeInsets.all(16.0),

                    // BoxDecoration allows us to style the Container (color, corners, borders)
                    decoration: BoxDecoration(
                      color: Colors.white, // White background for the card
                      borderRadius: BorderRadius.circular(
                        12.0,
                      ), // Rounded corners
                      // Adds a border around the card
                      border: Border.all(
                        // Conditional logic: Green border if unlocked, grey if not
                        color: isUnlocked
                            ? Colors.green.shade200
                            : Colors.grey.shade200,
                        width: 1.5, // Border thickness
                      ),

                      // Adds a subtle drop shadow to make the card "pop"
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(
                            0.02,
                          ), // Very faint black shadow
                          blurRadius: 8, // How soft the shadow is
                          offset: const Offset(
                            0,
                            4,
                          ), // Pushes the shadow 4 pixels down
                        ),
                      ],
                    ),

                    // Row lays out its children horizontally from left to right
                    child: Row(
                      children: [
                        // CircleAvatar creates a circular background for the icon
                        CircleAvatar(
                          // Green background if unlocked, grey if not
                          backgroundColor: isUnlocked
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          radius: 24, // Size of the circle
                          // The icon placed inside the circle
                          child: Icon(
                            // Shows a checkmark if unlocked, otherwise a map pin
                            isUnlocked ? Icons.check_circle : Icons.location_on,
                            // Green icon color if unlocked, grey if not
                            color: isUnlocked
                                ? Colors.green
                                : Colors.grey.shade500,
                            size: 28, // Size of the icon
                          ),
                        ),

                        // Adds 16 pixels of horizontal space between the icon and text
                        const SizedBox(width: 16),

                        // Expanded ensures the middle text section takes up all remaining
                        // middle space, pushing the trailing widget to the far right.
                        Expanded(
                          // Column stacks the title and subtitle vertically
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // Left-aligns text
                            children: [
                              // Displays the title from our mock data
                              Text(
                                item["title"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              // Small vertical gap between title and subtitle
                              const SizedBox(height: 4),
                              // Displays the subtitle from our mock data
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

                        // Column for the trailing part of the row (far right side)
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end, // Right-aligns content
                          children: [
                            // Displays either "Unlocked" or the points amount
                            Text(
                              isUnlocked ? "Unlocked" : item["points"],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                // Green text if unlocked, grey if not
                                color: isUnlocked
                                    ? Colors.green
                                    : Colors.grey.shade500,
                              ),
                            ),

                            // If it's NOT unlocked, show an arrow pointing right
                            if (!isUnlocked) ...[
                              // Small gap between points text and the arrow icon
                              const SizedBox(height: 4),
                              Icon(
                                Icons.chevron_right, // Right-facing arrow
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
