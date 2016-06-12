//
//  FaceRecognition.h
//  FaceRecognition
//
//  Created by Remi Robert on 30/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/core/core.hpp>
#import "Face.h"
#import "FaceContact.h"

@interface FaceRecognition : NSObject
+ (BOOL)trainingFace:(NSArray<Face *> *)faces withFace:(Face *)face;
+ (NSString *)recognitionFace:(NSArray<FaceContact *> *)faces face:(UIImage *)image;
@end
