import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePage();
  }
}

class HomePage extends State<MyApp> {
  dynamic file;

  void pickImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Image Picker"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  pickImage();
                },
                child: Text("Select Image"),
              ),
              if (file != null)
                Image.file(
                  file,
                  width: double.infinity,
                  height: 400.0,
                  fit: BoxFit.contain,
                ),
              ElevatedButton(
                onPressed: () {
                  pickImage();
                },
                child: Text("OCR"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}