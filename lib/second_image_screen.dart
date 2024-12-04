import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class SecondImageScreen extends StatefulWidget {
  final XFile imageOne;

  const SecondImageScreen({Key? key, required this.imageOne}) : super(key: key);

  @override
  _SecondImageScreenState createState() => _SecondImageScreenState();
}

class _SecondImageScreenState extends State<SecondImageScreen> {
  XFile? _imageTwo;
  String similarityResult = '';
  late Interpreter _interpreter;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // Load the TFLite model
  Future<void> loadModel() async {
    _interpreter =
        await Interpreter.fromAsset('assets/mobilenet_v3_large.tflite');
  }

  Future<void> _selectSecondImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageTwo = pickedImage;
    });
  }

  Future<void> _compareImages() async {
    if (_imageTwo != null) {
      try {
        final img.Image image1 =
            img.decodeImage(await widget.imageOne.readAsBytes())!;
        final img.Image image2 =
            img.decodeImage(await _imageTwo!.readAsBytes())!;

        // Convert images to embeddings
        final embedding1 = await _getEmbedding(image1);
        final embedding2 = await _getEmbedding(image2);

        // Calculate cosine similarity
        final similarity = _cosineSimilarity(embedding1, embedding2);

        setState(() {
          if (similarity >= 0.9) {
            similarityResult = 'Images are Similar';
          } else {
            similarityResult = 'Images are Not Similar';
          }
        });
      } catch (e) {
        setState(() {
          similarityResult = "Error: $e";
        });
      }
    } else {
      setState(() {
        similarityResult = "Please select the second image.";
      });
    }
  }

  // Convert image to embedding using the TFLite model
  Future<List<double>> _getEmbedding(img.Image image) async {
    var input = _preprocessImage(image);
    var output = List.filled(1280, 0.0).reshape([1, 1280]);
    _interpreter.run(input, output);
    return output[0];
  }

  // Preprocess the image to match model input size (224x224)
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    var resizedImage = img.copyResize(image, width: 224, height: 224);

    var input = List.generate(
        1,
        (i) => List.generate(
            224,
            (j) => List.generate(224, (k) {
                  var pixel = resizedImage.getPixel(j, k);
                  final redValue = pixel.r;
                  final greenValue = pixel.g;
                  final blueValue = pixel.b;
                  return [
                    (redValue / 255.0 - 0.485) / 0.229,
                    (greenValue / 255.0 - 0.456) / 0.224,
                    (blueValue / 255.0 - 0.406) / 0.225
                  ];
                })));
    return input;
  }

  // Compute cosine similarity
  double _cosineSimilarity(List<double> vec1, List<double> vec2) {
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;
    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      norm1 += vec1[i] * vec1[i];
      norm2 += vec2[i] * vec2[i];
    }
    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Image Comparison",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 21, 6, 48),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                  onPressed: _selectSecondImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 21, 6, 48), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    "Upload Second Image",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),
                if (_imageTwo != null)
                  Card(
                    color: const Color.fromARGB(255, 21, 6, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(_imageTwo!.path),
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _imageTwo != null ? _compareImages : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 21, 6, 48), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    "Compare Images",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70),
                  ),
                ),
                if (similarityResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      similarityResult,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: similarityResult.contains("Not")
                            ? Colors.red
                            : Colors.green,
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
