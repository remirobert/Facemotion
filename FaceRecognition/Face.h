//
//  Face.h
//  FaceRecognition
//
//  Created by Remi Robert on 30/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/core/core.hpp>

@interface Face : NSObject
@property (nonatomic, assign) cv::Mat face;
@property (nonatomic, strong) UIImage *faceImage;
@property (nonatomic, strong) NSString *id;

- (instancetype)init:(cv::Mat)face;
@end
