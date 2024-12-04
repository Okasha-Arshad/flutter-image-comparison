import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_image_embed/second_image_screen.dart';

class FirstImageScreen extends StatefulWidget {
  const FirstImageScreen({super.key});

  @override
  _FirstImageScreenState createState() => _FirstImageScreenState();
}

class _FirstImageScreenState extends State<FirstImageScreen> {
  XFile? _imageOne;
  final ImagePicker _picker = ImagePicker();

  void _goToSecondScreen() {
    if (_imageOne != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondImageScreen(imageOne: _imageOne!),
        ),
      );
    }
  }

  Future<void> _selectFirstImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageOne = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Image Comparison",
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: const Color.fromARGB(255, 21, 6, 48),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 21, 6, 48).withOpacity(0.1),
              Colors.white
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _selectFirstImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 6, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    "Upload First Image",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_imageOne != null)
                  Card(
                    color: const Color.fromARGB(255, 21, 6, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(_imageOne!.path),
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _imageOne != null ? _goToSecondScreen : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 6, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
