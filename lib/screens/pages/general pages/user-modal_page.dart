import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/models/user_model.dart';
import 'package:tolentino_mini_project/provider/user-slambook_provider.dart';

// Page for editing and deleting a friend
class UserModalPage extends StatefulWidget {
  // Variables
  final User? user;
  final String? type;
  final String name;
  const UserModalPage(
      {super.key, this.user, required this.type, required this.name});

  @override
  State<UserModalPage> createState() => _UserModalPageState();
}

class _UserModalPageState extends State<UserModalPage> {
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

  // Initial values of the fields
  String dropdownValue = "Super Strength";
  int radioValue = 1;
  bool switchLight = false;
  double currentSliderValue = 0;
  bool showSummary = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    if (widget.type == "Edit") {
      // Initial values of the fields (current details of the user) when editing
      nicknameController.text = widget.user!.nickname;
      ageController.text = widget.user!.age;
      dropdownValue = widget.user!.superpower;
      radioValue = radioValueFromMotto(widget.user!.motto);
      switchLight = (widget.user!.relationshipStatus == "Single");
      currentSliderValue = double.parse(widget.user!.happinessLevel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      content: _buildContent(context),
      // Cancel and Save button
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
      case 'Add':
        return const Text("My Slambook Data");
      case 'Delete':
        return const Text("Delete friend?");
      default:
        return const Text("");
    }
  }

  // Method to build the content or body depending on the functionality
  Widget _buildContent(BuildContext context) {
    switch (widget.type) {
      // case 'Delete':
      //   {
      //     return Text(
      //       "Are you sure you want to remove '${widget.friend.name}' as a friend?",
      //     );
      //   }
      // Form field for editing
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

  // Saving button function
  Widget _dialogAction(BuildContext context) {
    switch (widget.type) {
      case "Add":
        return TextButton(
          onPressed: () {
            // If the form is validated, add user's slambook
            if (formKey.currentState!.validate()) {
              User temp = User(
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
