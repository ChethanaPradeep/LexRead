import 'package:flutter/material.dart';

class FocusReadPage extends StatefulWidget {
  const FocusReadPage({Key? key}) : super(key: key);

  @override
  State<FocusReadPage> createState() => _FocusReadPageState();
}

class _FocusReadPageState extends State<FocusReadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: const Text("Title of PDF"),
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.menu),
      ),
    ));
  }
}
