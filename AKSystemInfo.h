//
//  AKSystemInfo.h
//  AKSystemInfo
//
//  Created by Ken M. Haggerty on 11/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_INTERNETSTATUS_DID_CHANGE @"kNotificationInternetStatusDidChange"

typedef enum {
    AKDisconnected = 0,
    AKConnectedViaWWAN,
    AKConnectedViaWiFi
} AKInternetStatus;

@interface AKSystemInfo : NSObject
+ (float)iOSVersion;
+ (CGSize)screenSize;
+ (BOOL)isPortrait;
+ (BOOL)isLandscape;
+ (BOOL)isRetina;
+ (CGFloat)statusBarHeight;
+ (UIStatusBarStyle)statusBarStyle;
+ (void)setStatusBarStyle:(UIStatusBarStyle)style;
+ (void)setStatusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated;
+ (UIColor *)iOSBlue;
+ (BOOL)viewIsUsingAutoLayout:(UIView *)view;
+ (BOOL)isReachable;
+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaWWAN;
@end