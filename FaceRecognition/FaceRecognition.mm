
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

+ (RecognitionResult *)trainingImages:(std::vector<cv::Mat>)images labels:(std::vector<int>)labels sample:(cv::Mat)frame {
    FaceRecognition *instance = [self sharedInstance];
    int predicted_label;
    double predicted_confidence = 0.0;
    
    instance.recognizer->train(images, labels);
    instance.recognizer->predict(frame, predicted_label, predicted_confidence);
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"idRecognition = %d", predicted_label];
    RLMResults<FaceContact *> *facesContact = [FaceContact objectsWithPredicate:pred];
    
    if (facesContact.count > 0) {
        FaceContact *contact = [facesContact objectAtIndex:0];
        RecognitionResult *result = [RecognitionResult new];
        result.contact = contact;
        result.confidence = predicted_confidence;
        return result;
    }
    return nil;
}

+ (RecognitionResult *)recognitionFace:(NSArray<FaceContact *> *)faces face:(UIImage *)image {
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    if (faces.count == 0) {
        return nil;
    }
    
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
    return [self trainingImages:images labels:labels sample:grayFrame];
}

@end
