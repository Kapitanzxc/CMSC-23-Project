import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';
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

  late String dropdownValue;
  late int radioValue;
  late bool switchLight;
  late double currentSliderValue;
  late bool showSummary;
  late String friendId;

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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      content: _buildContent(context),

      // Contains two buttons - edit/delete, and cancel
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Color.fromARGB(255, 6, 51, 4)),
          ),
        ),
        _dialogAction(context),
      ],
    );
  }

  // Method to show the title of the modal depending on the functionality
  Text _buildTitle() {
    switch (widget.type) {
      case 'Edit':
        return const Text("Edit friend");
      case 'Delete':
        return const Text("Delete friend?");
      default:
        return const Text("");
    }
  }

  // Method to build the content or body depending on the functionality
  Widget _buildContent(BuildContext context) {
    switch (widget.type) {
      case 'Delete':
        {
          return Text(
            "Are you sure you want to remove '${widget.friend.name}' as a friend?",
          );
        }
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
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Age"),
                    )),
                    // Relationship status
                    const Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Text("Are you single?")),
                    // Switch
                    Switch(
                      // Bool value that toggles the switch
                      value: switchLight,
                      activeColor: const Color.fromRGBO(79, 111, 82, 1),
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
              const Text(
                  "On a scale of 0 (Hopeless) to 10 (Very Happy), how would you rate your current lifestyle?",
                  textAlign: TextAlign.center),
              // Slider
              Slider(
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
              ),
              // Superpower and its dropdown
              headerText("Superpower"),
              const Text("If you were to have a superpower, what would it be?",
                  textAlign: TextAlign.center),
              // Dropdown
              Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 40, right: 40, bottom: 20),
                  // Creation of drowdownbutton
                  child: DropdownButtonFormField(
                    value: dropdownValue,
                    items: superpowers.map((item) {
                      return DropdownMenuItem(child: Text(item), value: item);
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
                      const Text("When life gives you lemons, make lemonade"),
                      1),
                  radioCreators(
                      const Text("Life every day like it's your last"), 2),
                  radioCreators(
                      const Text("Be yourself. Everyone else is already taken"),
                      3),
                  radioCreators(
                      const Text("Be the change you wish to see in the world"),
                      4),
                  radioCreators(
                      const Text(
                          "If you are not obsessed with your life, change it"),
                      5),
                  radioCreators(const Text("Take small steps every day"), 6),
                  radioCreators(
                      const Text("Be a rainbow in someone else's cloud"), 7),
                ],
              ),
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
                  content: Text('Succesfully edited ${widget.friend.name}')));
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
      case "Delete":
        return TextButton(
          // Delete friend through the provider
          onPressed: () {
            context.read<FriendListProvider>().deleteFriend(widget.friend);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Succesfully deleted')));
            // Remove dialog after editing
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.labelLarge,
            backgroundColor:
                const Color.fromRGBO(255, 0, 0, 1), // Adjust text color here
          ),
          child: const Text("Delete"),
        );
      default:
        return const Text("");
    }
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
            if (val == null || val.isEmpty || val.trim().isEmpty)
              return "This is a required field";
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
