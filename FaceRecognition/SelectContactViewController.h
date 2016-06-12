//
//  SelectContactViewController.h
//  FaceRecognition
//
//  Created by Remi Robert on 12/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectFace.h"
#import "FaceContact.h"

@interface SelectContactViewController : UIViewController
@property (nonatomic, strong) DetectFace *face;
+ (NSString *)recognitionFace:(NSArray<FaceContact *> *)faces face:(UIImage *)image;
@end
