import 'package:flutter/material.dart';

// Page for showing the summary/details
class SummaryPage extends StatefulWidget {
  final List? friendListValues;
  const SummaryPage({super.key, this.friendListValues});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Appbar formatting
        appBar: AppBar(
            backgroundColor: Color.fromRGBO(26, 77, 46, 1),
            title: Text(widget.friendListValues?[0],
                style: TextStyle(color: Colors.white))),
        backgroundColor: Color.fromRGBO(245, 239, 230, 1),
        // Shows the summarry
        body: Column(children: [
          summary(),
          SizedBox(height: 10),
          // Back button formatting
          TextButton(
              style: TextButton.styleFrom(
                fixedSize: Size(80, 10),
                foregroundColor: Color.fromRGBO(255, 255, 255, 1),
                backgroundColor: Color.fromRGBO(79, 111, 82, 1),
              ),
              // Button icon
              child: Text("Back"),
              onPressed: () {
                Navigator.pop(context);
              })
        ]));
  }

  // Show summary function
  Padding summary() {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Padding(
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
                buildSummaryRow("Name", widget.friendListValues?[0]),
                buildSummaryRow("Nickname", widget.friendListValues?[1]),
                buildSummaryRow("Age", widget.friendListValues?[2]),
                buildSummaryRow(
                    "Relationship Status", widget.friendListValues?[3]),
                buildSummaryRow("Happiness Level", widget.friendListValues?[4]),
                buildSummaryRow("Superpower", widget.friendListValues?[5]),
                buildSummaryRow("Favorite Motto", widget.friendListValues?[6])
              ],
            ),
          ],
        ));
  }

  // Creates a summary row (Label: Value)
  Widget buildSummaryRow(String label, String? input) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(children: [
        // Label
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
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
