//
//  AKSystemInfo.h
//  AKSuperViewController
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

@interface AKSystemInfo : NSObject

// IOS //

+ (float)iOSVersion;

// DEVICE //

+ (CGSize)screenSize;
+ (BOOL)isPortrait;
+ (BOOL)isLandscape;
+ (BOOL)isRetina;

// USER INTERFACE //

+ (CGFloat)statusBarHeight;
+ (UIStatusBarStyle)statusBarStyle;
+ (void)setStatusBarStyle:(UIStatusBarStyle)style;
+ (void)setStatusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated;
+ (UIColor *)iOSBlue;

@end