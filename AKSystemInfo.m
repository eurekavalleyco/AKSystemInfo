//
//  AKSystemInfo.m
//  AKSuperViewController
//
//  Created by Ken M. Haggerty on 11/11/13.
//  Copyright (c) 2013 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "AKSystemInfo.h"
#import "AKDebugger.h"

#pragma mark - // DEFINITIONS (Private) //

#define REACHABILITY_DOMAIN @"https://parse.com"

@interface AKSystemInfo ()
@end

@implementation AKSystemInfo

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

#pragma mark - // PUBLIC METHODS (iOS) //

+ (float)iOSVersion
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

#pragma mark - // PUBLIC METHODS (Device) //

+ (CGSize)screenSize
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [UIScreen mainScreen].bounds.size;
}

+ (BOOL)isPortrait
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    BOOL isPortrait = NO;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation == UIDeviceOrientationPortrait) || (orientation == UIDeviceOrientationPortraitUpsideDown)) isPortrait = YES;
    return isPortrait;
}

+ (BOOL)isLandscape
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    BOOL isLandscape = NO;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation == UIDeviceOrientationLandscapeLeft) || (orientation == UIDeviceOrientationLandscapeRight)) isLandscape = YES;
    return isLandscape;
}

+ (BOOL)isRetina
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    BOOL isRetina = NO;
    if ([UIScreen mainScreen].scale > 1.0) isRetina = YES;
    return isRetina;
}

#pragma mark - // PUBLIC METHODS (User Interface) //

+ (CGFloat)statusBarHeight
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (UIStatusBarStyle)statusBarStyle
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [UIApplication sharedApplication].statusBarStyle;
}

+ (void)setStatusBarStyle:(UIStatusBarStyle)style
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:style];
}

+ (void)setStatusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetter customCategories:nil message:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:animated];
}

+ (UIColor *)iOSBlue
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS //

@end