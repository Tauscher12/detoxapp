import 'package:flutter/material.dart';
import '../widgets/challenge_list.dart';

class ChallengesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tägliche Challenges')),
      body: ChallengeList(), // Widget mit einer Liste der Challenges
    );
  }
}
