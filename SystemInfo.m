//
//  SystemInfo.m
//  SystemInfo
//
//  Created by Ken M. Haggerty on 11/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "SystemInfo+PRIVATE.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import "Reachability.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#pragma mark - // DEFINITIONS (Private) //

#define SEGUE_DURATION 0.18

#define USERDEFAULTS_KEY_WIFI_ENABLED @"wifiEnabled"
#define USERDEFAULTS_KEY_WWAN_ENABLED @"wwanEnabled"

#define PUBLIC_IPADDRESS_URL @"https://api.ipify.org?format=json"
#define PUBLIC_IPADDRESS_KEY @"ip"

#define INTERNET_MAX_ATTEMPTS_COUNT 2
#define INTERNET_MAX_ATTEMPTS_TIME 1.0f

@interface SystemInfo () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic) Class classForPrivateInfo;
@property (nonatomic) UIDeviceOrientation deviceOrientation;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic) AKInternetStatus currentStatus;
@property (nonatomic, strong) NSString *publicIpAddress;
@property (nonatomic, strong) NSMutableData *publicIpAddressData;
@property (nonatomic, strong) NSString *privateIpAddress;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

// GENERAL //

- (void)setup;
- (void)teardown;

// CONVENIENCE //

+ (Reachability *)reachability;
+ (NSUserDefaults *)userDefaults;

// RESPONDERS //

- (void)deviceOrientationDidChange:(NSNotification *)notification;
- (void)internetStatusDidChange:(NSNotification *)notification;

// HELPER //

+ (void)updateInternetStatus;
+ (void)fetchPublicIpAddress;
+ (void)fetchPrivateIpAddress;

@end

@implementation SystemInfo

#pragma mark - // SETTERS AND GETTERS //

@synthesize classForPrivateInfo = _classForPrivateInfo;
@synthesize deviceOrientation = _deviceOrientation;
@synthesize reachability = _reachability;
@synthesize currentStatus = _currentStatus;
@synthesize publicIpAddress = _publicIpAddress;
@synthesize publicIpAddressData = _publicIpAddressData;
@synthesize privateIpAddress = _privateIpAddress;
@synthesize userDefaults = _userDefaults;

- (void)setClassForPrivateInfo:(Class <PrivateInfo>)classForPrivateInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    _classForPrivateInfo = classForPrivateInfo;
    [self setReachability:[Reachability reachabilityWithHostname:[classForPrivateInfo reachabilityDomain]]];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    if (deviceOrientation == _deviceOrientation) return;
    
    _deviceOrientation = deviceOrientation;
    
    [AKGenerics postNotificationName:NOTIFICATION_DEVICE_ORIENTATION_DID_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:deviceOrientation] forKey:NOTIFICATION_OBJECT_KEY]];
}

- (void)setReachability:(Reachability *)reachability
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    if ([AKGenerics object:reachability isEqualToObject:_reachability]) return;
    
    _reachability = reachability;
    [_reachability startNotifier];
}

- (Reachability *)reachability
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (_reachability) return _reachability;
    
    if (!self.classForPrivateInfo) return nil;
    
    [self setReachability:[Reachability reachabilityWithHostname:[self.classForPrivateInfo reachabilityDomain]]];
    return _reachability;
}

- (void)setCurrentStatus:(AKInternetStatus)currentStatus
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    if (currentStatus == _currentStatus) return;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInteger:currentStatus] forKey:NOTIFICATION_OBJECT_KEY];
    [userInfo setObject:[NSNumber numberWithInteger:_currentStatus] forKey:NOTIFICATION_OLD_KEY];
    
    _currentStatus = currentStatus;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNETSTATUS_DID_CHANGE object:nil userInfo:userInfo];
}

- (void)setPublicIpAddress:(NSString *)publicIpAddress
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    if ([AKGenerics object:publicIpAddress isEqualToObject:_publicIpAddress]) return;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (_publicIpAddress) [userInfo setObject:_publicIpAddress forKey:NOTIFICATION_OLD_KEY];
    
    _publicIpAddress = publicIpAddress;
    
    if (publicIpAddress) [userInfo setObject:publicIpAddress forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:NOTIFICATION_PUBLIC_IPADDRESS_DID_CHANGE object:nil userInfo:userInfo];
}

- (void)setPrivateIpAddress:(NSString *)privateIpAddress
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    if ([AKGenerics object:privateIpAddress isEqualToObject:_privateIpAddress]) return;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (_privateIpAddress) [userInfo setObject:_privateIpAddress forKey:NOTIFICATION_OLD_KEY];
    
    _privateIpAddress = privateIpAddress;
    
    if (privateIpAddress) [userInfo setObject:privateIpAddress forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:NOTIFICATION_PRIVATE_IPADDRESS_DID_CHANGE object:nil userInfo:userInfo];
}

- (NSUserDefaults *)userDefaults
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (_userDefaults) return _userDefaults;
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
}

#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    self = [super init];
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (Setup) //

+ (void)setupWithPrivateInfo:(Class)classForPrivateInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    if (!classForPrivateInfo)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeSetup tags:nil message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(classForPrivateInfo)]];
    }
    
    [[SystemInfo sharedInfo] setClassForPrivateInfo:classForPrivateInfo];
}

#pragma mark - // PUBLIC METHODS (General) //

+ (NSUUID *)deviceId
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[UIDevice currentDevice] identifierForVendor];
}

#pragma mark - // PUBLIC METHODS (Hardware) //

+ (CGSize)screenSize
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return [UIScreen mainScreen].bounds.size;
}

+ (BOOL)isPortrait
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return UIDeviceOrientationIsPortrait([[SystemInfo sharedInfo] deviceOrientation]);
}

+ (BOOL)isLandscape
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return UIDeviceOrientationIsLandscape([[SystemInfo sharedInfo] deviceOrientation]);
}

+ (BOOL)isRetina
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    if ([UIScreen mainScreen].scale > 1.0) return YES;
    else return NO;
}

#pragma mark - // PUBLIC METHODS (Software) //

+ (NSString *)bundleIdentifier
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)appName
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[[NSBundle mainBundle] infoDictionary]  objectForKey:(id)kCFBundleNameKey];
}

+ (float)iOSVersion
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (CGFloat)statusBarHeight
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (UIStatusBarStyle)statusBarStyle
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return [UIApplication sharedApplication].statusBarStyle;
}

+ (void)setStatusBarStyle:(UIStatusBarStyle)style
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:style];
}

+ (void)setStatusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:animated];
}

+ (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_UI] message:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
}

+ (UIColor *)iOSBlue
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

+ (BOOL)viewIsUsingAutoLayout:(UIView *)view
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_UI] message:nil];
    
//    if (view.translatesAutoresizingMaskIntoConstraints) return YES;
    if (view.constraints.count) return YES;
    else return NO;
}

#pragma mark - // PUBLIC METHODS (Internet) //

+ (AKInternetStatus)internetStatus
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] currentStatus];
}

+ (BOOL)isReachable
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return ([SystemInfo isReachableViaWiFi] || [SystemInfo isReachableViaWWAN]);
}

+ (BOOL)isReachableViaWiFi
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (![SystemInfo wifiEnabled]) return NO;
    
    int attempt = 0;
    BOOL isReachable;
    NSDate *startDate = [NSDate date];
    do {
        isReachable = [[[SystemInfo sharedInfo] reachability] isReachableViaWiFi];
    } while (!isReachable && (!INTERNET_MAX_ATTEMPTS_COUNT || (++attempt < INTERNET_MAX_ATTEMPTS_COUNT)) && (!INTERNET_MAX_ATTEMPTS_TIME || ([[NSDate date] timeIntervalSinceDate:startDate] < INTERNET_MAX_ATTEMPTS_TIME)));
    if (isReachable)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"Found Internet connection after %i attempts.", ++attempt]];
    }
    else
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"No Internet connection detected after %i attempts.", ++attempt]];
    }
    return isReachable;
}

+ (BOOL)isReachableViaWWAN
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (![SystemInfo wwanEnabled]) return NO;
    
    int attempt = 0;
    BOOL isReachable;
    NSDate *startDate = [NSDate date];
    do {
        isReachable = [[[SystemInfo sharedInfo] reachability] isReachableViaWWAN];
    } while (!isReachable && (!INTERNET_MAX_ATTEMPTS_COUNT || (++attempt < INTERNET_MAX_ATTEMPTS_COUNT)) && (!INTERNET_MAX_ATTEMPTS_TIME || ([[NSDate date] timeIntervalSinceDate:startDate] < INTERNET_MAX_ATTEMPTS_TIME)));
    if (isReachable)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"Found Internet connection after %i attempts.", ++attempt]];
    }
    else
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"No Internet connection detected after %i attempts.", ++attempt]];
    }
    return isReachable;
}

+ (BOOL)wifiEnabled
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    NSUserDefaults *userDefaults = [SystemInfo userDefaults];
    NSNumber *wifiEnabled = [userDefaults objectForKey:USERDEFAULTS_KEY_WIFI_ENABLED];
    if (wifiEnabled) return wifiEnabled.boolValue;
    
    [SystemInfo setWiFiEnabled:YES];
    return YES;
}

+ (void)setWiFiEnabled:(BOOL)wifiEnabled
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    NSUserDefaults *userDefaults = [SystemInfo userDefaults];
    [userDefaults setBool:wifiEnabled forKey:USERDEFAULTS_KEY_WIFI_ENABLED];
    [userDefaults synchronize];
    [SystemInfo updateInternetStatus];
}

+ (BOOL)wwanEnabled
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    NSUserDefaults *userDefaults = [SystemInfo userDefaults];
    NSNumber *wwanEnabled = [userDefaults objectForKey:USERDEFAULTS_KEY_WWAN_ENABLED];
    if (wwanEnabled) return wwanEnabled.boolValue;
    
    [SystemInfo setWWANEnabled:YES];
    return YES;
}

+ (void)setWWANEnabled:(BOOL)wwanEnabled
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    NSUserDefaults *userDefaults = [SystemInfo userDefaults];
    [userDefaults setBool:wwanEnabled forKey:USERDEFAULTS_KEY_WWAN_ENABLED];
    [userDefaults synchronize];
    [SystemInfo updateInternetStatus];
}

+ (NSString *)publicIpAddress
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] publicIpAddress];
}

+ (NSString *)privateIpAddress
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] privateIpAddress];
}

+ (void)refreshInternetStatus
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [SystemInfo updateInternetStatus];
    [SystemInfo fetchPublicIpAddress];
    [SystemInfo fetchPrivateIpAddress];
}

#pragma mark - // DELEGATED METHODS (NSURLConnectionDelegate) //

#pragma mark - // DELEGATED METHODS (NSURLConnectionDataDelegate) //

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [self setPublicIpAddressData:[[NSMutableData alloc] init]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    [self.publicIpAddressData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:self.publicIpAddressData options:0 error:&error];
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified tags:nil message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    [self setPublicIpAddress:[jsonObject objectForKey:PUBLIC_IPADDRESS_KEY]];
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

+ (id)sharedInfo
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    static SystemInfo *sharedInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInfo = [[SystemInfo alloc] init];
    });
    return sharedInfo;
}

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetStatusDidChange:) name:kReachabilityChangedNotification object:self.reachability];
    if ([self respondsToSelector:@selector(addObserversForAssetsLibraryCategory)]) [self performSelector:@selector(addObserversForAssetsLibraryCategory)];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:self.reachability];
    if ([self respondsToSelector:@selector(removeObserversForAssetsLibraryCategory)]) [self performSelector:@selector(removeObserversForAssetsLibraryCategory)];
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (Reachability *)reachability
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] reachability];
}

+ (NSUserDefaults *)userDefaults
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] userDefaults];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [self setDeviceOrientation:[[UIDevice currentDevice] orientation]];
}

- (void)internetStatusDidChange:(NSNotification *)notification
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [SystemInfo refreshInternetStatus];
}

#pragma mark - // PRIVATE METHODS (Helper) //

+ (void)updateInternetStatus
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    if ([SystemInfo isReachableViaWiFi]) [[SystemInfo sharedInfo] setCurrentStatus:AKConnectedViaWiFi];
    else if ([SystemInfo isReachableViaWWAN]) [[SystemInfo sharedInfo] setCurrentStatus:AKConnectedViaWWAN];
    else [[SystemInfo sharedInfo] setCurrentStatus:AKDisconnected];
}

+ (void)fetchPublicIpAddress
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (![SystemInfo isReachable]) return;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:PUBLIC_IPADDRESS_URL]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:[SystemInfo sharedInfo]];
    [connection start];
}

+ (void)fetchPrivateIpAddress
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (![SystemInfo isReachable]) return;
    
    NSString *ipAddress = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL)
        {
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    [[SystemInfo sharedInfo] setPrivateIpAddress:ipAddress];
}

@end
