import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_mini_project/models/friend_model.dart';
import 'package:tolentino_mini_project/provider/auth_provider.dart';
import 'package:tolentino_mini_project/provider/friends_provider.dart';
import 'package:tolentino_mini_project/screens/pages/modal_page.dart';

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
  Widget build(BuildContext context) {
    // Fetch friend list after signing up
    context.read<FriendListProvider>().fetchFriendList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(26, 77, 46, 1),
        title: Text("Friends", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Color.fromRGBO(245, 239, 230, 1),
      // Creates UI
      body: friendListUI(),
      // Button that navigates to slambook
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/slambook");
        },
        child: const Icon(Icons.add_outlined),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              // Friends page (current page)
              break;
            case 1:
              // Navigate to Slambook page
              Navigator.pushNamed(context, "/slambook");
              break;
            case 2:
              // Profile page
              context.read<UserAuthProvider>().signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              break;
          }
        },
        // Icons
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Slambook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }

  // Function for showing the list of friends (Overall UI)
  Widget friendListUI() {
    // Storing friend lists from the provider
    Stream<QuerySnapshot> friendList =
        context.watch<FriendListProvider>().friendList;
    return StreamBuilder(
      stream: friendList,
      builder: (context, snapshot) {
        // Catching errrors
        if (snapshot.hasError) {
          return Center(
            child: Text("Error encountered! ${snapshot.error}"),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
          // If no snapshot: Display no friends added yet
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(
              child: const Column(
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
            ],
          ));
        }
        return ListView.builder(
          // Iterate through the snapshot
          itemCount: snapshot.data?.docs.length,
          itemBuilder: ((context, index) {
            Friend friend = Friend.fromJson(
                snapshot.data?.docs[index].data() as Map<String, dynamic>);
            friend.id = snapshot.data?.docs[index].id;
            return SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(height: 10),
                // Display the friend name using friendRowCreator
                friendRowCreator(
                    friend.name, friend.toJson(friend).values.toList(), friend),
              ],
            ));
          }),
        );
      },
    );
  }

  // Function for displaying a friend
  Padding friendRowCreator(String name, List values, Friend friend) {
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
              Row(
                children: [
                  // Icon button for showing the summary or details page
                  IconButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color.fromRGBO(79, 111, 82, 1),
                    ),
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      Navigator.pushNamed(context, "/summary",
                          arguments: values);
                    },
                  ),
                  // Icon button for editing a friend
                  IconButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color.fromRGBO(79, 111, 82, 1),
                    ),
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            ModalPage(friend: friend, type: "Edit"),
                      );
                    },
                  ),
                  // Icon button for deleting a friend
                  IconButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color.fromRGBO(79, 111, 82, 1),
                    ),
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => ModalPage(
                          friend: friend,
                          type: 'Delete',
                        ),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
