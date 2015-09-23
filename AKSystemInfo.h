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
@import AssetsLibrary;

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

typedef enum {
    AKDisconnected = 0,
    AKConnectedViaWWAN = 1,
    AKConnectedViaWiFi = 2
} AKInternetStatus;

#define NOTIFICATION_INTERNETSTATUS_DID_CHANGE @"kNotificationInternetStatusDidChange"
#define NOTIFICATION_ASSETSLIBRARY_DID_CHANGE @"kNotificationAssetsLibraryDidChange"

@interface AKSystemInfo : NSObject

// HARDWARE //

+ (CGSize)screenSize;
+ (BOOL)isPortrait;
+ (BOOL)isLandscape;
+ (BOOL)isRetina;

// SOFTWARE //

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

// DATA //

+ (void)getLastPhotoThumbnailFromCameraRollWithCompletion:(void (^)(UIImage *))completion;
+ (ALAssetsLibrary *)assetsLibrary;

@end