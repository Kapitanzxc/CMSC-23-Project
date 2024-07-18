import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:provider/provider.dart";
import "package:tolentino_mini_project/models/user_model.dart";
import "package:tolentino_mini_project/provider/auth_provider.dart";
import "package:tolentino_mini_project/provider/user-info_provider.dart";
import "package:tolentino_mini_project/provider/user-slambook_provider.dart";
import "package:tolentino_mini_project/screens/pages/general%20pages/user-modal_page.dart";

// Profile Page
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;
  // Get the screen height
  double get screenHeight => MediaQuery.of(context).size.height;
  // Current navigation index
  int currentIndex = 2;
  // Content to be showed (default:personal page)
  String currentContent = "slambook";
  // Storing user personal information
  Map<String, dynamic>? userInfo;
  // User's name
  late String name;
  // Checks if there is slambook data
  bool slambookDataChecker = false;

  // Function for changing content (Slambook/Personal Info)
  void _changeContent(String content) {
    if (mounted) {
      setState(() {
        context.read<UserInfoProvider>().getUserInfo();
        currentContent = content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 239, 230, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover photo and profile picture
          coverAndPfp,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Creation of name and user name
                  createStreamBuilder(context, 1),
                  const SizedBox(height: 80),
                  // Content UI (the container widget)
                  mainContentUI(),
                  // Logout button
                  logoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Navigation Bar
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  // Responsible for Content UI
  Widget mainContentUI() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // // Buttons
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: <Widget>[
            //     ElevatedButton(
            //       onPressed: () {
            //         _changeContent("slambook");
            //       },
            //       child: Text("Button 1"),
            //     ),
            //     ElevatedButton(
            //       onPressed: () => _changeContent("personal"),
            //       child: Text("Button 2"),
            //     ),
            //   ],
            // ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: currentContent == "personal"
                      ? createStreamBuilder(context, 2)
                      // Shows the slambook content
                      : slambookContent(),
                ),
              ),
            ),
            // Buttons
            currentContent == "slambook" && slambookDataChecker
                ? editSlambookButton()
                : addSlambookButton(),
          ],
        ),
      ),
    );
  }

  // Displays the name and username
  Widget createStreamBuilder(BuildContext context, int type) {
    // Streambuilder to access the data
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: context.watch<UserInfoProvider>().userInfoStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Text("No user data available.");
        } else {
          // Process and display user data
          userInfo = snapshot.data!.data()!;
          if (type == 1) {
            // Displays the name and username
            name = userInfo!["name"] ?? "none";
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userInfo!["name"] ?? "none"),
                  Text(userInfo!["username"] ?? "none")
                ]);
          } else {
            // Shows personal information content
            return profileInformationContent(userInfo!);
          }
        }
      },
    );
  }

  // Function for showing the slambook content
  Widget slambookContent() {
    // Storing friend lists from the provider
    Stream<QuerySnapshot> userSlambookData =
        context.watch<UserSlambookProvider>().slambookData;
    return StreamBuilder(
      stream: userSlambookData,
      builder: (context, snapshot) {
        // Catching errors
        if (snapshot.hasError) {
          return Center(
            child: Text("Error encountered! ${snapshot.error}"),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group,
                  color: Color.fromRGBO(79, 111, 82, 1),
                  size: 50,
                ),
                Text("No slambook data yet"),
                SizedBox(height: 15),
              ],
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            slambookDataChecker = true;
          });
        });

        // Extract user data
        user = User.fromJson(
            snapshot.data!.docs.first.data() as Map<String, dynamic>);
        user.id = snapshot.data!.docs.first.id;

        // Display user's slambook data
        return Column(
          children: [
            displaySlambookData(user.toJson(user).values.toList()),
          ],
        );
      },
    );
  }

  // User's Slambook data
  Padding displaySlambookData(List<dynamic> userValues) {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Text(
                  "My Slambook Data",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(79, 111, 82, 1),
                  ),
                )),
            Column(
              children: [
                // Creates row of summary from the list
                buildSummaryRow("Nickname", userValues[1]),
                buildSummaryRow("Age", userValues[2]),
                buildSummaryRow("Relationship Status", userValues[3]),
                buildSummaryRow("Happiness Level", userValues[4]),
                buildSummaryRow("Superpower", userValues[5]),
                buildSummaryRow("Favorite Motto", userValues[6])
              ],
            ),
          ],
        ));
  }

  // Text creator for name and username
  Widget textCreator(String name, String username) {
    return Column(children: [Text(name), Text(username)]);
  }

  // Widget for the cover photo and pfp
  Widget get coverAndPfp => Stack(
        // Profile picture overflow
        clipBehavior: Clip.none,
        children: [
          // Calls stream builder to access the profile picture
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: context.watch<UserInfoProvider>().userInfoStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Center(child: Text("No user data available."));
              } else {
                // Storing image url
                Map<String, dynamic> userInfo = snapshot.data!.data()!;
                String imageURL = userInfo["profile-picture"] ?? "";
                return Stack(
                  // Profile picture overflow
                  clipBehavior: Clip.none,
                  children: [
                    // Cover photo
                    Container(
                      height: screenHeight * 0.3,
                      width: double.infinity,
                      color: Colors.green,
                    ),
                    // Profile picture
                    Positioned(
                      top: 210,
                      right: 20,
                      child: ClipOval(
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: imageURL.isNotEmpty
                              ? Image.network(
                                  imageURL,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/placeholder.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      );

// Displaying profile information
  Widget profileInformationContent(Map<String, dynamic> userInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSummaryRow("Email:", userInfo["email"] ?? "None"),
        buildSummaryRow(
            "Primary Contact Number:", userInfo["contact"] ?? "None"),
        buildAdditionalContacts(userInfo["additional_contacts"]),
      ],
    );
  }

// Function for displaying secondary contacts
  Widget buildAdditionalContacts(List<dynamic> additionalContacts) {
    if (additionalContacts.isEmpty) {
      return buildSummaryRow("Secondary Contact Number:", "None");
    } else {
      // Create a list of additional contacts
      List<Widget> contactRows = [];

      // Print the first contact number with a label
      contactRows.add(
          buildSummaryRow("Secondary Contact Number:", additionalContacts[0]));

      // Print other contact numbers without a label
      for (var i = 1; i < additionalContacts.length; i++) {
        contactRows.add(buildSummaryRow("", additionalContacts[i]));
      }
      // Return a column containing all contact
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contactRows,
      );
    }
  }

  // Function for building Label: Input formatting
  Widget buildSummaryRow(String label, String input) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Color.fromRGBO(79, 111, 82, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            input,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Add slambook button
  Widget addSlambookButton() {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  UserModalPage(type: "Add", name: name),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 97, 194, 7),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Add Slambook Data',
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  // Edit slambook button
  Widget editSlambookButton() {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  UserModalPage(type: "Edit", name: name, user: user),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 19, 97, 255),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Edit Slambook Data',
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  // Logout button
  Widget logoutButton() {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<UserAuthProvider>().signOut();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 4,
          ),
          child: Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  // Bottom navigation bar
  Widget bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });

        switch (index) {
          case 0:
            // Navigate to Friends page
            Navigator.pushNamed(context, "/friendspage");
            break;
          case 1:
            // Navigate to Slambook page
            Navigator.pushNamed(context, "/slambook");
            break;
          case 2:
            // Profile page
            _changeContent("personal"); // Set default content
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: "Friends",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: "Slambook",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: "Logout",
        ),
      ],
    );
  }
}
