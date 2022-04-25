import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
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
  dynamic text;
  dynamic final_labels;

  void pickImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    }
  }

  void OCR() async {
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(file);
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await textRecognizer.processImage(visionImage);
    print(visionText.text);
    setState(() {
      text = visionText.text;
    });
  }

  void ObjectDetection() async {
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(file);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    final List<ImageLabel> labels = await labeler.processImage(visionImage);
    print(labels);
    setState(() {
      final_labels = labels;
    });
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
                  OCR();
                },
                child: Text("OCR"),
              ),
              if (text != null)
                Text(
                  text,
                  style: TextStyle(fontSize: 20.0),
                ),
              ElevatedButton(
                onPressed: () {
                  ObjectDetection();
                },
                child: Text("Object Detection"),
              ),
              if (final_labels != null)
                Text(
                  final_labels.map((label) => '${label.text} '
                                'with confidence ${label.confidence.toStringAsFixed(2)}')
                            .join('\n'),
                  style: TextStyle(fontSize: 20.0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}