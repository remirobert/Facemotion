
//
//  FaceRecognition.m
//  FaceRecognition
//
//  Created by Remi Robert on 30/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <sstream>
#import "FaceRecognition.h"

@interface FaceRecognition ()
@property (nonatomic, assign) cv::Ptr<cv::FaceRecognizer> recognizer;
@end

@implementation FaceRecognition

+ (FaceRecognition *)sharedInstance {
    static FaceRecognition *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [FaceRecognition new];
        instance.recognizer = cv::createEigenFaceRecognizer();
    });
    return instance;
}

+ (int)trainingImages:(std::vector<cv::Mat>)images labels:(std::vector<int>)labels sample:(cv::Mat)frame {
    FaceRecognition *instance = [self sharedInstance];
    instance.recognizer->train(images, labels);
    return instance.recognizer->predict(frame);
}

+ (BOOL)trainingFace:(NSArray<Face *> *)faces withFace:(Face *)face {
    std::vector<cv::Mat> images;
    std::vector<int> labels;

    for (Face *currentFace in faces) {
        images.push_back(currentFace.face);
        labels.push_back(currentFace.label);
    }
    return [self trainingImages:images labels:labels sample:face.face] == face.label;
}

@end
