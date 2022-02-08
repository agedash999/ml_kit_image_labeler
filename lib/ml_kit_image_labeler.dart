// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

class MlKitImageLabeler {
  static const MethodChannel _channel = MethodChannel('ml_kit_image_labeler');

  bool _isOpened = false;
  bool _isClosed = false;

  /// Function that takes [InputImage] processes it and returns a List of [ImageLabel]
  Future<List<ImageLabel>> processImage(InputImage inputImage) async {
    _isOpened = true;

    final result = await _channel.invokeMethod('processImage',
        <String, dynamic>{'imageData': inputImage.getImageData()});
    var imageLabels = <ImageLabel>[];

    for (dynamic data in result) {
      imageLabels.add(ImageLabel(data));
    }

    return imageLabels;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await _channel.invokeMethod('closeDetector');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

/// This represents a label detected in image.
class ImageLabel {
  ImageLabel(dynamic data)
      : confidence = data['confidence'],
        label = data['text'],
        index = data['index'];

  /// The confidence(probability) given to label that was identified in image
  final double confidence;

  /// Label or title given for detected entity in image
  final String label;

  /// Index of label according to google's label map [https://developers.google.com/ml-kit/vision/image-labeling/label-map]
  final int index;
}

/// [InputImage] is the format Google' Ml kit takes to process the image
class InputImage {
  String? filePath;
  Uint8List? bytes;
  String imageType;
  InputImageData? inputImageData;
  InputImage._(
      {this.filePath,
      this.bytes,
      required this.imageType,
      this.inputImageData});

  /// Create InputImage from path of image stored in device.
  factory InputImage.fromFilePath(String path) {
    return InputImage._(filePath: path, imageType: 'file');
  }

  /// Create InputImage by passing a file.
  factory InputImage.fromFile(File file) {
    return InputImage._(filePath: file.path, imageType: 'file');
  }

  /// Create InputImage using bytes.
  factory InputImage.fromBytes(
      {required Uint8List bytes, required InputImageData inputImageData}) {
    return InputImage._(
        bytes: bytes, imageType: 'bytes', inputImageData: inputImageData);
  }

  Map<String, dynamic> getImageData() {
    var map = <String, dynamic>{
      'bytes': bytes,
      'type': imageType,
      'path': filePath,
      'metadata':
          inputImageData == null ? 'none' : inputImageData!.getMetaData()
    };
    return map;
  }
}

// To indicate the format of image while creating input image from bytes
enum InputImageFormat { NV21, YV12, YUV_420_888, YUV420, BGRA8888 }

extension InputImageFormatMethods on InputImageFormat {
  // source: https://developers.google.com/android/reference/com/google/mlkit/vision/common/InputImage#constants
  static Map<InputImageFormat, int> get _values => {
        InputImageFormat.NV21: 17,
        InputImageFormat.YV12: 842094169,
        InputImageFormat.YUV_420_888: 35,
        InputImageFormat.YUV420: 875704438,
        InputImageFormat.BGRA8888: 1111970369,
      };

  int get rawValue => _values[this] ?? 17;

  static InputImageFormat? fromRawValue(int rawValue) {
    return InputImageFormatMethods._values
        .map((k, v) => MapEntry(v, k))[rawValue];
  }
}

// The camera rotation angle to be specified
enum InputImageRotation {
  Rotation_0deg,
  Rotation_90deg,
  Rotation_180deg,
  Rotation_270deg
}

extension InputImageRotationMethods on InputImageRotation {
  static Map<InputImageRotation, int> get _values => {
        InputImageRotation.Rotation_0deg: 0,
        InputImageRotation.Rotation_90deg: 90,
        InputImageRotation.Rotation_180deg: 180,
        InputImageRotation.Rotation_270deg: 270,
      };

  int get rawValue => _values[this] ?? 0;

  static InputImageRotation? fromRawValue(int rawValue) {
    return InputImageRotationMethods._values
        .map((k, v) => MapEntry(v, k))[rawValue];
  }
}

/// Data of image required when creating image from bytes.
class InputImageData {
  /// Size of image.
  final Size size;

  /// Image rotation degree.
  final InputImageRotation imageRotation;

  /// Format of the input image.
  final InputImageFormat inputImageFormat;

  /// The plane attributes to create the image buffer on iOS.
  ///
  /// Not used on Android.
  final List<InputImagePlaneMetadata>? planeData;

  InputImageData(
      {required this.size,
      required this.imageRotation,
      required this.inputImageFormat,
      required this.planeData});

  /// Function to get the metadata of image processing purposes
  Map<String, dynamic> getMetaData() {
    var map = <String, dynamic>{
      'width': size.width,
      'height': size.height,
      'rotation': imageRotation.rawValue,
      'imageFormat': inputImageFormat.rawValue,
      'planeData': planeData
          ?.map((InputImagePlaneMetadata plane) => plane._serialize())
          .toList(),
    };
    return map;
  }
}

/// Plane attributes to create the image buffer on iOS.
///
/// When using iOS, [height], and [width] throw [AssertionError]
/// if `null`.
class InputImagePlaneMetadata {
  InputImagePlaneMetadata({
    required this.bytesPerRow,
    this.height,
    this.width,
  });

  /// The row stride for this color plane, in bytes.
  final int bytesPerRow;

  /// Height of the pixel buffer on iOS.
  final int? height;

  /// Width of the pixel buffer on iOS.
  final int? width;

  Map<String, dynamic> _serialize() => <String, dynamic>{
        'bytesPerRow': bytesPerRow,
        'height': height,
        'width': width,
      };
}
