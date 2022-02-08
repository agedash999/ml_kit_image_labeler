import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:ml_kit_image_labeler/ml_kit_image_labeler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  XFile? image;
  String predictedLabels = '';
  String timeElapsed = '';
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MlKit image labeler example '),
        ),
        body: ListView(
          physics: const ClampingScrollPhysics(),
          children: [
            const SizedBox(height: 20),
            if (image != null)
              SizedBox(
                height: 200,
                width: 200,
                child: InteractiveViewer(
                  child: Image.file(
                    File(image!.path),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (predictedLabels.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText('Predicted Labels: $predictedLabels'),
              ),
            if (timeElapsed.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Time elapsed: $timeElapsed ms'),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    predictedLabels = '';
                    timeElapsed = '';
                    setState(() {});
                  },
                  child: const Text('Pick Image'),
                ),
                if (image != null)
                  isProcessing
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            final imageLabeler = MlKitImageLabeler();
                            final stopwatch = Stopwatch()..start();
                            predictedLabels = '';
                            isProcessing = true;
                            setState(() {});

                            final labels = await imageLabeler.processImage(
                                InputImage.fromFilePath(image!.path));

                            timeElapsed =
                                stopwatch.elapsedMilliseconds.toString();

                            isProcessing = false;

                            for (var label in labels) {
                              predictedLabels +=
                                  '\n${label.label} ${(label.confidence * 100).toStringAsPrecision(4)}%';
                            }
                            stopwatch.reset();
                            stopwatch.stop();

                            setState(() {});
                          },
                          child: const Text('Predict from Image'),
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
