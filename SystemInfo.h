//
//  SystemInfo.h
//  SystemInfo
//
//  Created by Ken M. Haggerty on 11/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

@protocol PrivateInfo <NSObject>
+ (NSString *)reachabilityDomain;
@end

#pragma mark - // DEFINITIONS (Public) //

typedef enum {
    AKDisconnected = 0,
    AKConnectedViaWWAN = 1,
    AKConnectedViaWiFi = 2
} AKInternetStatus;

#define NOTIFICATION_INTERNETSTATUS_DID_CHANGE @"kNotificationInternetStatusDidChange"
#define NOTIFICATION_PUBLIC_IPADDRESS_DID_CHANGE @"kNotificationPublicIPAddressDidChange"
#define NOTIFICATION_PRIVATE_IPADDRESS_DID_CHANGE @"kNotificationPrivateIPAddressDidChange"

@interface SystemInfo : NSObject

// SETUP //

+ (void)setupWithPrivateInfo:(Class <PrivateInfo>)classForPrivateInfo;

// GENERAL //

+ (NSUUID *)deviceId;

// HARDWARE //

+ (CGSize)screenSize;
+ (BOOL)isPortrait;
+ (BOOL)isLandscape;
+ (BOOL)isRetina;

// SOFTWARE //

+ (NSString *)bundleIdentifier;
+ (NSString *)appName;
+ (float)iOSVersion;
+ (CGFloat)statusBarHeight;
+ (UIStatusBarStyle)statusBarStyle;
+ (void)setStatusBarStyle:(UIStatusBarStyle)style;
+ (void)setStatusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated;
+ (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation;
+ (UIColor *)iOSBlue;
+ (BOOL)viewIsUsingAutoLayout:(UIView *)view;

// INTERNET //

+ (AKInternetStatus)internetStatus;
+ (BOOL)isReachable;
+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)wifiEnabled;
+ (void)setWiFiEnabled:(BOOL)wifiEnabled;
+ (BOOL)wwanEnabled;
+ (void)setWWANEnabled:(BOOL)wwanEnabled;
+ (NSString *)publicIpAddress;
+ (NSString *)privateIpAddress;
+ (void)refreshInternetStatus;

@end