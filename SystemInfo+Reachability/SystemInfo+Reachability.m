//
//  SystemInfo+Reachability.m
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/25/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "SystemInfo+Reachability.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import <objc/runtime.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

#import "Reachability.h"

#pragma mark - // DEFINITIONS (Private) //

NSString * const InternetStatusDidChangeNotification = @"kNotificationSystemInfo_InternetStatusDidChange";
NSString * const PublicIPAddressDidChangeNotification = @"kNotificationSystemInfo_PublicIPAddressDidChange";
NSString * const PrivateIPAddressDidChangeNotification = @"kNotificationSystemInfo_PrivateIPAddressDidChange";

NSString * const NSUserDefaultsWiFiEnabledKey = @"wifiEnabled";
NSString * const NSUserDefaultsWWANEnabledKey = @"wwanEnabled";

NSString * const PublicIPAddressURL = @"https://api.ipify.org?format=json";
NSString * const PublicIPAddressKey = @"ip";

<#Class#> * const <#Key#> = <#value#>;

#define INTERNET_MAX_ATTEMPTS_COUNT 2
#define INTERNET_MAX_ATTEMPTS_TIME 1.0f

@implementation SystemInfo (Reachability)

#pragma mark - // SETTERS AND GETTERS //

- (void)setUserDefaults:(NSUserDefaults *)userDefaults {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    objc_setAssociatedObject(self, @selector(userDefaults), userDefaults, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUserDefaults *)userDefaults {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    NSUserDefaults *userDefaults = objc_getAssociatedObject(self, @selector(userDefaults));
    
    if (userDefaults) {
        return userDefaults;
    }
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    return self.userDefaults;
}

- (void)setReachability:(Reachability *)reachability {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    Reachability *primitiveReachability = self.reachability;
    
    if ([AKGenerics object:reachability isEqualToObject:primitiveReachability]) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(reachability), reachability, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [reachability startNotifier];
}

- (Reachability *)reachability {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    Reachability *reachability = objc_getAssociatedObject(self, @selector(reachability));
    
    if (reachability) {
        return reachability;
    }
    
    if (![SystemInfo privateInfo] || ![[SystemInfo privateInfo] respondsToSelector:(@selector(reachabilityDomain))]) {
        return nil;
    }
    
    self.reachability = [Reachability reachabilityWithHostname:[[SystemInfo privateInfo] reachabilityDomain]];
    
    return self.reachability;
}

- (void)setPublicIPAddress:(NSString *)publicIPAddress {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    NSString *primitivePublicIPAddress = self.publicIPAddress;
    
    if ([AKGenerics object:publicIPAddress isEqualToObject:primitivePublicIPAddress]) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(publicIPAddress), publicIPAddress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:publicIPAddress forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:PublicIPAddressDidChangeNotification object:nil userInfo:userInfo];
}

- (NSString *)publicIPAddress {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    return objc_getAssociatedObject(self, @selector(publicIPAddress));
}

- (void)setPublicIPAddressData:(NSMutableData *)publicIPAddressData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    objc_setAssociatedObject(self, @selector(publicIPAddressData), publicIPAddressData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableData *)publicIPAddressData {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    return objc_getAssociatedObject(self, @selector(publicIPAddressData));
}

- (void)setPrivateIPAddress:(NSString *)privateIPAddress {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    NSString *primitivePrivateIPAddress = self.privateIPAddress;
    
    if ([AKGenerics object:privateIPAddress isEqualToObject:primitivePrivateIPAddress]) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(privateIPAddress), privateIPAddress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithNullableObject:privateIPAddress forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:PrivateIPAddressDidChangeNotification object:nil userInfo:userInfo];
}

- (NSString *)privateIPAddress {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    return objc_getAssociatedObject(self, @selector(privateIPAddress));
}

- (void)setInternetStatus:(AKInternetStatus)internetStatus {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    AKInternetStatus primitiveInternetStatus = self.internetStatus;
    
    if (internetStatus == primitiveInternetStatus) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(internetStatus), [NSNumber numberWithInteger:internetStatus], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:internetStatus] forKey:NOTIFICATION_OBJECT_KEY];
    [AKGenerics postNotificationName:InternetStatusDidChangeNotification object:nil userInfo:userInfo];
}

- (AKInternetStatus)internetStatus {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    NSNumber *internetStatusValue = objc_getAssociatedObject(self, @selector(internetStatus));
    return internetStatusValue ? internetStatusValue.integerValue : AKInternetStatusUnknown;
}

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (Setup) //

- (void)setupReachabilityWithPrivateInfo:(Class<PrivateInfo_Reachability>)privateInfo {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:nil message:nil];
    
    self.reachability = [Reachability reachabilityWithHostname:[privateInfo reachabilityDomain]];
}

#pragma mark - // PUBLIC METHODS (General) //

+ (AKInternetStatus)internetStatus {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] internetStatus];
}

+ (BOOL)isReachable {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return ([SystemInfo isReachableViaWiFi] || [SystemInfo isReachableViaWWAN]);
}

+ (BOOL)isReachableViaWiFi {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (![SystemInfo wifiEnabled]) {
        return NO;
    }
    
    int attempt = 0;
    BOOL isReachable;
    NSDate *startDate = [NSDate date];
    do {
        isReachable = [[[SystemInfo sharedInfo] reachability] isReachableViaWiFi];
    } while (!isReachable && (!INTERNET_MAX_ATTEMPTS_COUNT || (++attempt < INTERNET_MAX_ATTEMPTS_COUNT)) && (!INTERNET_MAX_ATTEMPTS_TIME || ([[NSDate date] timeIntervalSinceDate:startDate] < INTERNET_MAX_ATTEMPTS_TIME)));
    if (isReachable) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"Found Internet connection after %i attempts.", ++attempt]];
    }
    else {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"No Internet connection detected after %i attempts.", ++attempt]];
    }
    return isReachable;
}

+ (BOOL)isReachableViaWWAN {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (![SystemInfo wwanEnabled]) {
        return NO;
    }
    
    int attempt = 0;
    BOOL isReachable;
    NSDate *startDate = [NSDate date];
    do {
        isReachable = [[[SystemInfo sharedInfo] reachability] isReachableViaWWAN];
    } while (!isReachable && (!INTERNET_MAX_ATTEMPTS_COUNT || (++attempt < INTERNET_MAX_ATTEMPTS_COUNT)) && (!INTERNET_MAX_ATTEMPTS_TIME || ([[NSDate date] timeIntervalSinceDate:startDate] < INTERNET_MAX_ATTEMPTS_TIME)));
    if (isReachable) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"Found Internet connection after %i attempts.", ++attempt]];
    }
    else {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeGetter tags:nil message:[NSString stringWithFormat:@"No Internet connection detected after %i attempts.", ++attempt]];
    }
    return isReachable;
}

+ (BOOL)wifiEnabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    NSUserDefaults *userDefaults = [SystemInfo userDefaults];
    NSNumber *wifiEnabled = [userDefaults objectForKey:USERDEFAULTS_KEY_WIFI_ENABLED];
    if (wifiEnabled) {
        return wifiEnabled.boolValue;
    }
    
    [SystemInfo setWiFiEnabled:YES];
    return YES;
}

+ (void)setWiFiEnabled:(BOOL)wifiEnabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    NSUserDefaults *userDefaults = [SystemInfo userDefaults];
    [userDefaults setBool:wifiEnabled forKey:USERDEFAULTS_KEY_WIFI_ENABLED];
    [userDefaults synchronize];
    [SystemInfo updateInternetStatus];
}

+ (BOOL)wwanEnabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    NSUserDefaults *userDefaults = [SystemInfo userDefaults];
    NSNumber *wwanEnabled = [userDefaults objectForKey:USERDEFAULTS_KEY_WWAN_ENABLED];
    if (wwanEnabled) {
        return wwanEnabled.boolValue;
    }
    
    [SystemInfo setWWANEnabled:YES];
    return YES;
}

+ (void)setWWANEnabled:(BOOL)wwanEnabled {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:nil message:nil];
    
    NSUserDefaults *userDefaults = [SystemInfo userDefaults];
    [userDefaults setBool:wwanEnabled forKey:USERDEFAULTS_KEY_WWAN_ENABLED];
    [userDefaults synchronize];
    [SystemInfo updateInternetStatus];
}

+ (NSString *)publicIPAddress {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] publicIPAddress];
}

+ (NSString *)privateIPAddress {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] privateIPAddress];
}

+ (void)refreshInternetStatus {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    [SystemInfo updateInternetStatus];
    [SystemInfo fetchPublicIPAddress];
    [SystemInfo fetchPrivateIPAddress];
}

#pragma mark - // PUBLIC METHODS (Observers) //

- (void)addObserversToReachability {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CONNECTIVITY, AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetStatusDidChange:) name:kReachabilityChangedNotification object:self.reachability];
}

- (void)removeObserversFromReachability {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup tags:@[AKD_CONNECTIVITY, AKD_NOTIFICATION_CENTER] message:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:self.reachability];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS (NSURLConnectionDelegate) //

#pragma mark - // DELEGATED METHODS (NSURLConnectionDataDelegate) //

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    self.publicIPAddressData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    [self.publicIPAddressData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:nil message:nil];
    
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:self.publicIPAddressData options:0 error:&error];
    if (error) {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified tags:nil message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    self.publicIPAddress = jsonObject[PUBLIC_IPADDRESS_KEY];
}

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (NSUserDefaults *)userDefaults {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    return [[SystemInfo sharedInfo] userDefaults];
}

+ (Reachability *)reachability {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    return [[SystemInfo sharedInfo] reachability];
}

+ (void)setInternetStatus:(AKInternetStatus)internetStatus {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter tags:@[AKD_CONNECTIVITY] message:nil];
    
    [[SystemInfo sharedInfo] setInternetStatus:internetStatus];
}

#pragma mark - // PRIVATE METHODS (Responders) //

- (void)internetStatusDidChange:(NSNotification *)notification {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    [SystemInfo refreshInternetStatus];
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (void)updateInternetStatus {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified tags:@[AKD_NOTIFICATION_CENTER] message:nil];
    
    if ([SystemInfo isReachableViaWiFi]) {
        [SystemInfo setInternetStatus:AKInternetConnectedViaWiFi];
    }
    else if ([SystemInfo isReachableViaWWAN]) {
        [SystemInfo setInternetStatus:AKInternetConnectedViaWWAN];
    }
    else {
        [SystemInfo setInternetStatus:AKInternetDisconnected];
    }
}

+ (void)fetchPublicIPAddress {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (![SystemInfo isReachable]) {
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:PUBLIC_IPADDRESS_URL]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:[SystemInfo sharedInfo]];
    [connection start];
}

// SOURCE: http://stackoverflow.com/questions/15693556/how-to-get-the-cellular-ip-address-in-ios-app
+ (void)fetchPrivateIPAddress {
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter tags:nil message:nil];
    
    if (![SystemInfo isReachable]) {
        return;
    }
    
    NSString *privateIPAddress = @"error";
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
                    privateIPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    [[SystemInfo sharedInfo] setPrivateIPAddress:privateIPAddress];
}

@end
