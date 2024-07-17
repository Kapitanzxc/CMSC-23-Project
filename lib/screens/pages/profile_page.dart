import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:provider/provider.dart";
import "package:tolentino_mini_project/provider/auth_provider.dart";
import "package:tolentino_mini_project/provider/users_provider.dart";

// Profile Page
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Get the screen height
  double get screenHeight => MediaQuery.of(context).size.height;
  // Current navigation index
  int currentIndex = 2;
  // Content to be showed (default:personal page)
  String currentContent = "slambook";
  // Storing user personal information
  Map<String, dynamic>? userInfo;

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
                  createStreamBuilder(context),
                  const SizedBox(height: 80),
                  // Content UI (the container widget)
                  contentUI(),
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

  // Displays the name and username
  Widget createStreamBuilder(BuildContext context) {
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
          // Displays the name and username
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userInfo!["name"] ?? "none"),
                Text(userInfo!["username"] ?? "none")
              ]);
        }
      },
    );
  }

  // Function for changing content (Slambook/Personal Info)
  void _changeContent(String content) {
    if (mounted) {
      setState(() {
        context.read<UserInfoProvider>().getUserInfo();
        currentContent = content;
      });
    }
  }

  // Responsible for Content UI
  Widget contentUI() {
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
            Row(
              // The buttons that changes the content
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _changeContent("slambook");
                  },
                  child: Text("Button 1"),
                ),
                ElevatedButton(
                  onPressed: () => _changeContent("personal"),
                  child: Text("Button 2"),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Content
            Center(
              // Content for personal information
              child: currentContent == "personal"
                  ? StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: context.watch<UserInfoProvider>().userInfoStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (!snapshot.hasData ||
                            snapshot.data!.data() == null) {
                          return const Text("No user data available.");
                        } else {
                          // Process and display user data
                          Map<String, dynamic> userInfo =
                              snapshot.data!.data()!;
                          return profileInformationContent(userInfo);
                        }
                      },
                    )
                  // Content for slambook
                  : slambookContent(),
            ),
          ],
        ),
      ),
    );
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

  // Function for showing the slambook content
  Widget slambookContent() {
    return const Text("Slambook Content");
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
