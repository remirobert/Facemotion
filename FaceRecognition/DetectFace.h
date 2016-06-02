//
//  DetectFace.h
//  FaceRecognition
//
//  Created by Remi Robert on 02/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetectFace : NSObject
@property (nonatomic, assign) NSInteger trackId;
@property (nonatomic, strong) NSMutableArray<UIImage *> *faces;

- (instancetype)initWithTrackId:(NSInteger)trackId;
- (void)addFrame:(UIImage *)frame;
@end
