//
//  OrientationDevice.m
//  FaceRecognition
//
//  Created by Remi Robert on 02/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "OrientationDevice.h"

@implementation OrientationDevice

+ (NSNumber *)exifOrientation {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    int exifOrientation;
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1,
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2,
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3,
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4,
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5,
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6,
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7,
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8
    };
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
            
        case UIDeviceOrientationPortrait:
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    return [NSNumber numberWithInt:exifOrientation];
}

@end
