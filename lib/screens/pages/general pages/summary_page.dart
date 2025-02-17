import 'package:flutter/material.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';
import 'package:tolentino_mini_project/screens/pages/general%20pages/friend_modal.dart';

// Page for showing the summary/details
class SummaryPage extends StatefulWidget {
  final Friend friend;
  const SummaryPage({super.key, required this.friend});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  // Get the screen dimensions
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;
  String? profilePictureURL;

  @override
  void initState() {
    super.initState();
    profilePictureURL = widget.friend.profilePictureURL;
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
          // Cover photo and profile picture
          coverAndPfp,
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Name
                  displayName(widget.friend),
                  const SizedBox(height: 12),
                  // Content UI (slambook widget)
                  mainContentUI(),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  // Responsible for Content UI
  Widget mainContentUI() {
    return SizedBox(
      height: screenHeight * 0.52,
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
            const SizedBox(height: 12),
            editSlambookButton(),
            const SizedBox(height: 4),
            deleteSlambookButton()
          ],
        ),
      ),
    );
  }

  // Function for showing the slambook content
  Widget slambookContent() {
    return LayoutBuilder(builder: (context, constraints) {
      double imageSize = constraints.maxWidth * 0.15;
      double fontSizeLarge = constraints.maxWidth * 0.07;
      double fontSizeSmall = constraints.maxWidth * 0.035;
      // Display friend's slambook data
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
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
                    nickname(widget.friend.nickname, fontSizeSmall),
                    // Motto
                    motto(widget.friend.motto, fontSizeSmall),
                    Column(
                      children: [
                        SizedBox(height: imageSize / 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Age and happiness Level
                            age(widget.friend.age, fontSizeSmall, imageSize),
                            happinessLevel(widget.friend.happinessLevel,
                                fontSizeSmall, imageSize),
                          ],
                        ),
                        SizedBox(height: imageSize / 5),
                        // Superpower
                        superPower(
                            widget.friend.superpower, fontSizeSmall, imageSize),
                        SizedBox(height: imageSize / 5),
                        // Relationship status
                        relationshipStatus(widget.friend.relationshipStatus,
                            fontSizeSmall, imageSize),
                      ],
                    )
                  ],
                ),
              ),
              // Happiness level emoji
              displayHappinessEmoji(widget.friend.happinessLevel, imageSize),
              // Verified sticker
              if (widget.friend.verified == "Yes") verified(imageSize),
            ],
          )
        ],
      );
    });
  }

  // Edit slambook button
  Widget editSlambookButton() {
    return SizedBox(
        child: ElevatedButton(
            onPressed: widget.friend.verified != "Yes"
                ? () async {
                    final result = await showDialog(
                      context: context,
                      // Navigate to edit modal page
                      builder: (BuildContext context) =>
                          ModalPage(friend: widget.friend, type: "Edit"),
                    );

                    if (result == 'refresh') {
                      setState(() {});
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('All set! Give it a splash to refresh!')));
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Formatting.primary,
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

  // Delete slambook button
  Widget deleteSlambookButton() {
    return SizedBox(
        child: ElevatedButton(
            onPressed: () async {
              await showDialog(
                context: context,
                // Navigate to delete modal page
                builder: (BuildContext context) =>
                    ModalPage(friend: widget.friend, type: "Delete"),
              );
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Successfully hopped out! Please refresh the pond!')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Formatting.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 4,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.delete,
                  color: Color.fromARGB(255, 255, 255, 255)),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Delete',
                style: Formatting.mediumStyle.copyWith(
                  fontSize: 14,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                ),
              )
            ])));
  }

// Widget for the cover photo and profile picture
  Widget get coverAndPfp => SizedBox(
        height: screenHeight * 0.4,
        width: double.infinity,
        child: Stack(
          // Profile picture overflow
          clipBehavior: Clip.none,
          children: [
            // Cover photo
            Container(
              height: screenHeight * 0.3,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage('assets/cover_photo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // App bar
            appBar,
            // Back button
            backButton,
            // Profile picture
            profilePicture,
            // Add Button
            addButton,
          ],
        ),
      );

// Heading
  Widget heading(double fontSized) {
    return Text(
      widget.friend.name,
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

  // Title
  Widget get appBar => Positioned(
        top: 40,
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
      );

  // Back button
  Widget get backButton => Positioned(
        top: 35,
        left: 24,
        child: backButtonIcon,
      );

  // Profile picture
  Widget get profilePicture => Positioned(
        top: screenHeight * 0.2,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.center,
          child: ClipOval(
            child: Container(
              height: 150,
              width: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              // Show default image if friend have no profile picture
              child: profilePictureURL != null && profilePictureURL!.isNotEmpty
                  ? Image.network(
                      profilePictureURL!,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/default_pfp.jpg',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      );

  // Add button
  Widget get addButton => Positioned(
        top: screenHeight * 0.33,
        left: 75,
        right: 0,
        child: Align(
          alignment: Alignment.center,
          child: IconButton(
            // Calls photoOptions/camera
            onPressed: () async {
              await showDialog(
                context: context,
                // Navigate to change profile picture modal page
                builder: (BuildContext context) =>
                    ModalPage(friend: widget.friend, type: "Change"),
              );
            },
            icon: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.photo_camera,
                    color: Color.fromARGB(255, 107, 107, 107)),
              ),
            ),
          ),
        ),
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

// Displaying name and username
  Widget displayName(Friend friend) {
    // Displays the name and username
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(friend.name,
          style: Formatting.boldStyle
              .copyWith(fontSize: 24, color: Formatting.black)),
    ]));
  }

  // Edit info button
  Widget get backButtonIcon => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
        color: const Color.fromARGB(255, 255, 255, 255),
      );
}
