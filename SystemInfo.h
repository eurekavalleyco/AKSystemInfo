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
@end

@protocol PrivateInfo_Reachability <NSObject>
+ (NSString *)reachabilityDomain;
@end

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_DEVICE_ORIENTATION_DID_CHANGE @"kNotificationDeviceOrientationDidChange"

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
+ (BOOL)forceTouchEnabledForViewController:(UIViewController *)viewController;

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

@end

@interface SystemInfo (PRIVATE)
+ (id)sharedInfo;
+ (Class)privateInfo;
@end
