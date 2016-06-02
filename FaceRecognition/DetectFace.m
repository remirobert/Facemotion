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
        self.faces = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)addFrame:(UIImage *)frame {
    if (self.faces.count >= 10) {
        [self.faces removeObjectAtIndex:0];
    }
    [self.faces addObject:frame];
}

@end
