import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';

// Page for showing the summary/details
class SummaryPage extends StatefulWidget {
  final Friend friend;
  const SummaryPage({super.key, required this.friend});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Appbar formatting
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(26, 77, 46, 1),
        ),
        backgroundColor: const Color.fromRGBO(245, 239, 230, 1),
        // Shows the summarry
        body: Column(children: [
          summary(),
          const SizedBox(height: 10),
          // Back button formatting
          TextButton(
              style: TextButton.styleFrom(
                fixedSize: const Size(80, 10),
                foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
                backgroundColor: const Color.fromRGBO(79, 111, 82, 1),
              ),
              // Button icon
              child: const Text("Back"),
              onPressed: () {
                Navigator.pop(context);
              })
        ]));
  }

  // Show summary function
  Padding summary() {
    return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Text(
                  "Summary",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(79, 111, 82, 1),
                  ),
                )),
            Column(
              children: [
                // Creates row of summary from the list
                buildSummaryRow("Name", widget.friend.name),
                buildSummaryRow("Nickname", widget.friend.nickname),
                buildSummaryRow("Age", widget.friend.age),
                buildSummaryRow(
                    "Relationship Status", widget.friend.relationshipStatus),
                buildSummaryRow(
                    "Happiness Level", widget.friend.happinessLevel),
                buildSummaryRow("Superpower", widget.friend.superpower),
                buildSummaryRow("Favorite Motto", widget.friend.motto)
              ],
            ),
          ],
        ));
  }

  // Creates a summary row (Label: Value)
  Widget buildSummaryRow(String label, String? input) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        // Label
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  color: Color.fromRGBO(79, 111, 82, 1),
                  fontWeight: FontWeight.bold)),
        ])),
        // Value
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text("${input}")],
        ))
      ]),
    );
  }
}
