#import "MlKitImageLabelerPlugin.h"

@implementation MlKitImageLabelerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"ml_kit_image_labeler"
                                     binaryMessenger:[registrar messenger]];
    MlKitImageLabelerPlugin* instance = [[MlKitImageLabelerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    NSMutableArray *handlers = [NSMutableArray new];
    [handlers addObject:[[ImageLabeler alloc] init]];
    
    instance.handlers = [NSMutableDictionary new];
    for (id<Handler> detector in handlers) {
        for (NSString *key in detector.getMethodsKeys) {
            instance.handlers[key] = detector;
        }
    }
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    id<Handler> handler = self.handlers[call.method];
    if (handler != NULL) {
        [handler handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
