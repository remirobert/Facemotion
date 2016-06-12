
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
#import "FaceContact.h"
#import "FaceRecognition.h"
#import "OpenCVImageProcessing.h"

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

+ (std::string)trainingImages:(std::vector<cv::Mat>)images labels:(std::vector<std::string>)labels sample:(cv::Mat)frame {
    FaceRecognition *instance = [self sharedInstance];
    std::string predicted_label;
    double predicted_confidence = 0.0;
    
    instance.recognizer->train(images, labels);
    predicted_label = instance.recognizer->predict(frame);
//    NSLog(@"number train faces: %d", images.size());
//    NSLog(@"ret label training : %d", predicted_label);
//    NSLog(@"ret confidence training : %f", predicted_confidence);
//    if (predicted_confidence == 0 && images.size() == 0) {
//        return -1;
//    }
    
    NSLog(@"label predicted : %s", predicted_label.c_str());
    return predicted_label;
//    return (predicted_confidence < 500) ? -1 : predicted_label;
}

+ (NSString *)recognitionFace:(NSArray<FaceContact *> *)faces face:(UIImage *)image {
    std::vector<cv::Mat> images;
    std::vector<std::string> labels;
    
    cv::Mat frame = [OpenCVImageProcessing cvMatFromUIImage:image];
    
    for (FaceContact *face in faces) {
        images.push_back([OpenCVImageProcessing cvMatFromUIImage:[UIImage imageWithData:face.imageData]]);
        labels.push_back([face.id UTF8String]);
    }
    [self trainingImages:images labels:labels sample:frame];
    return @"o";
}

//+ (BOOL)trainingFace:(NSArray<Face *> *)faces withFace:(Face *)face {
//    std::vector<cv::Mat> images;
//    std::vector<int> labels;
//    NSMutableArray<NSNumber *> *labelsTest = [NSMutableArray new];
//
//    NSLog(@"   🍿 test face label : %d", face.label);
//    for (Face *currentFace in faces) {
//        NSLog(@"add current label to training : %d", currentFace.label);
//        images.push_back(currentFace.face);
//        labels.push_back(currentFace.label);
//        [labelsTest addObject:@(currentFace.label)];
//    }
////    return [labelsTest containsObject:@([self trainingImages:images labels:labels sample:face.face])];
//}

@end
