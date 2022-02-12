//
//  ImageLabeler.m
//  ml_kit_image_labeler
//
//  Created by Madhav Tripathi on 09/02/22.
//


#import "MlKitImageLabelerPlugin.h"
#import <MLKitCommon/MLKitCommon.h>
#import <MLKitImageLabeling/MLKitImageLabeling.h>
#import <MLKitImageLabelingCommon/MLKitImageLabelingCommon.h>

#define startImageLabelDetector @"processImage"
#define closeImageLabelDetector @"closeDetector"

@implementation ImageLabeler {
    MLKImageLabeler *labeler;
}

- (NSArray *)getMethodsKeys {
    return @[startImageLabelDetector,
             closeImageLabelDetector];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:startImageLabelDetector]) {
        [self handleDetection:call result:result];
    } else if ([call.method isEqualToString:closeImageLabelDetector]) {
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    MLKVisionImage *image = [MLKVisionImage visionImageFromData:call.arguments[@"imageData"]];
    NSDictionary *dictionary = call.arguments[@"options"];
    
    
    MLKImageLabelerOptions *options = [self getImageLabelerOptions:dictionary];
    labeler = [MLKImageLabeler imageLabelerWithOptions:options];
    
    
    [labeler processImage:image
               completion:^(NSArray<MLKImageLabel *> *_Nullable labels, NSError *_Nullable error) {
        if (error) {
            result(getFlutterError(error));
            return;
        } else if (!labels) {
            result(@[]);
        }
        
        NSMutableArray *labelData = [NSMutableArray array];
        for (MLKImageLabel *label in labels) {
            NSDictionary *data = @{
                @"confidence" : @(label.confidence),
                @"index" : @(label.index),
                @"text" : label.text,
            };
            [labelData addObject:data];
        }
        
        result(labelData);
    }];
}

- (MLKImageLabelerOptions *)getImageLabelerOptions:(NSDictionary *)optionsData {
    NSNumber *conf = optionsData[@"confidenceThreshold"];
    
    MLKImageLabelerOptions *options = [MLKImageLabelerOptions new];
    options.confidenceThreshold = conf;
    
    return options;
}



@end
