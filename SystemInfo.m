//
//  SystemInfo.m
//  SystemInfo
//
//  Created by Ken M. Haggerty on 11/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "SystemInfo.h"
#import "AKDebugger.h"
#import "AKGenerics.h"

@protocol AssetsLibraryProtocol <NSObject>
@optional
- (void)addObserversForAssetsLibraryCategory;
- (void)removeObserversForAssetsLibraryCategory;
@end

@protocol ReachabilityProtocol <NSObject>
@optional
- (void)setupReachabilityWithPrivateInfo:(Class <PrivateInfo_Reachability>)privateInfo;
- (void)addObserversToReachability;
- (void)removeObserversFromReachability;
@end

#pragma mark - // DEFINITIONS (Private) //

#define SEGUE_DURATION 0.18

@interface SystemInfo () <AssetsLibraryProtocol, ReachabilityProtocol>
@property (nonatomic) Class privateInfo;
@property (nonatomic) UIDeviceOrientation deviceOrientation;

// RESPONDERS //

- (void)deviceOrientationDidChange:(NSNotification *)notification;

@end

@implementation SystemInfo

#pragma mark - // SETTERS AND GETTERS //

@synthesize privateInfo = _privateInfo;
@synthesize deviceOrientation = _deviceOrientation;

- (void)setPrivateInfo:(Class <PrivateInfo>)privateInfo {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    _privateInfo = privateInfo;
    
    if ([privateInfo conformsToProtocol:@protocol(PrivateInfo_Reachability)]) {
        [self setupReachabilityWithPrivateInfo:(Class <PrivateInfo_Reachability>)privateInfo];
    }
}

- (void)setDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    if (deviceOrientation == _deviceOrientation) return;
    
    _deviceOrientation = deviceOrientation;
    
    [AKGenerics postNotificationName:NOTIFICATION_DEVICE_ORIENTATION_DID_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:deviceOrientation] forKey:NOTIFICATION_OBJECT_KEY]];
}

#pragma mark - // INITS AND LOADS //

- (id)init {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    self = [super init];
    
    [self setup];
    return self;
}

- (void)awakeFromNib {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (Setup) //

+ (void)setupWithPrivateInfo:(Class)privateInfo {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    if (!privateInfo) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:nil message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(privateInfo)]];
    }
    
    [[SystemInfo sharedInfo] setPrivateInfo:privateInfo];
}

#pragma mark - // PUBLIC METHODS (General) //

+ (NSUUID *)deviceId {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[UIDevice currentDevice] identifierForVendor];
}

#pragma mark - // PUBLIC METHODS (Hardware) //

+ (CGSize)screenSize {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return [UIScreen mainScreen].bounds.size;
}

+ (BOOL)isPortrait {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return UIDeviceOrientationIsPortrait([[SystemInfo sharedInfo] deviceOrientation]);
}

+ (BOOL)isLandscape {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return UIDeviceOrientationIsLandscape([[SystemInfo sharedInfo] deviceOrientation]);
}

+ (BOOL)isRetina {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if ([UIScreen mainScreen].scale > 1.0) return YES;
    else return NO;
}

+ (BOOL)forceTouchEnabledForViewController:(UIViewController *)viewController {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if (![viewController.traitCollection respondsToSelector:@selector(forceTouchCapability)]) return NO;
    
    return (viewController.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable);
}

#pragma mark - // PUBLIC METHODS (Software) //

+ (NSString *)bundleIdentifier {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)appName {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[[NSBundle mainBundle] infoDictionary]  objectForKey:(id)kCFBundleNameKey];
}

+ (float)iOSVersion {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (CGFloat)statusBarHeight {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (UIStatusBarStyle)statusBarStyle {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return [UIApplication sharedApplication].statusBarStyle;
}

+ (void)setStatusBarStyle:(UIStatusBarStyle)style {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:style];
}

+ (void)setStatusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:animated];
}

+ (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
}

+ (UIColor *)iOSBlue {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

+ (BOOL)viewIsUsingAutoLayout:(UIView *)view {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
//    if (view.translatesAutoresizingMaskIntoConstraints) return YES;
    if (view.constraints.count) return YES;
    else return NO;
}

#pragma mark - // CATEGORY METHODS (PRIVATE) //

+ (instancetype)sharedInfo {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    static SystemInfo *_sharedInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInfo = [[SystemInfo alloc] init];
    });
    return _sharedInfo;
}

+ (Class)privateInfo {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] privateInfo];
}

#pragma mark - // OVERWRITTEN METHODS //

- (void)setup {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if ([self respondsToSelector:@selector(addObserversToReachability)]) {
        [self performSelector:@selector(addObserversToReachability)];
    }
    if ([self respondsToSelector:@selector(addObserversForAssetsLibraryCategory)]) {
        [self performSelector:@selector(addObserversForAssetsLibraryCategory)];
    }
}

- (void)teardown {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    if ([self respondsToSelector:@selector(removeObserversFromReachability)]) {
        [self performSelector:@selector(removeObserversFromReachability)];
    }
    if ([self respondsToSelector:@selector(removeObserversForAssetsLibraryCategory)]) {
        [self performSelector:@selector(removeObserversForAssetsLibraryCategory)];
    }
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [self setDeviceOrientation:[[UIDevice currentDevice] orientation]];
}

@end
