import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/android_features/camera_feat.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/image-storage_provider.dart';
import 'package:tolentino_mini_project/provider/user-friend_provider.dart';

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
  int _currentIndex = 1;
  Color selectedTileColor = Formatting.primary;
  // disable button
  bool isButtonEnabled = false;
  File? _imageFile;

  // Variables for saving the fields
  late String saveName;
  late String saveNickname;
  late String saveAge;
  late String saveRelationshipStatus;
  late String saveHappinessLvl;
  late String saveSuperPower;
  late String saveMotto;

  // Initializing camera feature
  final CameraFeature _cameraFeature = CameraFeature();

  // Updates the button if fields are empty
  void _checkFields() {
    setState(() {
      if (nameController.text.isNotEmpty &&
          nicknameController.text.isNotEmpty &&
          ageController.text.isNotEmpty) {
        isButtonEnabled = true;
      } else {
        isButtonEnabled = false;
      }
    });
  }

  // Disposing controllers
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    nicknameController.dispose();
    ageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Listeners to the controllers
    nameController.addListener(_checkFields);
    nicknameController.addListener(_checkFields);
    ageController.addListener(_checkFields);
    // Asking user's permission
    _cameraFeature.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: theme(),
        child: Scaffold(
            // Bottom Navigation Bar
            bottomNavigationBar: bottomNavigationBar(),
            // Personalizing the appbar and background color
            backgroundColor: const Color.fromARGB(255, 244, 244, 244),
            // The body is a single child scroll view
            body: buildContent()));
  }

  Widget buildContent() {
    return SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24),
        // Column composed of rows [Title, Form Widget (TextFields, Switch, Slider, Dropdown, Radio, and Submit buttons)]
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Title
            Text("Add a Friend",
                style: Formatting.semiBoldStyle.copyWith(
                  fontSize: 24,
                  color: Formatting.black,
                )),
            const SizedBox(height: 24),
            // Form Widget
            Form(
              key: formKey,
              child: Column(
                children: [
                  profilePicture,
                  // Name and Nickname Field
                  textFieldCreator(nameController, "Name"),
                  textFieldCreator(nicknameController, "Nickname"),
                  // Age and Relationship Status Field
                  Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      // Row compose of age and status
                      child: Row(children: [
                        // Age
                        ageFormField(),
                        // Relationship status
                        Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Text("Are you single?",
                                style: Formatting.regularStyle.copyWith(
                                    fontSize: 16, color: Formatting.black))),
                        // Switch
                        relationshipFormField(),
                      ])),
                  // Happiness Level and its slider
                  headerText("Happiness Level"),
                  Text(
                      "On a scale of 0 (Hopeless) to 10 (Very Happy), how would you rate your current lifestyle?",
                      style: Formatting.regularStyle
                          .copyWith(fontSize: 12, color: Formatting.black),
                      textAlign: TextAlign.center),
                  // Slider
                  happinessFormField(),
                  // Superpower and its dropdown
                  headerText("Superpower"),
                  Text("If you were to have a superpower, what would it be?",
                      style: Formatting.regularStyle
                          .copyWith(fontSize: 12, color: Formatting.black),
                      textAlign: TextAlign.center),
                  // Dropdown
                  superpowerFormField(),
                  // Motto and radioboxes
                  headerText("Motto"),
                  radioFormFields(),
                  // Buttons for resetting and submitting form
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Button for resetting the form
                Expanded(child: resetFormButtom()),
                const SizedBox(width: 8),
                // Button for submitting the form
                Expanded(child: submitFormButton()),
              ],
            ),
            const SizedBox(height: 16)
          ],
        ));
  }

  // Show summary dialog
  void summaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Frog-tastic! Friend Added!",
                    textAlign: TextAlign.center,
                    style: Formatting.boldStyle.copyWith(
                      fontSize: 24,
                      color: Formatting.black,
                    ),
                  ),
                ),
                // Creates row of label and value
                Row(children: [
                  Expanded(child: buildSummaryRow("Name", saveName))
                ]),
                Row(children: [
                  Expanded(child: buildSummaryRow("Nickname", saveNickname))
                ]),
                Row(children: [
                  Expanded(child: buildSummaryRow("Age", saveAge)),
                  Expanded(
                      child:
                          buildSummaryRow("Happiness Level", saveHappinessLvl)),
                ]),
                Row(children: [
                  Expanded(
                      child: buildSummaryRow(
                          "Relationship Status", saveRelationshipStatus))
                ]),
                Row(children: [
                  Expanded(child: buildSummaryRow("Superpower", saveSuperPower))
                ]),
                Row(children: [
                  Expanded(child: buildSummaryRow("Favorite Motto", saveMotto))
                ]),
              ],
            ),
          ),
          actions: <Widget>[
            // Add more friend button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  formKey.currentState!.reset();
                  setState(() {
                    resetForm();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Add more friends',
                  style: Formatting.mediumStyle.copyWith(
                      fontSize: 16, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Go to friends page button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Pop the context then navigate to the friends page
                  Navigator.pop(context);
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                  Navigator.pushNamed(context, "/friendspage");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Formatting.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Go to friends page',
                  style: Formatting.mediumStyle.copyWith(
                      fontSize: 16,
                      color: const Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Creates a summary row (Label: Value)
  Widget buildSummaryRow(String label, String? input) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Value Formatting
      Text(input ?? "",
          softWrap: true,
          style: Formatting.semiBoldStyle
              .copyWith(fontSize: 16, color: Formatting.black)),

      // Label Formatting
      Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(label,
              style: Formatting.regularStyle
                  .copyWith(fontSize: 12, color: Formatting.black)))
    ]);
  }

  // Button for submitting the form
  Widget submitFormButton() {
    return SizedBox(
        height: 48,
        child: ElevatedButton(
          // Show button if enabled
          onPressed: isButtonEnabled
              ? () {
                  if (formKey.currentState!.validate() && !showSummary) {
                    submitForm();
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Formatting.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
          child: Text(
            'Submit',
            style: Formatting.mediumStyle.copyWith(
                fontSize: 16, color: const Color.fromRGBO(255, 255, 255, 1)),
          ),
        ));
  }

  // Profile picture
  Widget get profilePicture => Stack(
        children: [
          // If no image file existing, show the default pfp
          _imageFile != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                      width: 140,
                      height: 140,
                      child: ClipOval(
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )))
              : Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                      width: 140,
                      height: 140,
                      child: ClipOval(
                        child: Image.asset("assets/default_pfp.jpg",
                            fit: BoxFit.cover),
                      ))),
          // Add Button
          Positioned(
            top: 100,
            right: 0,
            child: IconButton(
              // Calls photoOptions/camera
              onPressed: () => _photoOptions(context),
              icon: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(1),
                  child: Icon(Icons.add, color: Colors.black),
                ),
              ),
            ),
          )
        ],
      );

  // Function for showing photo options
  void _photoOptions(BuildContext context) {
    // Shows a bottom modal sheet
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Take a picture
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a picture'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await _cameraFeature.takePicture();
                setState(() {
                  _imageFile = image;
                });
              },
            ),
            // Choose from gallery
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await _cameraFeature.chooseFromGallery();
                setState(() {
                  _imageFile = image;
                });
              },
            ),
            // Delete option
            if (_imageFile != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    _imageFile = null;
                  });
                },
              )
          ],
        );
      },
    );
  }

  // Function for saving the form
  void submitForm() async {
    // Saving the variables from the form
    saveName = nameController.text;
    saveNickname = nicknameController.text;
    saveAge = ageController.text;
    saveRelationshipStatus = switchLight ? "Single" : "Not Single";
    saveHappinessLvl = currentSliderValue.toString();
    saveSuperPower = dropdownValue;
    saveMotto = motto(radioValue);
    String? downloadURL;

    // Upload profile picture to the cloud
    if (_imageFile != null) {
      String? uid = context.read<UserAuthProvider>().getCurrentUserId();
      downloadURL = await context
          .read<StorageProvider>()
          .uploadFriendProfilePicture(uid!, saveName, _imageFile);
    }

    // Assigning the new values in the friendList
    Friend temp = Friend(
        verified: "No",
        name: saveName,
        nickname: saveNickname,
        age: saveAge,
        relationshipStatus: saveRelationshipStatus,
        happinessLevel: saveHappinessLvl,
        superpower: saveSuperPower,
        motto: saveMotto,
        profilePictureURL: downloadURL);

    // Adding the friend to the user's firebase
    String? uid = context.read<UserAuthProvider>().getCurrentUserId();
    await context.read<FriendListProvider>().addFriend(uid!, temp);

    setState(() {
      summaryDialog(context);
      // Show summary
      showSummary = true;
    });

    // Print statement
    print("Submitted! Summary displayed");
  }

  // Button for resetting the form
  Widget resetFormButtom() {
    return SizedBox(
        height: 48,
        child: ElevatedButton(
          // Show button if enabled
          onPressed: () {
            formKey.currentState!.reset();
            setState(() {
              resetForm();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
          child: Text(
            'Reset',
            style: Formatting.mediumStyle.copyWith(
                fontSize: 16, color: const Color.fromARGB(255, 0, 0, 0)),
          ),
        ));
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
    _imageFile = null;
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

  // Age form field
  Widget ageFormField() {
    return Flexible(
        child: TextFormField(
      controller: ageController,
      validator: (val) {
        // Validators
        if (val == null || val.isEmpty) {
          return "This is a required field";
        } else if (int.tryParse(val) == null || int.parse(val) <= 0) {
          return "Please enter a valid age";
        } else {
          return null;
        }
      },
      // Decoration
      decoration:
          const InputDecoration(border: OutlineInputBorder(), labelText: "Age"),
    ));
  }

  // Relationship form field
  Widget relationshipFormField() {
    return Switch(
      // Bool value that toggles the switch
      value: switchLight,
      activeColor: Formatting.primary,
      onChanged: (bool value) {
        // Update bool value when changed
        setState(() {
          switchLight = value;
        });
      },
    );
  }

  // Happiness level form field
  Widget happinessFormField() {
    return Slider(
      value: currentSliderValue,
      // From 0: 10
      max: 10,
      divisions: 10,
      label: currentSliderValue.round().toString(),
      activeColor: Formatting.primary,
      onChanged: (double value) {
        setState(() {
          // Update slider value on change
          currentSliderValue = value;
        });
      },
    );
  }

// Superpower form field
  Widget superpowerFormField() {
    return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        // Creation of drowdownbutton
        child: DropdownButtonFormField(
            value: dropdownValue,
            items: superpowers.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                // Updates dropdown value on changed
                dropdownValue = val!;
              });
            }
            // decoration: InputDecoration(fillColor: )
            ));
  }

  // Text field formatting function
  Padding textFieldCreator(TextEditingController controller, String labelText) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          // Validation
          validator: (val) {
            if (val == null || val.isEmpty || val.trim().isEmpty) {
              return "This is a required field";
            }
            return null;
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(), labelText: labelText),
        ));
  }

  // Header formatting function
  Text headerText(String title) {
    return Text(title,
        style: Formatting.semiBoldStyle.copyWith(
          fontSize: 20,
          color: Formatting.black,
        ));
  }

  // Radio creator function
  ListTile radioCreators(Widget motto, int value) {
    return ListTile(
      title: motto,
      leading: Radio<int>(
        value: value,
        groupValue: radioValue,
        activeColor: Formatting.primary, // Set the active color here
        onChanged: (int? value) {
          setState(() {
            radioValue = value!;
          });
        },
      ),
    );
  }

  Widget radioFormFields() {
    return Column(
      children: <Widget>[
        // Radioboxes
        radioCreators(
            Text("When life gives you lemons, make lemonade",
                style: Formatting.regularStyle
                    .copyWith(fontSize: 16, color: Formatting.black)),
            1),
        radioCreators(
            Text("Live every day like it's your last",
                style: Formatting.regularStyle
                    .copyWith(fontSize: 16, color: Formatting.black)),
            2),
        radioCreators(
            Text("Be yourself. Everyone else is already taken",
                style: Formatting.regularStyle
                    .copyWith(fontSize: 16, color: Formatting.black)),
            3),
        radioCreators(
            Text("Be the change you wish to see in the world",
                style: Formatting.regularStyle
                    .copyWith(fontSize: 16, color: Formatting.black)),
            4),
        radioCreators(
            Text("If you are not obsessed with your life, change it",
                style: Formatting.regularStyle
                    .copyWith(fontSize: 16, color: Formatting.black)),
            5),
        radioCreators(
            Text("Take small steps every day",
                style: Formatting.regularStyle
                    .copyWith(fontSize: 16, color: Formatting.black)),
            6),
        radioCreators(
            Text("Be a rainbow in someone else's cloud",
                style: Formatting.regularStyle
                    .copyWith(fontSize: 16, color: Formatting.black)),
            7),
      ],
    );
  }

  // Themes
  ThemeData theme() {
    return ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Formatting.primary,
      onTap: (index) {
        if (index == _currentIndex) {
          // Do nothing if tapping on the current tab
          return;
        }

        switch (index) {
          case 0:
            // Friends page
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.pushNamed(context, "/friendspage");
            break;
          case 1:
            // Slambook page(current page)
            Navigator.popUntil(context, ModalRoute.withName("/"));
            break;
          case 2:
            // Profile page
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.pushNamed(context, "/profilepage");

            break;
        }
        setState(() {
          _currentIndex = index;
        });
      },
      // Icons
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Slambook',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
