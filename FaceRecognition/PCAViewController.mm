//
//  PCAViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 28/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "PCAViewController.h"

#import <FCFileManager.h>

#include <opencv2/highgui/cap_ios.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>

#include <iostream>
#include <fstream>
#include <sstream>

@interface PCAViewController ()

@end

@implementation PCAViewController

static cv::Mat norm_0_255(cv::InputArray _src) {
    cv::Mat src = _src.getMat();
    // Create and return normalized image:
    cv::Mat dst;
    switch(src.channels()) {
        case 1:
            cv::normalize(_src, dst, 0, 255, cv::NORM_MINMAX, CV_8UC1);
            break;
        case 3:
            cv::normalize(_src, dst, 0, 255, cv::NORM_MINMAX, CV_8UC3);
            break;
        default:
            src.copyTo(dst);
            break;
    }
    return dst;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    cv::Mat mean;
    
    NSString * path2 = [FCFileManager pathForMainBundleDirectory];    
    NSArray *files2 = [FCFileManager listFilesInDirectoryAtPath:path2];
    NSMutableArray *files = [NSMutableArray new];
    
    for (NSString *path in files2) {
        if ([[[path componentsSeparatedByString:@"."] lastObject] isEqualToString:@"pgm"] || [[[path componentsSeparatedByString:@"."] lastObject] isEqualToString:@"jpg"]) {
            [files addObject:path];
        }
    }
    
    NSLog(@"files paths : %@", files);

    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    images.push_back(cv::imread([(NSString *)[files objectAtIndex:0] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(0);
    images.push_back(cv::imread([(NSString *)[files objectAtIndex:1] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(0);
    
    images.push_back(cv::imread([(NSString *)[files objectAtIndex:2] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(1);
    images.push_back(cv::imread([(NSString *)[files objectAtIndex:3] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(1);

    images.push_back(cv::imread([(NSString *)[files objectAtIndex:4] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(2);
    images.push_back(cv::imread([(NSString *)[files objectAtIndex:5] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(2);

    images.push_back(cv::imread([(NSString *)[files objectAtIndex:6] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(3);
    images.push_back(cv::imread([(NSString *)[files objectAtIndex:7] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(3);
    
    images.push_back(cv::imread([(NSString *)[files objectAtIndex:8] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(4);
    images.push_back(cv::imread([(NSString *)[files objectAtIndex:9] UTF8String], cv::IMREAD_GRAYSCALE));
    labels.push_back(4);

    
    cv::Mat testSample = images[images.size() - 1];
    int testLabel = labels[labels.size() - 1];
    
    cv::Ptr<cv::FaceRecognizer> model = cv::createEigenFaceRecognizer();
    model->train(images, labels);
    int predictedLabel = model->predict(testSample);
    
    NSLog(@"found : %d / %d", predictedLabel, testLabel);
}

@end
