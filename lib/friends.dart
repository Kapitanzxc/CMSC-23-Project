import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // A map for storing friend lists
  Map<String, List> friendList = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer and scaffold formatting
      drawer: drawer(),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(26, 77, 46, 1),
        title: Text("Friends", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Color.fromRGBO(245, 239, 230, 1),
      // Creation of UI
      body: friendListUI(),
    );
  }

  // Drawer function
  Widget drawer() {
    return Drawer(
      child: ListView(
        children: [
          // Title bar of the drawer
          Container(
            color: Color.fromRGBO(26, 77, 46, 1),
            height: 100,
            child: DrawerHeader(
              child: Text(
                "Exercise 5: Menu, Routes, and Navigation",
                style: TextStyle(
                    fontSize: 20, color: Color.fromRGBO(243, 243, 243, 1)),
              ),
            ),
          ),
          // Friends tab (only pops the drawer since its currently on friends page)
          ListTile(
            title: Text("Friends"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // Slambook Tab
          ListTile(
              title: Text("Slambook"),
              onTap: () async {
                // Closes the drawer
                Navigator.pop(context);
                // Navigate to the slambook page and also passed the friend list data
                final result = await Navigator.pushNamed(
                    context, "/slambookpage",
                    arguments: friendList);

                // Update the friend list data once received
                if (result != null) {
                  setState(() {
                    friendList = result as Map<String, List>;
                  });
                }
              }),
        ],
      ),
    );
  }

  // Function for showing the list of friends (Overall UI)
  Widget friendListUI() {
    // If its empty, show that there is no friends and a button
    if (friendList.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            Icons.group,
            color: Color.fromRGBO(79, 111, 82, 1),
            size: 50,
          ),
          // Text statement
          Text("No friends added yet"),
          SizedBox(height: 15),
          // Button going to the slambook page
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Color.fromRGBO(255, 255, 255, 1),
              backgroundColor: Color.fromRGBO(79, 111, 82, 1),
            ),
            onPressed: () async {
              // Navigate to the slambook page and also passed the friend list data
              final result = await Navigator.pushNamed(context, "/slambookpage",
                  arguments: friendList);
              // Update the friend list data once received
              if (result != null) {
                setState(() {
                  friendList = result as Map<String, List>;
                });
              }
            },
            // Text label
            child: Text(
              "Go to Slambook",
              style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
            ),
          ),
        ],
      ));
      // If there is at least on friend, display it
    } else {
      return SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(height: 10),
          // Display the friend name using friendRowCreator
          for (var key in friendList.keys)
            friendRowCreator(friendList[key]?[0], friendList[key]!),
        ],
      ));
    }
  }

  // Function for displaying a friend
  Padding friendRowCreator(String name, List values) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Container(
        // Container formatting
        height: 80,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          border: Border.all(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          // Row that contains the name and  the button
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Name Formatting
              Text(
                name,
                style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(79, 111, 82, 1),
                    fontWeight: FontWeight.bold),
              ),
              // Text button formatting
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Color.fromRGBO(255, 255, 255, 1),
                  backgroundColor: Color.fromRGBO(79, 111, 82, 1),
                ),
                child: Text("View Details"),
                // Text button navigates to the summary page along with the arguments (friend information)
                onPressed: () {
                  Navigator.pushNamed(context, "/summarypage",
                      arguments: values);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
