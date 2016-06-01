//
//  SystemInfo+Reachability.h
//  PushQuery
//
//  Created by Ken M. Haggerty on 5/25/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "SystemInfo.h"

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

typedef enum {
    AKInternetDisconnected,
    AKInternetConnectedViaWWAN,
    AKInternetConnectedViaWiFi,
    AKInternetStatusUnknown,
} AKInternetStatus;

extern NSString * const InternetStatusDidChangeNotification;
extern NSString * const PublicIPAddressDidChangeNotification;
extern NSString * const PrivateIPAddressDidChangeNotification;

@interface SystemInfo (Reachability) <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

// SETUP //

- (void)setupReachabilityWithPrivateInfo:(Class <PrivateInfo_Reachability>)privateInfo;

// GENERAL //

+ (AKInternetStatus)internetStatus;
+ (BOOL)isReachable;
+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)wifiEnabled;
+ (void)setWiFiEnabled:(BOOL)wifiEnabled;
+ (BOOL)wwanEnabled;
+ (void)setWWANEnabled:(BOOL)wwanEnabled;
+ (NSString *)publicIPAddress;
+ (NSString *)privateIPAddress;
+ (void)refreshInternetStatus;

// OBSERVERS //

- (void)addObserversToReachability;
- (void)removeObserversFromReachability;

@end
