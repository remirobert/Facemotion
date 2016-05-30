//
//  Face.m
//  FaceRecognition
//
//  Created by Remi Robert on 30/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "Face.h"
#import "OpenCVImageProcessing.h"

@implementation Face

- (instancetype)init:(cv::Mat)face {
    self = [super init];
    
    if (self) {
        self.face = face;
        self.faceImage = [OpenCVImageProcessing UIImageFromCVMat:face];
        self.label = [[NSDate new] timeIntervalSince1970];
    }
    return self;
}

@end
