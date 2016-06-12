//
//  OpenCVImageProcessing.m
//  FaceRecognition
//
//  Created by Remi Robert on 29/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "OpenCVImageProcessing.h"

@implementation OpenCVImageProcessing

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols,rows;
    if (image.imageOrientation == UIImageOrientationLeft
         || image.imageOrientation == UIImageOrientationRight) {
        cols = image.size.height;
        rows = image.size.width;
    }
    else {
        cols = image.size.width;
        rows = image.size.height;
    }
    cv::Mat cvMat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    
    cv::Mat cvMatTest;
    cv::transpose(cvMat, cvMatTest);
    
    if  (image.imageOrientation == UIImageOrientationLeft
         || image.imageOrientation == UIImageOrientationRight) {
    }
    else{
        return cvMat;
        
    }
    cvMat.release();
//    cv::flip(cvMatTest, cvMatTest, 1);
    return cvMatTest;
}

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image {
    cv::Mat cvMat = [self cvMatFromUIImage:image];
    cv::Mat grayMat;
    if (cvMat.channels() == 1) {
        grayMat = cvMat;
    }
    else {
        grayMat = cv::Mat(cvMat.rows,cvMat.cols, CV_8UC1);
        cv::cvtColor(cvMat, grayMat, CV_BGR2GRAY);
    }
    return grayMat;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(cvMat.cols,
                                        cvMat.rows,
                                        8,
                                        8 * cvMat.elemSize(),
                                        cvMat.step[0],
                                        colorSpace,
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
