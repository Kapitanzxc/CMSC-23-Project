import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/android_features/camera_feat.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
        actions: <Widget>[
          _dialogAction(context),
        ],
      ),
      body: _buildContent(context),
    );
  }

  // Method to build the content or body depending on the functionality
  Widget _buildContent(BuildContext context) {
    switch (widget.type) {
      case "Edit2":
        // List of existing text fields
        List<Widget> textFields = [
          textFieldCreator(usernameController, "Username"),
          textFieldCreator(nameController, "Name"),
          textFieldCreator(contactController, "Contact Number")
        ];

        // Add additional contact number text fields
        for (var controller in contactNumberControllers) {
          textFields
              .add(textFieldCreator(controller, "Additional Contact Number"));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Form(
                key: formKey,
                child: Column(
                  // Text Fields
                  children: [
                    // Display users profile picture if imagePath is not set
                    if (_imagePath == null)
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: ClipOval(
                          child: SizedBox(
                              height: 40,
                              width: 40,
                              child: Image.network(
                                  widget.currentUser!.profilePicURL!,
                                  fit: BoxFit.cover)),
                        ),
                      )
                    else
                      // Display users new picture if imagePath is set
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: ClipOval(
                            child: SizedBox(
                          height: 40,
                          width: 40,
                          child: Image.file(_imagePath!, fit: BoxFit.cover),
                        )),
                      ),
                    // Shows a button of adding profile photo
                    Column(
                      children: [
                        ElevatedButton(
                          // Shows the photo options
                          onPressed: () => _photoOptions(context),
                          child: const Text('Edit Profile Photo'),
                        ),
                      ],
                    ),
                    // Display text fields
                    ...textFields,
                    const SizedBox(height: 10),
                    // Button for adding additional contact numbers
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          contactNumberControllers.add(TextEditingController());
                        });
                      },
                      child: const Text("Add Contact Number"),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );

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
                        const Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text("Are you single?")),
                        // Switch
                        relationshipFormField(),
                      ])),
                  // Happiness Level and its slider
                  headerText("Happiness Level"),
                  const Text(
                      "On a scale of 0 (Hopeless) to 10 (Very Happy), how would you rate your current lifestyle?",
                      textAlign: TextAlign.center),
                  // Slider
                  happinessFormField(),
                  // Superpower and its dropdown
                  headerText("Superpower"),
                  const Text(
                      "If you were to have a superpower, what would it be?",
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
                  motto: motto(radioValue));
              context.read<UserSlambookProvider>().addSlambookData(temp);

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Succesfully added slambook data')));
              // Remove dialog after editing
              Navigator.of(context).pop();
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.labelLarge,
            backgroundColor:
                const Color.fromRGBO(79, 111, 82, 1), // Adjust text color here
          ),
          child: const Text("Save"),
        );
      // Edit function
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
                  content: Text('Succesfully edited your slambook data')));
              // Remove dialog after editing
              Navigator.of(context).pop();
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.labelLarge,
            backgroundColor:
                const Color.fromRGBO(79, 111, 82, 1), // Adjust text color here
          ),
          child: const Text("Save"),
        );
      case "Edit2":
        return TextButton(
          onPressed: () async {
            // If the form is validated, edit the user's personal information
            if (formKey.currentState!.validate()) {
              // Accsesing userId
              String? userId =
                  context.read<UserAuthProvider>().getCurrentUserId();
              // Storing current profile picture URL
              String? profilePicURL = widget.currentUser!.profilePicURL;

              // If user added a new picture, upload it to the cloud
              if (_imagePath != null && userId != null) {
                profilePicURL = await context
                    .read<StorageProvider>()
                    .uploadProfilePicture(userId, _imagePath!);
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

              // Snackbar
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Succesfully edited your personal information')));
              // Remove dialog after editing
              Navigator.of(context).pop();
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.labelLarge,
            backgroundColor:
                const Color.fromRGBO(79, 111, 82, 1), // Adjust text color here
          ),
          child: const Text("Save"),
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
            ListTile(
                // Taking a picture from the camera
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final imagePath = await _cameraFeature.takePicture();
                  if (imagePath != null) {
                    // Setting new image path
                    setState(() {
                      _imagePath = imagePath;
                    });
                  }
                }),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                // Taking a picture from the gallery
                final imagePath = await _cameraFeature.chooseFromGallery();
                if (imagePath != null) {
                  // Setting new image path
                  setState(() {
                    _imagePath = imagePath;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Text field formatting function
  Padding textFieldCreator(TextEditingController controller, String labelText) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          readOnly: labelText == "Name" ? true : false,
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
    return Text(
      title,
      style: const TextStyle(
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
  }

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

  Widget relationshipFormField() {
    return Switch(
      // Bool value that toggles the switch
      value: switchLight,
      activeColor: const Color.fromRGBO(79, 111, 82, 1),
      onChanged: (bool value) {
        // Update bool value when changed
        setState(() {
          switchLight = value;
        });
      },
    );
  }

  Widget happinessFormField() {
    return Slider(
      value: currentSliderValue,
      // From 0: 10
      max: 10,
      divisions: 10,
      label: currentSliderValue.round().toString(),
      activeColor: const Color.fromRGBO(79, 111, 82, 1),
      onChanged: (double value) {
        setState(() {
          // Update slider value on change
          currentSliderValue = value;
        });
      },
    );
  }

  Widget superpowerFormField() {
    return Padding(
        padding:
            const EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 20),
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

  Widget radioFormFields() {
    return Column(
      children: <Widget>[
        // Radioboxes
        radioCreators(
            const Text("When life gives you lemons, make lemonade"), 1),
        radioCreators(const Text("Life every day like it's your last"), 2),
        radioCreators(
            const Text("Be yourself. Everyone else is already taken"), 3),
        radioCreators(
            const Text("Be the change you wish to see in the world"), 4),
        radioCreators(
            const Text("If you are not obsessed with your life, change it"), 5),
        radioCreators(const Text("Take small steps every day"), 6),
        radioCreators(const Text("Be a rainbow in someone else's cloud"), 7),
      ],
    );
  }

  // Method to show the title of the modal depending on the functionality
  Text _buildTitle() {
    switch (widget.type) {
      case 'Add':
        return const Text("My Slambook");
      case 'Edit':
        return const Text("Edit Slambook");
      case 'Edit2':
        return const Text("Edit Personal Information");
      case 'Delete':
        return const Text("Delete friend?");
      default:
        return const Text("");
    }
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
}
