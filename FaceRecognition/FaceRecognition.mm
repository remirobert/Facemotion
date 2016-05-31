
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
    int ret = instance.recognizer->predict(frame);
    NSLog(@"ret training : %d", ret);
    return ret;
}

+ (BOOL)trainingFace:(NSArray<Face *> *)faces withFace:(Face *)face {
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    NSMutableArray<NSNumber *> *labelsTest = [NSMutableArray new];
    
    NSLog(@"size image training : %d %d", faces.firstObject.face.size[0], faces.firstObject.face.size[1]);
    NSLog(@"size image test : %d %d", face.face.size[0], face.face.size[1]);

    for (Face *currentFace in faces) {
        NSLog(@"add current label to training : %d", currentFace.label);
        images.push_back(currentFace.face);
        labels.push_back(currentFace.label);
        [labelsTest addObject:@(currentFace.label)];
    }
    return [labelsTest containsObject:@([self trainingImages:images labels:labels sample:face.face])];
//    return [self trainingImages:images labels:labels sample:face.face] == face.label;
}

@end
