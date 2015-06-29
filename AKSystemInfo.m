//
//  AKSystemInfo.m
//  AKSystemInfo
//
//  Created by Ken M. Haggerty on 11/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AKSystemInfo.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "Reachability.h"
#import "AKPrivateInfo.h"

#pragma mark - // DEFINITIONS (Private) //

@interface AKSystemInfo ()
@property (nonatomic, strong) Reachability *reachability;
+ (id)sharedInfo;
+ (Reachability *)reachability;
- (void)setup;
- (void)teardown;
- (void)internetStatusDidChange:(NSNotification *)notification;
@end

@implementation AKSystemInfo

#pragma mark - // SETTERS AND GETTERS //

- (Reachability *)reachability
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (_reachability) return _reachability;
    
    _reachability = [Reachability reachabilityWithHostName:[AKPrivateInfo reachabilityDomain]];
    [_reachability startNotifier];
    return _reachability;
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    self = [super init];
    if (!self)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeCritical methodType:AKMethodTypeSetup customCategories:nil message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
        return nil;
    }
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS //

+ (float)iOSVersion
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (CGSize)screenSize
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    return [UIScreen mainScreen].bounds.size;
}

+ (BOOL)isPortrait
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation == UIDeviceOrientationPortrait) || (orientation == UIDeviceOrientationPortraitUpsideDown)) return YES;
    else return NO;
}

+ (BOOL)isLandscape
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight)) return YES;
    else return NO;
}

+ (BOOL)isRetina
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    if ([UIScreen mainScreen].scale > 1.0) return YES;
    else return NO;
}

+ (CGFloat)statusBarHeight
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (UIStatusBarStyle)statusBarStyle
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    return [UIApplication sharedApplication].statusBarStyle;
}

+ (void)setStatusBarStyle:(UIStatusBarStyle)style
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:style];
}

+ (void)setStatusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:animated];
}

+ (UIColor *)iOSBlue
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

+ (BOOL)viewIsUsingAutoLayout:(UIView *)view
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_UI] message:nil];
    
//    if (view.translatesAutoresizingMaskIntoConstraints) return YES;
    if (view.constraints.count) return YES;
    else return NO;
}

+ (BOOL)isReachable
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[[AKSystemInfo sharedInfo] reachability] isReachable];
}

+ (BOOL)isReachableViaWiFi
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[[AKSystemInfo sharedInfo] reachability] isReachableViaWiFi];
}

+ (BOOL)isReachableViaWWAN
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[[AKSystemInfo sharedInfo] reachability] isReachableViaWWAN];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

+ (id)sharedInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    static AKSystemInfo *sharedInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInfo = [[AKSystemInfo alloc] init];
    });
    return sharedInfo;
}

+ (Reachability *)reachability
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[AKSystemInfo sharedInfo] reachability];
}

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetStatusDidChange:) name:kReachabilityChangedNotification object:self.reachability];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:self.reachability];
}

- (void)internetStatusDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    if (![AKSystemInfo isReachable])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNETSTATUS_DID_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:AKDisconnected] forKey:NOTIFICATION_OBJECT_KEY]];
        return;
    }
    
    if ([AKSystemInfo isReachableViaWiFi])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNETSTATUS_DID_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:AKConnectedViaWiFi] forKey:NOTIFICATION_OBJECT_KEY]];
    }
    if ([AKSystemInfo isReachableViaWWAN])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNETSTATUS_DID_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:AKConnectedViaWWAN] forKey:NOTIFICATION_OBJECT_KEY]];
    }
}

@end