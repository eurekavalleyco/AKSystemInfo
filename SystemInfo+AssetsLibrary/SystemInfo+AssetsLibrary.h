//
//  SystemInfo+AssetsLibrary.h
//  SystemInfo
//
//  Created by Ken M. Haggerty on 9/25/15.
//  Copyright (c) 2015 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "SystemInfo.h"
#import <AssetsLibrary/AssetsLibrary.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

#define NOTIFICATION_ASSETSLIBRARY_DID_CHANGE @"kNotificationAssetsLibraryDidChange"

@interface SystemInfo (AssetsLibrary)
+ (ALAssetsLibrary *)assetsLibrary;
+ (void)getLastPhotoThumbnailFromCameraRollWithCompletion:(void (^)(UIImage *))completion;
@end
