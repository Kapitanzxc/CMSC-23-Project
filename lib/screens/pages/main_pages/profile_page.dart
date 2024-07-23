import "dart:io";
import "dart:typed_data";
import "dart:ui";

import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/rendering.dart";
import "package:provider/provider.dart";
import "package:qr_flutter/qr_flutter.dart";
import "package:tolentino_mini_project/formatting/formatting.dart";
import "package:tolentino_mini_project/models/user-slambook_model.dart";
import "package:tolentino_mini_project/models/users-info_model.dart";
import "package:tolentino_mini_project/provider/auth_provider.dart";
import "package:tolentino_mini_project/provider/user-info_provider.dart";
import "package:tolentino_mini_project/provider/user-slambook_provider.dart";
import "package:tolentino_mini_project/screens/pages/general%20pages/user_modal.dart";

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
  // Saving qr code variables
  final GlobalKey _qrkey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/storage/emulated/0/Download/Qr_code';

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
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          coverAndPfp,
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Creation of name and user name
                  createStreamBuilder(context),
                  // const SizedBox(height: 12),
                  // Content UI (slambook widget)
                  mainContentUI(),
                  // Logout button
                  logoutButton(),
                ],
              ),
            ),
          ),
        ],
      )),

      // Navigation Bar
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  // Responsible for Content UI
  Widget mainContentUI() {
    return SizedBox(
      height: screenHeight * 0.44,
      // Container formatting
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(65, 97, 97, 97)),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 6.0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                // Show the slambook content
                child: slambookContent(),
              ),
            ),
            // Buttons
            if (slambookDataChecker)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  editSlambookButton(),
                  const SizedBox(width: 10), // Space between buttons
                  generateQrButton(context, name)
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
          return noSlambookData;
        }

        // Slambook data is fetched
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            context.read<UserSlambookProvider>().setUser(user);
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
    return LayoutBuilder(builder: (context, constraints) {
      double imageSize = constraints.maxWidth * 0.15;
      double fontSizeLarge = constraints.maxWidth * 0.07;
      double fontSizeSmall = constraints.maxWidth * 0.035;
      return Stack(
        // Stack overflow
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 12, right: 12),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nickname
                heading(fontSizeLarge),
                nickname(userValues[1], fontSizeSmall),
                // Motto
                motto(userValues[6], fontSizeSmall),
                Column(
                  children: [
                    SizedBox(height: imageSize / 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Age and happiness Level
                        age(userValues[2], fontSizeSmall, imageSize),
                        happinessLevel(userValues[4], fontSizeSmall, imageSize),
                      ],
                    ),
                    SizedBox(height: imageSize / 5),
                    // Superpower
                    superPower(userValues[5], fontSizeSmall, imageSize),
                    SizedBox(height: imageSize / 5),
                    // Relationship status
                    relationshipStatus(userValues[3], fontSizeSmall, imageSize),
                  ],
                )
              ],
            ),
          ),
          // Happiness level emoji
          displayHappinessEmoji(userValues[4], imageSize),
          // Verified sticker
          verified(imageSize),
        ],
      );
    });
  }

// Add slambook button
  Widget addSlambookButton() {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => UserModalPage(
                  type: "Add", name: name, currentUser: currentUser),
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
        width: screenWidth * 0.30,
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
            const Icon(Icons.qr_code,
                color: const Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(
              width: 7,
            ),
            Text(
              'Qr Code',
              style: Formatting.mediumStyle
                  .copyWith(fontSize: 10, color: Formatting.black),
            )
          ]),
        ));
  }

  // Edit slambook button
  Widget editSlambookButton() {
    return SizedBox(
        width: screenWidth * 0.30,
        child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                // Navigate to the edit modal page
                builder: (BuildContext context) =>
                    UserModalPage(type: "Edit", name: name, user: user),
              );
              context.read<UserSlambookProvider>().setUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Formatting.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 4,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.edit, color: Color.fromARGB(255, 255, 255, 255)),
              const SizedBox(
                width: 7,
              ),
              Text(
                'Edit',
                style: Formatting.mediumStyle.copyWith(
                  fontSize: 10,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                ),
              )
            ])));
  }

  // Logout button
  Widget logoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: TextButton(
        onPressed: () {
          // Reseting variables
          setState(() {
            slambookDataChecker = false;
            userInfo = null;
          });
          // Sign out and exit
          context.read<UserAuthProvider>().signOut();
          Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          foregroundColor: Colors.red, // Text color
          textStyle: Formatting.mediumStyle.copyWith(
            fontSize: 14,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text('Logout'),
          ],
        ),
      ),
    );
  }

  // Shows an alert dialog of qr mimage
  Widget get slambookQrImage => AlertDialog(
        content: SizedBox(
            width: 320,
            height: 350,
            child: Column(
              children: [
                // Qr code
                RepaintBoundary(
                    key: _qrkey,
                    child: QrImageView(
                      data: user.toJsonString(user),
                      version: QrVersions.auto,
                      size: 250,
                      gapless: false,
                    )),
                const SizedBox(
                  height: 12,
                ),
                // Text
                Text(
                  "$name's slambook",
                  style: Formatting.boldStyle
                      .copyWith(fontSize: 24, color: Formatting.primary),
                  textAlign: TextAlign.center,
                ),
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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              saveToGalleryButton()
            ],
          ),
        ],
      );

// Save to gallery button
  Widget saveToGalleryButton() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton(
        onPressed: () {
          _captureAndSavePng();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          foregroundColor: Formatting.black, // Text color
          textStyle: Formatting.mediumStyle.copyWith(
            fontSize: 14,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Formatting.black),
            SizedBox(width: 10),
            Text('Save to gallery'),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndSavePng() async {
    try {
      // Translate the QR image widget to an image
      RenderRepaintBoundary boundary =
          _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);

      //Drawing white background because QR code is black
      final whitePaint = Paint()..color = Colors.white;
      // Starts the picture recorder
      final recorder = PictureRecorder();
      // Creates Canvas
      final canvas = Canvas(recorder,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
      // Draw a whtie rectangle canvas
      canvas.drawRect(
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          whitePaint);
      // Draws the image (qr code) to the canvas
      canvas.drawImage(image, Offset.zero, Paint());
      // End recording
      final picture = recorder.endRecording();
      // Translate the drawing to an image
      final img = await picture.toImage(image.width, image.height);
      // Saving the image to png format
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      //Check for duplicate file name to avoid overwriting
      String fileName = currentUser.name;
      int i = 1;
      while (await File('$externalDir/$fileName.png').exists()) {
        fileName = '${currentUser.name}_$i';
        i++;
      }

      // Check if Directory Path exists or not
      dirExists = await File(externalDir).exists();
      //if not then create the path
      if (!dirExists) {
        await Directory(externalDir).create(recursive: true);
        dirExists = true;
      }

      // Creates a file
      final file = await File('$externalDir/$fileName.png').create();
      // Write the byte data format of the qr image
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      const snackBar =
          SnackBar(content: Text('QR code safely hopped to the gallery!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print(e);
    }
  }

// Heading
  Widget heading(double fontSized) {
    return Text(
      "My Slambook",
      style: Formatting.semiBoldStyle.copyWith(
        fontSize: fontSized,
        color: Formatting.black,
      ),
    );
  }

  // Nickname
  Widget nickname(String nickname, double fontSized) {
    return Text(
      "Frog name: ${nickname.length > 18 ? "${nickname.substring(0, 18)}..." : nickname}",
      style: Formatting.mediumStyle.copyWith(
        fontSize: fontSized,
        color: Formatting.black,
      ),
    );
  }

  // Motto
  Widget motto(String motto, double fontSized) {
    return SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If text overflows, create another line
            Text(
              motto,
              style: Formatting.italicStyle
                  .copyWith(fontSize: fontSized, color: Formatting.black),
              softWrap: true,
            )
          ],
        ));
  }

  // Frog image with age
  Widget age(String age, double fontSized, double imageSize) {
    return Row(
      children: [
        SizedBox(
          height: imageSize,
          width: imageSize,
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
                  fontSize: fontSized * 1.5,
                  color: Formatting.black,
                )),
            Text("Age",
                style: Formatting.mediumStyle.copyWith(
                  fontSize: fontSized,
                  color: const Color.fromARGB(255, 90, 90, 90),
                ))
          ],
        ),
      ],
    );
  }

  // Happiness Level
  Widget happinessLevel(
      String happinessLevel, double fontSized, double imageSize) {
    List happinessLevelList = happinessLevel.split(".");
    return Row(
      children: [
        SizedBox(
          height: imageSize,
          width: imageSize,
          child: Image.asset("assets/frog_happiness.png"),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(happinessLevelList[0],
                style: Formatting.semiBoldStyle.copyWith(
                  fontSize: fontSized * 1.5,
                  color: Formatting.black,
                )),
            Text("Happiness Level",
                style: Formatting.mediumStyle.copyWith(
                  fontSize: fontSized,
                  color: const Color.fromARGB(255, 90, 90, 90),
                ))
          ],
        ),
      ],
    );
  }

  // Superpower
  Widget superPower(String superpower, double fontSized, double imageSize) {
    return Row(
      children: [
        SizedBox(
          height: imageSize,
          width: imageSize,
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
                  fontSize: fontSized * 1.5,
                  color: Formatting.black,
                )),
            Text("Super Power",
                style: Formatting.mediumStyle.copyWith(
                  fontSize: fontSized,
                  color: const Color.fromARGB(255, 90, 90, 90),
                ))
          ],
        ),
      ],
    );
  }

  // Relationship status
  Widget relationshipStatus(
      String relationshipStatus, double fontSized, double imageSize) {
    return Row(
      children: [
        SizedBox(
          height: imageSize,
          width: imageSize,
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
                  fontSize: fontSized * 1.5,
                  color: Formatting.black,
                )),
            Text("Relationship Status",
                style: Formatting.mediumStyle.copyWith(
                  fontSize: fontSized,
                  color: const Color.fromARGB(255, 90, 90, 90),
                ))
          ],
        ),
      ],
    );
  }

  // Emoji depending on the happiness level
  Widget displayHappinessEmoji(String happinessLevel, double imageSize) {
    return Positioned(
      top: -40,
      right: 0,
      child: ClipOval(
        child: Container(
            height: imageSize * 2.3,
            width: imageSize * 2.3,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: happinessLevelEmoji(double.parse(happinessLevel))),
      ),
    );
  }

  // Verified sticker
  Widget verified(double imageSize) {
    return Positioned(
      bottom: 18,
      right: 15,
      child: Container(
          height: imageSize * 1.5,
          width: imageSize * 1.5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Image.asset("assets/verified.png")),
    );
  }

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
  Widget get noSlambookData => LayoutBuilder(
        builder: (context, constraints) {
          double imageSize = constraints.maxWidth * 0.3;
          double fontSizeLarge = constraints.maxWidth * 0.07;
          double fontSizeSmall = constraints.maxWidth * 0.035;
          double spacing = constraints.maxHeight * 0.06;

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: spacing),
              // Image
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: Image.asset("assets/frog_angry.png"),
              ),
              // Text
              Text(
                "No slambook yet   (¬､¬)",
                style: Formatting.boldStyle.copyWith(
                  fontSize: fontSizeLarge,
                  color: Formatting.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing),
              // Text
              Text(
                "Your slambook is currently empty. Click the ‘Add’ button to start creating your own slambook",
                style: Formatting.mediumStyle.copyWith(
                  fontSize: fontSizeSmall,
                  color: Formatting.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing),
            ],
          );
        },
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
                String? imageURL = userInfo["profilePicURL"];
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
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Profile Page",
                          style: Formatting.semiBoldStyle.copyWith(
                            fontSize: 24,
                            color: const Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        top: 65,
                        left: 20,
                        child: SizedBox(
                            width: 50,
                            child: Image.asset("assets/ribbit_logo3.png"))),
                    Positioned(top: 55, right: 16, child: editInfoButton),
                    // Profile picture
                    Positioned(
                      top: screenHeight * 0.2,
                      right: 0,
                      left: 0,
                      child: Align(
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: imageURL != null
                                ? Image.network(
                                    imageURL,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/default_pfp.jpg',
                                    fit: BoxFit.cover,
                                  ),
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

// Displaying name and username
  Widget displayNameUsername(Map<String, dynamic>? userInfo) {
    // Displays the name and username
    name = userInfo!["name"] ?? "none";
    return Container(
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

  // Edit info button
  Widget get editInfoButton => IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => UserModalPage(
                type: "Edit2",
                name: name,
                currentUser: currentUser,
                user: user),
          );
        },
        color: const Color.fromARGB(255, 255, 255, 255),
      );

  // Bottom navigation bar
  Widget bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Formatting.primary,
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
