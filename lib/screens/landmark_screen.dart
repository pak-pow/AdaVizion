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
      "title": "Main Gate Euthenics Marker",
      "subtitle": "Scan QR at location to unlock trivia.",
      "isUnlocked": false,
      "points": "+40 pts",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}