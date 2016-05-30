//
//  FaceDetector.h
//  FaceRecognition
//
//  Created by Remi Robert on 30/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import <opencv2/core/core.hpp>
#import "Face.h"

@interface FaceDetector : NSObject
@property (nonatomic, assign) cv::CascadeClassifier face_cascade;

+ (NSArray<Face *> *)detectFace:(cv::Mat)frame;
@end
