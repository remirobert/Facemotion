//
//  RecognitionResult.h
//  FaceRecognition
//
//  Created by Remi Robert on 12/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceContact.h"

@interface RecognitionResult : NSObject
@property (nonatomic, strong) FaceContact *contact;
@property (nonatomic, assign) double confidence;
@end
