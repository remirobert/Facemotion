//
//  OpenCVImageProcessing.h
//  FaceRecognition
//
//  Created by Remi Robert on 29/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/core/core.hpp>
#include <iostream>
#include <fstream>
#include <sstream>

@interface OpenCVImageProcessing : NSObject

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
