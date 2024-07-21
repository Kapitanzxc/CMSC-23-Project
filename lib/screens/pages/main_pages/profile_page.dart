import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:provider/provider.dart";
import "package:qr_flutter/qr_flutter.dart";
import "package:tolentino_mini_project/formatting/formatting.dart";
import "package:tolentino_mini_project/models/user-slambook_model.dart";
import "package:tolentino_mini_project/models/users-info_model.dart";
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
  late Users user;
  // Get the screen dimensions
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;
  // Current navigation index
  int _currentIndex = 2;
  // Storing user personal information
  Map<String, dynamic>? userInfo;
  late UsersInfo currentUser;
  // User's name
  late String name;
  // Checks if there is slambook data
  bool slambookDataChecker = false;

  // Fetch user's slambook data everytime this page is initialize
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserSlambookProvider>().fetchSlambookData();
      context.read<UserInfoProvider>().getUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      extendBodyBehindAppBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover photo and profile picture
          coverAndPfp,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Creation of name and user name
                  createStreamBuilder(context),
                  const SizedBox(height: 12),
                  // Content UI (slambook widget)
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
      // Container formatting
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(65, 97, 97, 97)),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                // Show the slambook content
                child: Container(
                  child: slambookContent(),
                ),
              ),
            ),
            // Buttons
            if (slambookDataChecker)
              Row(
                children: [
                  Expanded(child: editSlambookButton()),
                  const SizedBox(width: 10), // Space between buttons
                  Expanded(child: generateQrButton(context, name)),
                ],
              )
            else
              addSlambookButton(),
          ],
        ),
      ),
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
          return Center(child: noSlambookData);
        }

        // Slambook data is fetched
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            slambookDataChecker = true;
          });
        });

        // Extract user data
        user = Users.fromJson(
            snapshot.data!.docs.first.data() as Map<String, dynamic>);
        user.id = snapshot.data!.docs.first.id;

        // Display user's slambook data
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            displaySlambookData(user.toJson(user).values.toList()),
          ],
        );
      },
    );
  }

  // User's Slambook data
  Widget displaySlambookData(List<dynamic> userValues) {
    return Stack(
      // Stack overflow
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nickname
              heading,
              nickname(userValues[1]),
              const SizedBox(height: 8),
              // Motto
              motto(userValues[6]),
              Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Age and happiness Level
                      age(userValues[2]),
                      happinessLevel(userValues[4]),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Superpower
                  superPower(userValues[5]),
                  const SizedBox(
                    height: 20,
                  ),
                  // Relationship status
                  relationshipStatus(userValues[3]),
                ],
              )
            ],
          ),
        ),
        // Happiness level emoji
        displayHappinessEmoji(userValues[4]),
        // Verified sticker
        verified,
      ],
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
            backgroundColor: Formatting.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 4,
          ),
          child: Text(
            'Add Slambook Data',
            style: Formatting.mediumStyle.copyWith(
                fontSize: 16, color: const Color.fromRGBO(255, 255, 255, 1)),
          ),
        ));
  }

  // Generate qr code button
  Widget generateQrButton(BuildContext context, String name) {
    return SizedBox(
        child: ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // Shows an alert dialog showing an qr image of user's slambook data
            return slambookQrImage;
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 4,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.qr_code, color: const Color.fromARGB(255, 0, 0, 0)),
        const SizedBox(
          width: 10,
        ),
        Text(
          'Qr Code',
          style: Formatting.mediumStyle
              .copyWith(fontSize: 14, color: Formatting.black),
        )
      ]),
    ));
  }

  // Edit slambook button
  Widget editSlambookButton() {
    return SizedBox(
        child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                // Navigate to the edit modal page
                builder: (BuildContext context) =>
                    UserModalPage(type: "Edit", name: name, user: user),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 19, 97, 255),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 4,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.edit, color: Color.fromARGB(255, 255, 255, 255)),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Edit',
                style: Formatting.mediumStyle.copyWith(
                  fontSize: 14,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                ),
              )
            ])));
  }

  // Logout button
  Widget logoutButton() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              // Reseting variables
              slambookDataChecker = false;
              userInfo = null;
            });
            // Sign out and exit
            context.read<UserAuthProvider>().signOut();
            Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 4,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.logout, color: Color.fromARGB(255, 255, 255, 255)),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Logout',
              style: Formatting.mediumStyle.copyWith(
                fontSize: 14,
                color: const Color.fromRGBO(255, 255, 255, 1),
              ),
            )
          ]),
        ));
  }

  // Shows an alert dialog of qr mimage
  Widget get slambookQrImage => AlertDialog(
        content: SizedBox(
            width: 320,
            height: 300,
            child: Column(
              children: [
                // Qr code
                QrImageView(
                  data: user.toJsonString(user),
                  version: QrVersions.auto,
                  size: 200,
                  gapless: false,
                ),
                // Text
                Text(
                  "${name}'s slambook",
                  style: Formatting.boldStyle
                      .copyWith(fontSize: 24, color: Formatting.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Text
                Text(
                  "Show this QR code to your friends so they can easily add you to their slambook. Just let them scan it with their device!",
                  style: Formatting.mediumStyle
                      .copyWith(fontSize: 12, color: Formatting.black),
                  textAlign: TextAlign.center,
                ),
              ],
            )),
        actions: <Widget>[
          //  Exit button
          SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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
                  'Exit',
                  style: Formatting.mediumStyle.copyWith(
                      fontSize: 16,
                      color: const Color.fromRGBO(255, 255, 255, 1)),
                ),
              )),
        ],
      );

// Heading
  Widget get heading => Text(
        "My Slambook",
        style: Formatting.semiBoldStyle.copyWith(
          fontSize: 24,
          color: Formatting.black,
        ),
      );

  // Nickname
  Widget nickname(String nickname) {
    return Text(
      "Frog name: ${nickname.length > 18 ? "${nickname.substring(0, 18)}..." : nickname}",
      style: Formatting.mediumStyle.copyWith(
        fontSize: 10,
        color: Formatting.black,
      ),
    );
  }

  // Motto
  Widget motto(String motto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // If text overflows, create another line
        Text(
          '"${motto.length > 20 ? motto.substring(0, 20) : "$motto'"}',
          style: Formatting.italicStyle.copyWith(
            fontSize: 10,
            color: Formatting.black,
          ),
        ),
        if (motto.length > 20)
          Text(
            '${motto.substring(20)}"',
            style: Formatting.italicStyle.copyWith(
              fontSize: 10,
              color: Formatting.black,
            ),
          ),
      ],
    );
  }

  // Frog image with age
  Widget age(String age) {
    return Row(
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: Image.asset("assets/frog_age.png"),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(age,
                style: Formatting.semiBoldStyle.copyWith(
                  fontSize: 16,
                  color: Formatting.black,
                )),
            Text("Age",
                style: Formatting.mediumStyle.copyWith(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 90, 90, 90),
                ))
          ],
        ),
      ],
    );
  }

  // Happiness Level
  Widget happinessLevel(String happinessLevel) {
    return Row(
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: Image.asset("assets/frog_happiness.png"),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(happinessLevel,
                style: Formatting.semiBoldStyle.copyWith(
                  fontSize: 16,
                  color: Formatting.black,
                )),
            Text("Happiness Level",
                style: Formatting.mediumStyle.copyWith(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 90, 90, 90),
                ))
          ],
        ),
      ],
    );
  }

  // Superpower
  Widget superPower(String superpower) {
    return Row(
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: Image.asset("assets/frog_superpower.png"),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(superpower,
                style: Formatting.semiBoldStyle.copyWith(
                  fontSize: 16,
                  color: Formatting.black,
                )),
            Text("Super Power",
                style: Formatting.mediumStyle.copyWith(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 90, 90, 90),
                ))
          ],
        ),
      ],
    );
  }

  // Relationship status
  Widget relationshipStatus(String relationshipStatus) {
    return Row(
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: Image.asset("assets/frog_relationship.png"),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(relationshipStatus,
                style: Formatting.semiBoldStyle.copyWith(
                  fontSize: 16,
                  color: Formatting.black,
                )),
            Text("Relationship",
                style: Formatting.mediumStyle.copyWith(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 90, 90, 90),
                ))
          ],
        ),
      ],
    );
  }

  // Emoji depending on the happiness level
  Widget displayHappinessEmoji(String happinessLevel) {
    return Positioned(
      top: -40,
      right: 0,
      child: ClipOval(
        child: Container(
            height: 120,
            width: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: happinessLevelEmoji(double.parse(happinessLevel))),
      ),
    );
  }

  // Verified sticker
  Widget get verified => Positioned(
        bottom: 18,
        right: 15,
        child: Container(
            height: 90,
            width: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset("assets/verified.png")),
      );

// Return image depending on the happiness Level
  Widget happinessLevelEmoji(double happinessLevel) {
    switch (happinessLevel) {
      case 10 || 9:
        return Image.asset("assets/super_happy.png");
      case 8 || 7:
        return Image.asset("assets/happy.png");
      case 6 || 5:
        return Image.asset("assets/neutral.png");
      case 4 || 3:
        return Image.asset("assets/sad.png");
      case 2 || 1:
        return Image.asset("assets/super_sad.png");
      default:
        return Image.asset("assets/crying.png");
    }
  }

  // Display no slambook data
  Widget get noSlambookData => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          SizedBox(
            width: 150,
            height: 150,
            child: Image.asset("assets/frog_angry.png"),
          ),
          // Text
          Text(
            "No slambook yet   (¬､¬)",
            style: Formatting.boldStyle
                .copyWith(fontSize: 24, color: Formatting.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Text
          Text(
            "Your slambook is currently empty. Click the ‘Add’ button to start creating your own slambook",
            style: Formatting.mediumStyle
                .copyWith(fontSize: 12, color: Formatting.black),
            textAlign: TextAlign.center,
          ),
        ],
      );

  // Function for creating a stream builder
  Widget createStreamBuilder(BuildContext context) {
    // Streambuilder to access the data
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: context.watch<UserInfoProvider>().userInfoStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Text("No user data available.");
        } else {
          // Process and display user data
          userInfo = snapshot.data!.data()!;
          currentUser = UsersInfo.fromJson(userInfo!);

          return displayNameUsername(userInfo!);
        }
      },
    );
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
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.data() == null) {
                return const Center(child: Text("No user data available."));
              } else {
                // Storing image url
                Map<String, dynamic> userInfo = snapshot.data!.data()!;
                String imageURL = userInfo["profilePicURL"] ?? "";
                return Stack(
                  // Profile picture overflow
                  clipBehavior: Clip.none,
                  children: [
                    // Cover photo
                    Container(
                      height: screenHeight * 0.3,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/cover_photo.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // App bar
                    Positioned(
                      top: 60,
                      left: screenWidth / 2 - 60,
                      child: Text(
                        "Profile Page",
                        style: Formatting.semiBoldStyle.copyWith(
                          fontSize: 20,
                          color: const Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    ),
                    Positioned(top: 50, right: 16, child: editInfoButton),
                    // Profile picture
                    Positioned(
                      top: 210,
                      right: screenWidth / 2 - 75,
                      child: ClipOval(
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: imageURL.isNotEmpty
                              ? Image.network(
                                  imageURL,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/default_pfp.png',
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

  // Text creator for name and username
  Widget textCreator(String name, String username) {
    return Column(children: [Text(name), Text(username)]);
  }

// Displaying name and username
  Widget displayNameUsername(Map<String, dynamic>? userInfo) {
    // Displays the name and username
    name = userInfo!["name"] ?? "none";
    return Container(
        margin: const EdgeInsets.only(left: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(userInfo["name"] ?? "none",
              style: Formatting.boldStyle
                  .copyWith(fontSize: 24, color: Formatting.black)),
          Text(
            "@${userInfo["username"] ?? "none"}",
            style: Formatting.mediumStyle
                .copyWith(fontSize: 16, color: Formatting.black),
          )
        ]));
  }

// // Displaying profile information
//   Widget profileInformationContent(Map<String, dynamic> userInfo) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         buildSummaryRow("Email:", userInfo["email"] ?? "None"),
//         buildSummaryRow(
//             "Primary Contact Number:", userInfo["contact"] ?? "None"),
//         buildAdditionalContacts(userInfo["additional_contacts"]),
//       ],
//     );
//   }

// // Function for displaying secondary contacts
//   Widget buildAdditionalContacts(List<dynamic> additionalContacts) {
//     if (additionalContacts.isEmpty) {
//       return buildSummaryRow("Secondary Contact Number:", "None");
//     } else {
//       // Create a list of additional contacts
//       List<Widget> contactRows = [];

//       // Print the first contact number with a label
//       contactRows.add(
//           buildSummaryRow("Secondary Contact Number:", additionalContacts[0]));

//       // Print other contact numbers without a label
//       for (var i = 1; i < additionalContacts.length; i++) {
//         contactRows.add(buildSummaryRow("", additionalContacts[i]));
//       }
//       // Return a column containing all contact
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: contactRows,
//       );
//     }
//   }

//   // Function for building Label: Input formatting
//   Widget buildSummaryRow(String label, String input) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(
//                 color: Color.fromRGBO(79, 111, 82, 1),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Text(
//             input,
//             style: const TextStyle(
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

  // Edit info button
  Widget get editInfoButton => IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => UserModalPage(
                type: "Edit2", name: name, currentUser: currentUser),
          );
        },
        color: Color.fromARGB(255, 255, 255, 255),
      );

  // Bottom navigation bar
  Widget bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == _currentIndex) {
          return;
        }
        switch (index) {
          case 0:
            // Friends page
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.pushNamed(context, "/friendspage");
            break;
          case 1:
            // Slambook page
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.pushNamed(context, "/slambook");
            break;
          case 2:
            // Profile page (current page)
            Navigator.popUntil(context, ModalRoute.withName("/"));
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
          label: 'Logout',
        ),
      ],
    );
  }
}
