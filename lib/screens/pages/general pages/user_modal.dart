import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/android_features/camera_feat.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/models/user-slambook_model.dart';
import 'package:tolentino_mini_project/models/users-info_model.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/image-storage_provider.dart';
import 'package:tolentino_mini_project/provider/user-info_provider.dart';
import 'package:tolentino_mini_project/provider/user-slambook_provider.dart';

// Page for editing and deleting a friend
class UserModalPage extends StatefulWidget {
  // Variables
  final UsersInfo? currentUser;
  final Users? user;
  final String? type;
  final String name;

  const UserModalPage(
      {super.key,
      this.user,
      required this.type,
      required this.name,
      this.currentUser});

  @override
  State<UserModalPage> createState() => _UserModalPageState();
}

class _UserModalPageState extends State<UserModalPage> {
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
  TextEditingController usernameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  List<TextEditingController> contactNumberControllers = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Initial values of the fields
  String dropdownValue = "Super Strength";
  int radioValue = 1;
  bool switchLight = false;
  double currentSliderValue = 0;
  bool showSummary = false;
  File? _imagePath;
  String? profilePictureURL;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    if (widget.type == "Edit") {
      // Initial values of the fields (current slambook data of the user) when editing
      initializeSlambookData();
    }
    if (widget.type == "Edit2") {
      // Initial values of the fields (current personal details of the user) when editing
      initializePersonalInformation();
    }
  }

  // Disposing controllers
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    nicknameController.dispose();
    ageController.dispose();
    usernameController.dispose();
    contactController.dispose();
    for (var controller in contactNumberControllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: theme(),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            // Title
            title: _buildTitle(),
            // Save/Add button
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: _dialogAction(context)),
            ],
          ),
          // Content
          body: _buildContent(context),
        ));
  }

  // Method to build the content or body depending on the functionality
  Widget _buildContent(BuildContext context) {
    // Edit2 = Personal Information
    // Edit = Slambook Data
    // Add = Add Slambook Data
    switch (widget.type) {
      case "Edit2":
        // List of textField
        List<Widget> textFields = [
          textFieldCreator(usernameController, "Username"),
          textFieldCreator(nameController, "Name"),
          textFieldCreator(contactController, "Contact Number")
        ];

        // Add additional contact number text fields
        for (var i = 0; i < contactNumberControllers.length; i++) {
          textFields.add(displayAdditionalContact(i));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Display users profile picture if imagePath is not set
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
                                    child: Image.file(_imagePath!,
                                        fit: BoxFit.cover),
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
                    ),
                    // Display text fields
                    ...textFields,
                    // Button for adding additional contact numbers
                    Row(children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 237, 237, 237),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(1),
                          elevation: 1,
                        ),
                        // Adds contact controller
                        onPressed: () {
                          setState(() {
                            contactNumberControllers
                                .add(TextEditingController());
                          });
                        },
                        child: const Icon(
                          Icons.add,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(width: 1),
                      const Text(
                        'Contact Number',
                        style: TextStyle(fontSize: 16, color: Formatting.black),
                      ),
                    ]),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );

      // When adding/editing a slambook data
      default:
        return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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

  // Saving button function
  Widget _dialogAction(BuildContext context) {
    // When adding a new slambook data
    switch (widget.type) {
      case "Add":
        return TextButton(
          onPressed: () {
            // If the form is validated, add user's slambook
            if (formKey.currentState!.validate()) {
              Users temp = Users(
                  name: widget.name,
                  nickname: nicknameController.text,
                  age: ageController.text,
                  relationshipStatus: switchLight ? "Single" : "Not Single",
                  happinessLevel: currentSliderValue.toString(),
                  superpower: dropdownValue,
                  motto: motto(radioValue),
                  profilePictureURL: widget.currentUser!.profilePicURL);
              context.read<UserSlambookProvider>().addSlambookData(temp);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Successfully added slambook data to the froggy file!')));
              // Remove dialog after editing
              Navigator.of(context).pop();
            }
          },
          style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: Theme.of(context).textTheme.labelLarge,
              backgroundColor: Formatting.primary),
          child: const Text("Save"),
        );
      // Edit Slambook data function
      case "Edit":
        return TextButton(
          onPressed: () {
            // If the form is validated, edit the user's slambook data
            if (formKey.currentState!.validate()) {
              context.read<UserSlambookProvider>().editUserSlambook(
                  widget.user!,
                  nicknameController.text,
                  ageController.text,
                  switchLight ? "Single" : "Not Single",
                  currentSliderValue.toString(),
                  dropdownValue,
                  motto(radioValue));

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Your slambook data has been splashed with updates!')));
              // Remove dialog after editing
              Navigator.of(context).pop();
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
      // Editing Personal Information data
      case "Edit2":
        return TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              String? userId =
                  context.read<UserAuthProvider>().getCurrentUserId();
              String? profilePicURL = widget.currentUser!.profilePicURL;

              // If user added a new picture, upload it to the cloud
              if (_imagePath != null && userId != null) {
                profilePicURL = await context
                    .read<StorageProvider>()
                    .uploadProfilePicture(userId, _imagePath!);
              } else {
                profilePicURL = null;
              }

              // Edit user's information
              context.read<UserInfoProvider>().editUserInfo(
                    usernameController.text,
                    contactController.text,
                    contactNumberControllers
                        .map((controller) => controller.text)
                        .toList(),
                    profilePicURL,
                  );

              // Edit slambook profile picture
              context
                  .read<UserSlambookProvider>()
                  .editUserPicture(profilePicURL, widget.user!);

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Successfully splashed your personal info into place!')));
              Navigator.of(context).pop();
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.labelLarge,
            backgroundColor: Formatting.primary,
          ),
          child: Text("Save",
              style: Formatting.regularStyle
                  .copyWith(fontSize: 12, color: Colors.white)),
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

  // Initial values of the fields (current slambook data of the user) when editing
  void initializeSlambookData() {
    nicknameController.text = widget.user!.nickname;
    ageController.text = widget.user!.age;
    dropdownValue = widget.user!.superpower;
    radioValue = radioValueFromMotto(widget.user!.motto);
    switchLight = (widget.user!.relationshipStatus == "Single");
    currentSliderValue = double.parse(widget.user!.happinessLevel);
  }

  // Initial values of the fields (current personal details of the user) when editing
  void initializePersonalInformation() {
    usernameController.text = widget.currentUser!.username;
    contactController.text = widget.currentUser!.contact;
    for (var contact in widget.currentUser!.additionalContacts) {
      TextEditingController controller = TextEditingController(text: contact);
      contactNumberControllers.add(controller);
    }
    profilePictureURL = widget.currentUser!.profilePicURL;
  }

  // Displaying additional contacts
  Widget displayAdditionalContact(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            // Creating text form field
            child: TextFormField(
              controller: contactNumberControllers[index],
              validator: (val) {
                if (val == null || val.isEmpty || val.trim().isEmpty) {
                  return "This is a required field";
                }
                return null;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Additional Contact Number ${index + 1}",
              ),
            ),
          ),
          // Delete button for additional contacts
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                contactNumberControllers.removeAt(index);
              });
            },
          ),
        ],
      ),
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

  // Method to show the title of the modal depending on the functionality
  Text _buildTitle() {
    switch (widget.type) {
      case 'Add':
        return Text("My Slambook",
            style: Formatting.boldStyle
                .copyWith(fontSize: 18, color: Formatting.black));
      case 'Edit':
        return Text("Edit Slambook",
            style: Formatting.boldStyle
                .copyWith(fontSize: 18, color: Formatting.black));
      case 'Edit2':
        return Text("Edit Personal Information",
            style: Formatting.boldStyle
                .copyWith(fontSize: 18, color: Formatting.black));
      default:
        return const Text("");
    }
  }
}
