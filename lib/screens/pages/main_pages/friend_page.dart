import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/user-friend_provider.dart';
import 'package:tolentino_mini_project/screens/pages/general%20pages/friend_modal.dart';
import 'package:tolentino_mini_project/screens/pages/general%20pages/qr-code_page.dart';
import 'package:tolentino_mini_project/screens/pages/general%20pages/summary_page.dart';

// Friends page
class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // Index for bottom navigation bar
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch friend list after signing up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendListProvider>().fetchFriendList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: theme(),
        child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 244, 244, 244),
            // Creates UI
            body: friendListUI(),
            // Button that navigates to slambook
            floatingActionButton: qrCodeScanner(),
            // Bottom navigation bar
            bottomNavigationBar: bottomNavigationBar()));
  }

  // Function for showing the list of friends (Overall UI)
  Widget friendListUI() {
    // Storing friend lists from the provider
    Stream<QuerySnapshot> friendList =
        context.watch<FriendListProvider>().friendList;

    return StreamBuilder(
      stream: friendList,
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
        } else if (snapshot.data?.docs.isEmpty ?? true) {
          // If no slambook data, display this:
          return noSlambookData;
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Title
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: heading,
              ),
              const SizedBox(height: 20),
              // List of friends
              Column(
                children: [
                  for (var doc in snapshot.data?.docs ?? [])
                    // Display the friend name using friendRowCreator
                    friendRowCreator(
                        // Map to friend to name
                        Friend.fromJson(doc.data() as Map<String, dynamic>),
                        doc),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Function for displaying a friend
  Padding friendRowCreator(Friend friend, var doc) {
    // Assigning the id to the friend.id
    friend.id = doc.id;
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      child: GestureDetector(
        onTap: () {
          // Navigate to the summary page when container is clicked
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                // Navigate to delete modal page
                SummaryPage(friend: friend),
          );
        },
        child: Container(
          // Container formatting
          height: 80,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 6.0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            // Row that contains picture, name and the buttons
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile picture
                    profilePicture(friend),
                    const SizedBox(width: 12),
                    // Name and nickname Formatting
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        nameAndverified(friend),
                        nickname(friend),
                      ],
                    ),
                  ],
                ),
                // Button for pop up menu
                popUpMenu(friend)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Floating qrCodeScanner
  Widget qrCodeScanner() {
    return FloatingActionButton(
      onPressed: () async {
        // Navigate to the QR Scanner page and wait for the result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRCodeScannerPage()),
        );
        if (result != null) {
          // Turn the result to a Map
          Map<String, dynamic> dataMap = jsonDecode(result);
          // Instantiate a friend
          Friend temp = Friend(
              verified: "Yes",
              name: dataMap["name"],
              nickname: dataMap["nickname"],
              age: dataMap["age"],
              relationshipStatus: dataMap["relationshipStatus"],
              happinessLevel: dataMap["happinessLevel"],
              superpower: dataMap["superpower"],
              motto: dataMap["motto"],
              profilePictureURL: dataMap["profilePictureURL"]);
          // Add friend to the firestore
          addFriend(temp);
        }
      },
      child: const Icon(Icons.qr_code_scanner),
    );
  }

  // Appending friend Id to the user's friendlist array
  Future<void> addFriend(Friend temp) async {
    String? uid = context.read<UserAuthProvider>().getCurrentUserId();
    await context.read<FriendListProvider>().addFriend(uid!, temp);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Succesfully added ${temp.name}')));
  }

  // Heading/Title
  Widget get heading => Row(
        children: [
          const Spacer(),
          const SizedBox(width: 24),
          Text(
            "Friends",
            style: Formatting.semiBoldStyle.copyWith(
              fontSize: 24,
              color: Formatting.black,
            ),
          ),
          const Spacer(),
          // Button for adding a friend
          IconButton(
              onPressed: () {
                // Navigate to Slambook page
                Navigator.popUntil(context, ModalRoute.withName("/"));
                Navigator.pushNamed(context, "/slambook");
              },
              icon: const Icon(Icons.add))
        ],
      );

  // Display this when no slambook data
  Widget get noSlambookData => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // Title
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Row(
                children: [
                  const Spacer(),
                  const SizedBox(width: 24),
                  Text(
                    "Friends",
                    style: Formatting.semiBoldStyle.copyWith(
                      fontSize: 24,
                      color: Formatting.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        // Navigate to Slambook page
                        Navigator.popUntil(context, ModalRoute.withName("/"));
                        Navigator.pushNamed(context, "/slambook");
                      },
                      icon: const Icon(Icons.add))
                ],
              ),
            ),
            const Spacer(),
            // Image
            Center(
                child: Column(
              children: [
                SizedBox(
                    width: 200, child: Image.asset("assets/frog_sleep.png")),
                const SizedBox(height: 12),
                // Text statement
                Text("No friends added yet",
                    style: Formatting.mediumStyle.copyWith(
                      fontSize: 16,
                      color: Formatting.black,
                    )),
                const SizedBox(height: 15),
              ],
            )),
            const Spacer(flex: 2),
          ],
        ),
      );

  // Profile picture
  Widget profilePicture(Friend friend) {
    return ClipOval(
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: friend.profilePictureURL != null
            ? Image.network(
                friend.profilePictureURL!,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_pfp.jpg',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  // Name and verified formatting
  Widget nameAndverified(Friend friend) {
    return SizedBox(
      width: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              friend.name,
              overflow: TextOverflow.ellipsis,
              style: Formatting.mediumStyle.copyWith(
                fontSize: 18,
                color: Formatting.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (friend.verified != "No")
            SizedBox(
              width: 20,
              child: Image.asset("assets/verified.png"),
            ),
        ],
      ),
    );
  }

  // Nickname
  Widget nickname(Friend friend) {
    return SizedBox(
      width: 150,
      child: Text(
        friend.name,
        overflow: TextOverflow.ellipsis,
        style: Formatting.regularStyle.copyWith(
          fontSize: 12,
          color: Formatting.black,
        ),
      ),
    );
  }

  // Popup Menu
  Widget popUpMenu(Friend friend) {
    return Row(
      children: [
        PopupMenuButton<int>(
          surfaceTintColor: const Color.fromARGB(255, 255, 255, 255),
          onSelected: (item) => handleClick(item, friend),
          itemBuilder: (context) => [
            // Edit
            if (friend.verified != "Yes")
              const PopupMenuItem<int>(
                  value: 0,
                  child: Row(children: [
                    Icon(Icons.edit),
                    SizedBox(width: 12),
                    Text('Edit')
                  ])),
            // Change profile picture
            const PopupMenuItem<int>(
                value: 1,
                child: Row(children: [
                  Icon(Icons.photo),
                  SizedBox(width: 12),
                  Text('Change Picture')
                ])),
            // Delete
            const PopupMenuItem<int>(
                value: 2,
                child: Row(children: [
                  Icon(Icons.delete),
                  SizedBox(width: 12),
                  Text('Delete')
                ])),
          ],
        ),
      ],
    );
  }

  // Handles the pop up menu when clicked
  void handleClick(int item, Friend friend) {
    switch (item) {
      case 0:
        showDialog(
          context: context,
          // Navigate to edit modal page
          builder: (BuildContext context) =>
              ModalPage(friend: friend, type: "Edit"),
        );
        break;
      case 1:
        showDialog(
          context: context,
          // Navigate to change modal page
          builder: (BuildContext context) =>
              ModalPage(friend: friend, type: "Change"),
        );
        break;
      case 2:
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              // Navigate to delete modal page
              ModalPage(friend: friend, type: 'Delete'),
        );
        break;
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

  Widget bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Formatting.primary,
      onTap: (index) {
        if (index == _currentIndex) {
          // Do nothing if tapping on the current tab
          return;
        }
        switch (index) {
          case 0:
            // Friends page (current page)
            Navigator.popUntil(context, ModalRoute.withName("/"));
            break;
          case 1:
            // Navigate to Slambook page
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.pushNamed(context, "/slambook");
            break;
          case 2:
            // Profile page
            Navigator.popUntil(context, ModalRoute.withName("/"));
            Navigator.pushNamed(context, "/profilepage");
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
