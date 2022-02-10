# MLKIT Image Labeler
Plugin which provides native ML Kit ImageLabeler API

### Requirements

**Android**
- Set `minSdkVersion 21` in `android/app/build.gradle`
- Set `ext.kotlin_version = '1.6.10'` in `android/build.gradle`

- *App size impact: 700KB(Using Unbundled Model, downloads model using Google play services for the first time when app launches)*, refer [here](https://developers.google.com/ml-kit/vision/image-labeling/android)

**iOS**
- Minimum iOS Deployment Target: 10.0
- Xcode 12.5.1 or greater.
- ML Kit only supports 64-bit architectures (x86_64 and arm64). Check this [list](https://developer.apple.com/support/required-device-capabilities/) to see if your device has the required device capabilities.
- Since ML Kit does not support 32-bit architectures (i386 and armv7) [Read more](https://developers.google.com/ml-kit/migration/ios), you need to exclude amrv7 architectures in Xcode in order to build iOS, refer [here](https://developers.google.com/ml-kit/vision/image-labeling/ios)


### Usage 
```dart
// Create an Instance of [MlKitImageLabeler]
final imageLabeler = MlKitImageLabeler();


//...
// Pick Image using image picker
//...

// Call `processImage()` and pass params as `InputImage` [check example for more info]
final labels = await imageLabeler.processImage(
    InputImage.fromFilePath(image.path));

String predictedLabels = '';

// Iterate over Labels 
for (var label in labels) {
    predictedLabels +=
        '\n${label.label} ${(label.confidence * 100).toStringAsPrecision(2)}%';
}
```

This plugin is basically a trimmed down version of [google_ml_kit](https://pub.dev/packages/google_ml_kit). As google_ml_kit contains all the NLP and Vison APIs, the App size increases drastically. So, I created this plugin and now the example app's fat apk is of 17MB and splitted apks are 6MB.