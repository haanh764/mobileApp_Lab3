import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:firebase_ml_vision/firebase_ml_vision.dart' as fb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
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
  dynamic final_objects;
  dynamic image_labels;
  dynamic final_rects;

  void pickImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    }
  }

  void OCR() async {
    fb.FirebaseVisionImage visionImage = fb.FirebaseVisionImage.fromFile(file);
    fb.TextRecognizer textRecognizer = fb.FirebaseVision.instance.textRecognizer();
    fb.VisionText visionText = await textRecognizer.processImage(visionImage);
    setState(() {
      text = visionText.text;
    });
  }

  void ImageLabelling() async {
    final inputImage = InputImage.fromFile(file);
    final imageLabels = await GoogleMlKit.vision.imageLabeler();
    final labels = await imageLabels.processImage(inputImage);
    setState(() {
      image_labels = labels;
    });
  }

  void ObjectDetection() async {
    final inputImage = InputImage.fromFile(file);
    final objectDetector = GoogleMlKit.vision.objectDetector(ObjectDetectorOptions(mode: DetectionMode.singleImage, classifyObjects: true, multipleObjects: false));
    final List<DetectedObject> objects = await objectDetector.processImage(inputImage);

    for(DetectedObject detectedObject in objects){
      final rect = detectedObject.boundingBox;
      if (detectedObject.labels.isNotEmpty) { 
        final_labels = detectedObject.labels;
        final_objects.add(detectedObject);
        setState(() {
          final_labels = final_labels;
          final_rects = rect;
          final_objects.add(detectedObject);
        });
      }
      else {
        final_labels = null;
        setState(() {
          final_labels = final_labels;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Image Processing App"),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  pickImage();
                },
                child: Text("Choose Image"),
              ),
              if (file != null)
                Image.file(
                  file,
                  width: double.infinity,
                  height: 400.0,
                  fit: BoxFit.contain,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      OCR();
                    },
                    child: Text("OCR"),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ObjectDetection();
                    },
                    child: Text("Object Detection"),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ImageLabelling();
                    },
                    child: Text("Image Labelling"),
                  ),
                ],
              ),
              if (text != null)
                Text(
                  'Text Recognition Results: \n' + text + '\n',
                  style: TextStyle(fontSize: 16.0),
                ),
              if (final_labels != null)
                Text('Object Detection Results: \n' + final_labels.map((Label label) => '${label.text} '
                                'with confidence ${label.confidence.toStringAsFixed(2)}')
                            .join('\n') + '\n',
                    style: TextStyle(fontSize: 16.0))
              else if (file != null && final_labels == null) 
                Text("No Object Detected \n", style: TextStyle(fontSize: 16.0)),
              if (image_labels != null)
                Text('Image Labelling Results: \n' + image_labels.map((ImageLabel label) => '${label.label} '
                                'with confidence ${label.confidence.toStringAsFixed(2)}')
                            .join('\n') + '\n',
                            style: TextStyle(fontSize: 16.0))
              else if (file != null && image_labels == null) 
                Text("No Image Labelled \n", style: TextStyle(fontSize: 16.0)),
            ],
          ),
        ),
      ),
    );
  }
}
