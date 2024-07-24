import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/android_features/camera_feat.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/image-storage_provider.dart';
import 'package:tolentino_mini_project/provider/user-friend_provider.dart';

// Page for editing and deleting a friend
class ModalPage extends StatefulWidget {
  final Friend friend;
  final String? type;
  const ModalPage({super.key, required this.friend, required this.type});

  @override
  State<ModalPage> createState() => _ModalPageState();
}

class _ModalPageState extends State<ModalPage> {
  // Iniitializing camera feature
  final CameraFeature _cameraFeature = CameraFeature();

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
  TextEditingController nameController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

// Variables
  late String dropdownValue;
  late int radioValue;
  late bool switchLight;
  late double currentSliderValue;
  late bool showSummary;
  late String friendId;
  Color selectedTileColor = Formatting.primary;
  File? _imagePath;
  String? profilePictureURL;

  @override
  void initState() {
    super.initState();
    // Initial values of the fields (current details of a friend)
    friendId = widget.friend.id!;
    nameController.text = widget.friend.name;
    nicknameController.text = widget.friend.nickname;
    ageController.text = widget.friend.age;
    dropdownValue = widget.friend.superpower;
    radioValue = radioValueFromMotto(widget.friend.motto);
    switchLight = (widget.friend.relationshipStatus == "Single");
    currentSliderValue = double.parse(widget.friend.happinessLevel);
    profilePictureURL = widget.friend.profilePictureURL;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        // themes
        data: theme(),
        child: widget.type == "Delete" || widget.type == "Change"
            ? buildDialog()
            : buildScaffold());
  }

  // Content for delete and change type
  Widget buildDialog() {
    return AlertDialog(
      title: _buildTitle(),
      content: _buildContent(context),
      // Contains two buttons - save/delete, and cancel
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: Text(
            "Cancel",
            style: Formatting.regularStyle.copyWith(
              fontSize: 12,
              color: Formatting.black,
            ),
          ),
        ),
        _dialogAction(context),
      ],
    );
  }

  // Content for editing type
  Widget buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // Title
        title: _buildTitle(),
        // Save button
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 24),
              child: _dialogAction(context)),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: _buildContent(context)),
    );
  }

  // Method to show the title of the modal depending on the functionality
  Widget _buildTitle() {
    switch (widget.type) {
      case 'Edit':
        return Center(
            child: Text("Edit friend",
                style: Formatting.boldStyle
                    .copyWith(fontSize: 18, color: Formatting.black)));
      case 'Delete':
        return Center(
            child: Text("Froggy Farewell? ",
                style: Formatting.boldStyle
                    .copyWith(fontSize: 18, color: Formatting.black)));
      case 'Change':
        return Center(
            child: Text("Change Profile Picture ",
                style: Formatting.boldStyle
                    .copyWith(fontSize: 18, color: Formatting.black)));
      default:
        return const Text("");
    }
  }

  // Method to build the content or body depending on the functionality
  Widget _buildContent(BuildContext context) {
    switch (widget.type) {
      case 'Delete':
        {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Image
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset("assets/frog_cry.png"),
              ),
              const SizedBox(height: 10),

              // Text
              Text(
                "Are you sure you want to delete this friend from your slambook? Once removed, they’ll hop away for good. ૮(˶╥︿╥)ა",
                style: Formatting.mediumStyle
                    .copyWith(fontSize: 14, color: Formatting.black),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

      case 'Change':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Stack(
              // If no image file existing, show the default pfp
              children: [
                if (_imagePath != null)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                          width: 140,
                          height: 140,
                          child: ClipOval(
                            child: Image.file(_imagePath!, fit: BoxFit.cover),
                          )))
                else if (profilePictureURL != null &&
                    profilePictureURL!.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                          width: 140,
                          height: 140,
                          child: ClipOval(
                            child: Image.network(profilePictureURL!,
                                fit: BoxFit.cover),
                          )))
                else
                  Padding(
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
            )
          ],
        );

      // Edit have input field in them
      default:
        return SingleChildScrollView(
            child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
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
            ],
          ),
        ));
    }
  }

  // Saving/Deleting button function
  Widget _dialogAction(BuildContext context) {
    switch (widget.type) {
      case "Edit":
        return TextButton(
          onPressed: () {
            // If the form is validated, edit the friend's details
            if (formKey.currentState!.validate()) {
              context.read<FriendListProvider>().editFriend(
                  widget.friend,
                  nicknameController.text,
                  ageController.text,
                  switchLight ? "Single" : "Not Single",
                  currentSliderValue.toString(),
                  dropdownValue,
                  motto(radioValue));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '${widget.friend.name} has been adjusted in the pond!')));
              // Remove dialog after editing
              Navigator.pop(context, 'refresh');
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.labelLarge,
            backgroundColor: Formatting.primary, // Adjust text color here
          ),
          child: Text("Save",
              style: Formatting.regularStyle.copyWith(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 255, 255, 255))),
        );
      case "Delete":
        return TextButton(
          // Delete friend through the provider
          onPressed: () {
            context.read<FriendListProvider>().deleteFriend(widget.friend);
            ;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('A friend leapt out of the pond!')));
            // Remove dialog after editing
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.labelLarge,
            backgroundColor: const Color.fromARGB(
                255, 190, 41, 41), // Adjust text color here
          ),
          child: Text("Delete",
              style: Formatting.regularStyle.copyWith(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 255, 255, 255))),
        );

      case "Change":
        return TextButton(
          onPressed: () async {
            // Get current user's id
            String? userId =
                context.read<UserAuthProvider>().getCurrentUserId();
            String? profilePicURL = widget.friend.profilePictureURL;

            // If user added a new picture, upload it to the cloud
            if (_imagePath != null && userId != null) {
              profilePicURL = await context
                  .read<StorageProvider>()
                  .uploadFriendProfilePicture(
                      userId, widget.friend.name, _imagePath!);
            } else {
              profilePicURL = null;
            }

            // Edit friend profile picture
            await context
                .read<FriendListProvider>()
                .editFriendProfilePicture(
                  widget.friend,
                  profilePicURL,
                )
                .then((value) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Successfully splashed a new profile pic')));
              Navigator.pop(context, 'refresh');
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.labelLarge,
            backgroundColor: Formatting.primary, // Adjust text color here
          ),
          child: Text("Save",
              style: Formatting.regularStyle.copyWith(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 255, 255, 255))),
        );
      default:
        return const Text("");
    }
  }

  // Modal bottom sheet for photo options
  void _photoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Camera
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a picture'),
              onTap: () async {
                Navigator.of(context).pop();
                final imagePath = await _cameraFeature.takePicture();
                if (imagePath != null) {
                  setState(() {
                    _imagePath = imagePath;
                  });
                }
              },
            ),
            // Gallery
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final imagePath = await _cameraFeature.chooseFromGallery();
                if (imagePath != null) {
                  setState(() {
                    _imagePath = imagePath;
                  });
                }
              },
            ),
            // Delete option
            if (_imagePath != null ||
                (profilePictureURL != null && profilePictureURL!.isNotEmpty))
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    _imagePath = null;
                    profilePictureURL = null;
                  });
                },
              )
          ],
        );
      },
    );
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
          readOnly: labelText == "Name" ? true : false,
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

  // Returns the radio value given a motto string
  int radioValueFromMotto(String motto) {
    switch (motto) {
      case "When life gives you lemons, make lemonade":
        return 1;
      case "Live every day like it's your last":
        return 2;
      case "Be yourself. Everyone else is already taken":
        return 3;
      case "Be the change you wish to see in the world":
        return 4;
      case "If you are not obsessed with your life, change it":
        return 5;
      case "Take small steps every day":
        return 6;
      case "Be a rainbow in someone else's cloud":
        return 7;
      default:
        return 0;
    }
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
        labelStyle: const TextStyle(color: Formatting.black),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}
