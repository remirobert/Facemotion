//
//  DetectFace.m
//  FaceRecognition
//
//  Created by Remi Robert on 02/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "DetectFace.h"

@implementation DetectFace

- (instancetype)initWithTrackId:(NSInteger)trackId {
    self = [super init];
    
    if (self) {
        self.trackId = trackId;
        self.faces = [[NSMutableArray alloc] initWithCapacity:MAX_NUMBER_FRAME];
    }
    return self;
}

- (void)addFrame:(UIImage *)frame {
    if (!frame) {
        return;
    }
    if (self.faces.count >= MAX_NUMBER_FRAME) {
        [self.faces insertObject:frame atIndex:MAX_NUMBER_FRAME - 1];
        return;
    }
    [self.faces addObject:frame];
}

@end
