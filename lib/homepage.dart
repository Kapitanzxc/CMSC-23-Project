import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: drawer(),
        appBar: AppBar(title: Text("This is the first page")),
        body: Column(
          children: [
            TextField(
              controller: controller,
            ),
            ElevatedButton(
                onPressed: () {
                  final result = Navigator.pushNamed(context, "/slambookpage");
                },
                child: Text("Go to the second page")),
          ],
        ));
  }

  Widget drawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text("Menu, Routes, and Navigation")),
          ListTile(
              title: Text("First Page"),
              onTap: () {
                Navigator.pushNamed(context, "/homepage");
              }),
          ListTile(
              title: Text("Second Page"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/slambookpage");
              })
        ],
      ),
    );
  }
}
