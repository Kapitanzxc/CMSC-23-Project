import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/friends_provider.dart';
import 'package:tolentino_mini_project/provider/users_provider.dart';

class SlamBook extends StatefulWidget {
  const SlamBook({super.key});

  @override
  State<SlamBook> createState() => _SlamBookState();
}

class _SlamBookState extends State<SlamBook> {
  // List of superpowers
  List<String> superpowers = [
    "Super Strength",
    "Flight",
    "Invisibility",
    "Telepathy",
    "Telekinesis",
    "Super Speed",
    "Healing Factor",
    "Shape-shifting",
    "Elemental Control",
    "Time Manipulation",
    "Immortality",
  ];

  // Text Editor Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Initial values of the fields
  String dropdownValue = "Super Strength";
  int radioValue = 1;
  bool switchLight = false;
  double currentSliderValue = 0;
  bool showSummary = false;

  // Variables for saving the fields
  late String saveName;
  late String saveNickname;
  late String saveAge;
  late String saveRelationshipStatus;
  late String saveHappinessLvl;
  late String saveSuperPower;
  late String saveMotto;

  // Disposing controllers
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    nicknameController.dispose();
    ageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Drawer
        drawer: drawer(),
        // Personalizing the appbar and background color
        backgroundColor: Color.fromRGBO(245, 239, 230, 1),
        appBar: AppBar(
            backgroundColor: Color.fromRGBO(26, 77, 46, 1),
            title: Text("Slambook", style: TextStyle(color: Colors.white))),
        // The body is a single child scroll view
        body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            // Column composed of rows [Title, Form Widget (TextFields, Switch, Slider, Dropdown, Radio, and Submit buttons)]
            child: Column(
              children: [
                // Title
                Text(
                  "My Friends' Slambook",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(79, 111, 82, 1)),
                ),
                SizedBox(height: 20),
                // Form Widget
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Name and Nickname Field
                      textFieldCreator(nameController, "Name"),
                      textFieldCreator(nicknameController, "Nickname"),
                      // Age and Relationship Status Field
                      Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          // Row compose of age and status
                          child: Row(children: [
                            // Age
                            Flexible(
                                child: TextFormField(
                              controller: ageController,
                              validator: (val) {
                                // Validators
                                if (val == null || val.isEmpty) {
                                  return "This is a required field";
                                } else if (int.tryParse(val) == null ||
                                    int.parse(val) <= 0) {
                                  return "Please enter a valid age";
                                } else {
                                  return null;
                                }
                              },
                              // Decoration
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Age"),
                            )),
                            // Relationship status
                            Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: Text("Are you single?")),
                            // Switch
                            Switch(
                              // Bool value that toggles the switch
                              value: switchLight,
                              activeColor: Color.fromRGBO(79, 111, 82, 1),
                              onChanged: (bool value) {
                                // Update bool value when changed
                                setState(() {
                                  switchLight = value;
                                });
                              },
                            )
                          ])),
                      // Happiness Level and its slider
                      headerText("Happiness Level"),
                      Text(
                          "On a scale of 0 (Hopeless) to 10 (Very Happy), how would you rate your current lifestyle?",
                          textAlign: TextAlign.center),
                      // Slider
                      Slider(
                        value: currentSliderValue,
                        // From 0: 10
                        max: 10,
                        divisions: 10,
                        label: currentSliderValue.round().toString(),
                        activeColor: Color.fromRGBO(79, 111, 82, 1),
                        onChanged: (double value) {
                          setState(() {
                            // Update slider value on change
                            currentSliderValue = value;
                          });
                        },
                      ),
                      // Superpower and its dropdown
                      headerText("Superpower"),
                      Text(
                          "If you were to have a superpower, what would it be?",
                          textAlign: TextAlign.center),
                      // Dropdown
                      Padding(
                          padding: EdgeInsets.only(
                              top: 20, left: 40, right: 40, bottom: 20),
                          // Creation of drowdownbutton
                          child: DropdownButtonFormField(
                            value: dropdownValue,
                            items: superpowers.map((item) {
                              return DropdownMenuItem(
                                  child: Text(item), value: item);
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                // Updates dropdown value on changed
                                dropdownValue = val!;
                              });
                            },
                            // decoration: InputDecoration(fillColor: )
                          )),
                      // Motto and radioboxes
                      headerText("Motto"),
                      Column(
                        children: <Widget>[
                          // Radioboxes
                          radioCreators(
                              Text("When life gives you lemons, make lemonade"),
                              1),
                          radioCreators(
                              Text("Life every day like it's your last"), 2),
                          radioCreators(
                              Text(
                                  "Be yourself. Everyone else is already taken"),
                              3),
                          radioCreators(
                              Text(
                                  "Be the change you wish to see in the world"),
                              4),
                          radioCreators(
                              Text(
                                  "If you are not obsessed with your life, change it"),
                              5),
                          radioCreators(Text("Take small steps every day"), 6),
                          radioCreators(
                              Text("Be a rainbow in someone else's cloud"), 7),
                        ],
                      ),
                      // Show summary when submit button is pressed
                      if (showSummary) summary(),
                      // Buttons for resetting and submitting form
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Button for resetting the form
                          OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Color.fromRGBO(79, 111, 82, 1)),
                              ),
                              // When pressed, reset the form
                              onPressed: () {
                                formKey.currentState!.reset();
                                setState(() {
                                  resetForm();
                                });
                              },
                              // Reset icon
                              icon: const Icon(Icons.restart_alt,
                                  color: Color.fromRGBO(79, 111, 82, 1)),
                              label: Text("Reset",
                                  style: TextStyle(
                                      color: Color.fromRGBO(0, 0, 0, 1)))),
                          SizedBox(width: 10),
                          // Button for submitting the form
                          TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Color.fromRGBO(255, 255, 255, 1),
                                backgroundColor: Color.fromRGBO(79, 111, 82, 1),
                              ),
                              // When pressed, submit the form only if it is validated and showSummary is not displayed
                              onPressed: () {
                                if (formKey.currentState!.validate() &&
                                    !showSummary) {
                                  submitForm();
                                }
                              },
                              // Submit icon
                              icon: const Icon(Icons.send, size: 20),
                              label: const Text("Submit",
                                  style: TextStyle(
                                      color:
                                          Color.fromRGBO(255, 255, 255, 1)))),
                        ],
                      )
                    ],
                  ),
                )
              ],
            )));
  }

  // Drawer Function
  Widget drawer() {
    return Drawer(
      child: ListView(
        children: [
          // Drawer title formatting
          Container(
            color: Color.fromRGBO(26, 77, 46, 1),
            height: 100,
            child: DrawerHeader(
                child: Text(
              "Exercise 5: Menu, Routes, and Navigation",
              style: TextStyle(
                  fontSize: 20, color: Color.fromRGBO(243, 243, 243, 1)),
            )),
          ),
          // Friends tab
          ListTile(
            title: Text("Friends"),
            onTap: () {
              // Pops the drawer
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          // Slambook Tab (closes the drawer)
          ListTile(
            title: Text("Slambook"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Text field formatting function
  Padding textFieldCreator(TextEditingController controller, String labelText) {
    return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: TextFormField(
          controller: controller,
          // Validation
          validator: (val) {
            if (val == null || val.isEmpty || val.trim().isEmpty)
              return "This is a required field";
            return null;
          },
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: labelText),
        ));
  }

  // Header formatting function
  Text headerText(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(79, 111, 82, 1)),
    );
  }

  // Radio creator function
  ListTile radioCreators(Widget motto, int value) {
    return ListTile(
      title: motto,
      leading: Radio<int>(
        value: value,
        groupValue: radioValue,
        onChanged: (int? value) {
          setState(() {
            radioValue = value!;
          });
        },
      ),
    );
  }

  // Show summary function
  Padding summary() {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Divider(
              color: Color.fromRGBO(79, 111, 82, 1),
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Summary",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(79, 111, 82, 1),
                  ),
                )),
            Column(
              children: [
                // Creates row of summary
                buildSummaryRow("Name", saveName),
                buildSummaryRow("Nickname", saveNickname),
                buildSummaryRow("Age", saveAge),
                buildSummaryRow("Relationship Status", saveRelationshipStatus),
                buildSummaryRow("Happiness Level", saveHappinessLvl),
                buildSummaryRow("Superpower", saveSuperPower),
                buildSummaryRow("Favorite Motto", saveMotto)
              ],
            ),
          ],
        ));
  }

  // Function for saving the form
  void submitForm() {
    // Saving the variables from the form
    setState(() {
      saveName = nameController.text;
      saveNickname = nicknameController.text;
      saveAge = ageController.text;
      saveRelationshipStatus = switchLight ? "Single" : "Not Single";
      saveHappinessLvl = currentSliderValue.toString();
      saveSuperPower = dropdownValue;
      saveMotto = motto(radioValue);
      // Assigning the new values in the friendList
      // Instantiate a todo objeect to be inserted, default userID will be 1, the id will be the next id in the list
      Friend temp = Friend(
          name: saveName,
          nickname: saveNickname,
          age: saveAge,
          relationshipStatus: saveRelationshipStatus,
          happinessLevel: saveHappinessLvl,
          superpower: saveSuperPower,
          motto: saveMotto);
      appendFriend(temp);
      showSummary = true; // Show summary
    });
    // Print statement
    print("Submitted! Summary displayed");
  }

  Future<void> appendFriend(Friend temp) async {
    String? uid = context.read<UserAuthProvider>().getCurrentUserId();
    String? documentID =
        await context.read<FriendListProvider>().addFriend(uid!, temp);
    print("Friend ID: $documentID UID: $uid");
    if (documentID != null && uid != null) {
      await context.read<UserInfoProvider>().addFriend(uid, documentID);
      showSummary = true; // Show summary
    } else {
      print("Failed to add friend.");
      // Handle error or retry logic here
    }
  }

  // Reset function
  void resetForm() {
    // Resetting the variables
    nameController.clear();
    nicknameController.clear();
    ageController.clear();
    dropdownValue = "Super Strength";
    radioValue = 1;
    switchLight = false;
    currentSliderValue = 0;
    showSummary = false;
  }

  // Returns the motto string given a value
  String motto(int radioValue) {
    switch (radioValue) {
      case 1:
        return "When life gives you lemons, make lemonade";
      case 2:
        return "Live every day like it's your last";
      case 3:
        return "Be yourself. Everyone else is already taken";
      case 4:
        return "Be the change you wish to see in the world";
      case 5:
        return "If you are not obsessed with your life, change it";
      case 6:
        return "Take small steps every day";
      case 7:
        return "Be a rainbow in someone else's cloud";
      default:
        return "";
    }
  }

  // Creates a summary row (Label: Value)
  Widget buildSummaryRow(String label, String? input) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(children: [
        // Label Formatting
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  color: Color.fromRGBO(79, 111, 82, 1),
                  fontWeight: FontWeight.bold)),
        ])),
        // Value Formatting
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(input ?? "")],
        ))
      ]),
    );
  }
}
