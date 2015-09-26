//
//  AKSystemInfo.m
//  AKSystemInfo
//
//  Created by Ken M. Haggerty on 11/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AKSystemInfo+PRIVATE.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "Reachability.h"
#import "AKPrivateInfo.h"

#pragma mark - // DEFINITIONS (Private) //

#define SEGUE_DURATION 0.18

#define USERDEFAULTS_KEY_WIFI_ENABLED @"wifiEnabled"
#define USERDEFAULTS_KEY_WWAN_ENABLED @"wwanEnabled"

#define INTERNET_MAX_ATTEMPTS_COUNT 0
#define INTERNET_MAX_ATTEMPTS_TIME 1.0

@interface AKSystemInfo ()
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic) AKInternetStatus currentStatus;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

// GENERAL //

- (void)setup;
- (void)teardown;

// CONVENIENCE //

+ (Reachability *)reachability;
+ (NSUserDefaults *)userDefaults;

// RESPONDERS //

- (void)internetStatusDidChange:(NSNotification *)notification;

// HELPER //

+ (void)updateInternetStatus;

@end

@implementation AKSystemInfo

#pragma mark - // SETTERS AND GETTERS //

@synthesize reachability = _reachability;
@synthesize currentStatus = _currentStatus;
@synthesize userDefaults = _userDefaults;

- (Reachability *)reachability
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (_reachability) return _reachability;
    
    _reachability = [Reachability reachabilityWithHostName:[AKPrivateInfo reachabilityDomain]];
    [_reachability startNotifier];
    return _reachability;
}

- (void)setCurrentStatus:(AKInternetStatus)currentStatus
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    if (currentStatus == _currentStatus) return;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInteger:currentStatus] forKey:NOTIFICATION_OBJECT_KEY];
    [userInfo setObject:[NSNumber numberWithInteger:_currentStatus] forKey:NOTIFICATION_OLD_KEY];
    
    _currentStatus = currentStatus;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNETSTATUS_DID_CHANGE object:nil userInfo:userInfo];
}

- (NSUserDefaults *)userDefaults
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (_userDefaults) return _userDefaults;
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
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

#pragma mark - // PUBLIC METHODS (Hardware) //

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

#pragma mark - // PUBLIC METHODS (Software) //

+ (float)iOSVersion
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[[UIDevice currentDevice] systemVersion] floatValue];
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

+ (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:@[AKD_UI] message:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
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

#pragma mark - // PUBLIC METHODS (Internet) //

+ (AKInternetStatus)internetStatus
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[AKSystemInfo sharedInfo] currentStatus];
}

+ (BOOL)isReachable
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return ([AKSystemInfo isReachableViaWiFi] || [AKSystemInfo isReachableViaWWAN]);
}

+ (BOOL)isReachableViaWiFi
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (![AKSystemInfo wifiEnabled]) return NO;
    
    int attempt = 0;
    BOOL isReachable;
    NSDate *startDate = [NSDate date];
    do {
        isReachable = [[[AKSystemInfo sharedInfo] reachability] isReachableViaWiFi];
    } while (!isReachable && (!INTERNET_MAX_ATTEMPTS_COUNT || (++attempt < INTERNET_MAX_ATTEMPTS_COUNT)) && (!INTERNET_MAX_ATTEMPTS_TIME || ([[NSDate date] timeIntervalSinceDate:startDate] < INTERNET_MAX_ATTEMPTS_TIME)));
    if (isReachable)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategories:nil message:[NSString stringWithFormat:@"Found Internet connection after %i attempts.", ++attempt]];
    }
    else
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategories:nil message:[NSString stringWithFormat:@"No Internet connection detected after %i attempts.", ++attempt]];
    }
    return isReachable;
}

+ (BOOL)isReachableViaWWAN
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    if (![AKSystemInfo wwanEnabled]) return NO;
    
    int attempt = 0;
    BOOL isReachable;
    NSDate *startDate = [NSDate date];
    do {
        isReachable = [[[AKSystemInfo sharedInfo] reachability] isReachableViaWWAN];
    } while (!isReachable && (!INTERNET_MAX_ATTEMPTS_COUNT || (++attempt < INTERNET_MAX_ATTEMPTS_COUNT)) && (!INTERNET_MAX_ATTEMPTS_TIME || ([[NSDate date] timeIntervalSinceDate:startDate] < INTERNET_MAX_ATTEMPTS_TIME)));
    if (isReachable)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter customCategories:nil message:[NSString stringWithFormat:@"Found Internet connection after %i attempts.", ++attempt]];
    }
    else
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter customCategories:nil message:[NSString stringWithFormat:@"No Internet connection detected after %i attempts.", ++attempt]];
    }
    return isReachable;
}

+ (BOOL)wifiEnabled
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    NSUserDefaults *userDefaults = [AKSystemInfo userDefaults];
    NSNumber *wifiEnabled = [userDefaults objectForKey:USERDEFAULTS_KEY_WIFI_ENABLED];
    if (wifiEnabled) return wifiEnabled.boolValue;
    
    [AKSystemInfo setWiFiEnabled:YES];
    return YES;
}

+ (void)setWiFiEnabled:(BOOL)wifiEnabled
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    NSUserDefaults *userDefaults = [AKSystemInfo userDefaults];
    [userDefaults setBool:wifiEnabled forKey:USERDEFAULTS_KEY_WIFI_ENABLED];
    [userDefaults synchronize];
    [AKSystemInfo updateInternetStatus];
}

+ (BOOL)wwanEnabled
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    NSUserDefaults *userDefaults = [AKSystemInfo userDefaults];
    NSNumber *wwanEnabled = [userDefaults objectForKey:USERDEFAULTS_KEY_WWAN_ENABLED];
    if (wwanEnabled) return wwanEnabled.boolValue;
    
    [AKSystemInfo setWWANEnabled:YES];
    return YES;
}

+ (void)setWWANEnabled:(BOOL)wwanEnabled
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    NSUserDefaults *userDefaults = [AKSystemInfo userDefaults];
    [userDefaults setBool:wwanEnabled forKey:USERDEFAULTS_KEY_WWAN_ENABLED];
    [userDefaults synchronize];
    [AKSystemInfo updateInternetStatus];
}

#pragma mark - // CATEGORY METHODS (PRIVATE) //

+ (id)sharedInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    static AKSystemInfo *sharedInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInfo = [[AKSystemInfo alloc] init];
    });
    return sharedInfo;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetStatusDidChange:) name:kReachabilityChangedNotification object:self.reachability];
    if ([self respondsToSelector:@selector(addObserversForAssetsLibraryCategory)]) [self performSelector:@selector(addObserversForAssetsLibraryCategory)];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:self.reachability];
    if ([self respondsToSelector:@selector(removeObserversForAssetsLibraryCategory)]) [self performSelector:@selector(removeObserversForAssetsLibraryCategory)];
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (Reachability *)reachability
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[AKSystemInfo sharedInfo] reachability];
}

+ (NSUserDefaults *)userDefaults
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[AKSystemInfo sharedInfo] userDefaults];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)internetStatusDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [AKSystemInfo updateInternetStatus];
}

#pragma mark - // PRIVATE METHODS (Helper) //

+ (void)updateInternetStatus
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    if ([AKSystemInfo isReachableViaWiFi]) [[AKSystemInfo sharedInfo] setCurrentStatus:AKConnectedViaWiFi];
    else if ([AKSystemInfo isReachableViaWWAN]) [[AKSystemInfo sharedInfo] setCurrentStatus:AKConnectedViaWWAN];
    else [[AKSystemInfo sharedInfo] setCurrentStatus:AKDisconnected];
}

@end