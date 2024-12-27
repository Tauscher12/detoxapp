import 'package:flutter/material.dart';

class ChallengeList extends StatefulWidget {
  const ChallengeList({super.key});
   @override
  State<StatefulWidget> createState() {
    return _ChallengeListState();
  }
}
class _ChallengeListState extends State<ChallengeList>
{
   List<String> challenges = [
    "1 Stunde ohne Handy",
    "20 Minuten lesen",
    "Kein Social Media bis 18 Uhr",
  ];

  @override
  Widget build(BuildContext context) {
 return ListView.builder(
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text(challenges[index]),
          trailing:const Icon(Icons.arrow_forward),
        );
      },
    );
  }
  
}