package com.madhavcodes.ml_kit_image_labeler

import android.content.Context
import com.google.mlkit.vision.label.ImageLabeler
import com.google.mlkit.vision.label.ImageLabeling
import com.google.mlkit.vision.label.defaults.ImageLabelerOptions
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.*
import java.util.*


//Detector to identify the entities present in an image.
//It's an abstraction over ImageLabeler provided by ml tool kit.
class ImageLabelDetector(private val context: Context) : MethodCallHandler {
    private var imageLabeler: ImageLabeler? = null
    private val detectionScope = CoroutineScope(Job() + Dispatchers.IO)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            START -> {
                detectionScope.launch {
                    handleDetection(call, result)
                }
            }
            CLOSE -> {
                closeDetector()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleDetection(call: MethodCall, result: MethodChannel.Result) {
        val imageData = call.argument<Map<String, Any>>("imageData")!!
        val inputImage = InputImageConverter.getInputImageFromData(
            imageData as Map<String, Any?>,
            context, result
        ) ?: return

        imageLabeler = ImageLabeling.getClient(ImageLabelerOptions.DEFAULT_OPTIONS)

        imageLabeler!!.process(inputImage)
            .addOnSuccessListener { imageLabels ->
                val labels: MutableList<Map<String, Any>> =
                    ArrayList(imageLabels.size)
                for (label in imageLabels) {
                    val labelData: MutableMap<String, Any> =
                        HashMap()
                    labelData["text"] = label.text
                    labelData["confidence"] = label.confidence
                    labelData["index"] = label.index
                    labels.add(labelData)
                }
                result.success(labels)
            }
            .addOnFailureListener { e ->
                result.error(
                    "ImageLabelDetectorError",
                    e.toString(),
                    null
                )
            }
    }


    private fun closeDetector() {
        detectionScope.cancel()
        imageLabeler!!.close()
        imageLabeler = null
    }

    companion object {
        private const val START = "processImage"
        private const val CLOSE = "closeDetector"
    }
}