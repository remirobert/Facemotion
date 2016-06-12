
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

+ (int)trainingImages:(std::vector<cv::Mat>)images labels:(std::vector<int>)labels sample:(cv::Mat)frame {
    FaceRecognition *instance = [self sharedInstance];
    int predicted_label;
    double predicted_confidence = 0.0;
    
    instance.recognizer->train(images, labels);
    predicted_label = instance.recognizer->predict(frame);
//    NSLog(@"number train faces: %d", images.size());
//    NSLog(@"ret label training : %d", predicted_label);
//    NSLog(@"ret confidence training : %f", predicted_confidence);
//    if (predicted_confidence == 0 && images.size() == 0) {
//        return -1;
//    }
    
    NSLog(@"label predicted : %d", predicted_label);
    return predicted_label;
//    return (predicted_confidence < 500) ? -1 : predicted_label;
}

+ (NSString *)recognitionFace:(NSArray<FaceContact *> *)faces face:(UIImage *)image {
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    cv::Mat frame = [OpenCVImageProcessing cvMatFromUIImage:image];
    
    for (FaceContact *face in faces) {
        UIImage *currentImage = [UIImage imageWithData:face.imageData];
        cv::Mat currentFrame = [OpenCVImageProcessing cvMatFromUIImage:currentImage];
        cv::Mat grayFrame;
        cv::cvtColor(currentFrame, grayFrame, CV_BGR2GRAY);
        images.push_back(grayFrame);
        labels.push_back((int)face.idRecognition);
    }
    cv::Mat grayFrame;
    cv::cvtColor(frame, grayFrame, CV_BGR2GRAY);
    [self trainingImages:images labels:labels sample:grayFrame];
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
