//
//  FaceDetector.m
//  FaceRecognition
//
//  Created by Remi Robert on 30/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "FaceDetector.h"
#import "OpenCVImageProcessing.h"

@implementation FaceDetector

- (instancetype)init {
    self = [super init];
    
    if (self) {
        std::string faceCascadePath = [[[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2"
                                                                       ofType:@"xml"] UTF8String];
        self.face_cascade = cv::CascadeClassifier(faceCascadePath);
    }
    return self;
}

+ (FaceDetector *)sharedInstance {
    static FaceDetector *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [FaceDetector new];
    });
    return instance;
}

+ (NSArray<Face *> *)detectFace:(cv::Mat)frame {
    std::vector<cv::Rect> faces;
    cv::Size resizeImage(frame.size[1] / 10, frame.size[0] / 10);
    cv::Mat grayImage;
    cv::Mat smallImage;
    resize(frame, smallImage, resizeImage);
    cv::cvtColor(smallImage, grayImage, cv::COLOR_BGR2GRAY);
    
    NSLog(@"size image detected : %d %d", frame.size[0], frame.size[1]);
    
    NSMutableArray<Face *> *facesDetected = [[NSMutableArray alloc] initWithCapacity:faces.size()];
    [self sharedInstance].face_cascade.detectMultiScale(smallImage, faces, 1.4, 3, 0, cv::Size(30, 30));
    
    for( size_t i = 0; i < faces.size(); i++ ) {
        NSLog(@"✅⚽️ position face detected : %d %d", faces[i].x, faces[i].y);
        NSLog(@"✅💨 size face detected : %d %d", faces[i].width, faces[i].height);
        cv::Point center(faces[i].x + resizeImage.width * 0.5, faces[i].y + resizeImage.height * 0.5);
        cv::Mat faceDetected = smallImage(faces[i]);
        cv::Mat croppedImage = cv::Mat(smallImage, cv::Rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height)).clone();
        cv::Mat croppedImageGray = cv::Mat(grayImage, cv::Rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height)).clone();

        cv::Size finalSize(50, 50);
        resize(croppedImage, croppedImage, cv::Size(50, 50));
        resize(croppedImageGray, croppedImageGray, cv::Size(50, 50));
        NSLog(@"resize cropped Image : %d %d", croppedImage.size[0], croppedImage.size[1]);
        
        Face *newFace = [[Face alloc] init:croppedImage];
        newFace.face = croppedImageGray;
        newFace.rect = CGRectMake(faces[i].x * 10, faces[i].y * 10, faces[i].width * 10, faces[i].height * 10);
        [facesDetected addObject:newFace];
    }
    return facesDetected;
}

@end
