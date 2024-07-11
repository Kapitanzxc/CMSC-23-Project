import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolentino_exer7_firebase/models/friend_model.dart';
import 'package:tolentino_exer7_firebase/provider/friends_provider.dart';
import 'package:tolentino_exer7_firebase/screens/modal_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the slambook page
            Navigator.pushNamed(context, "/slambook");
          },
          child: const Icon(Icons.add_outlined),
        ));
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

  // Drawer function
  Widget drawer() {
    return Drawer(
      child: ListView(
        children: [
          // Title bar of the drawer
          Container(
            color: Color.fromRGBO(26, 77, 46, 1),
            height: 100,
            child: const DrawerHeader(
              child: Text(
                "Menu",
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
                Navigator.pushNamed(context, "/slambook");
                // Update the friend list data once received
              }),
        ],
      ),
    );
  }
}
