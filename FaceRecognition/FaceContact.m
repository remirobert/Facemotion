
//
//  FaceContact.m
//  FaceRecognition
//
//  Created by Remi Robert on 12/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "FaceContact.h"

@implementation FaceContact

+ (nullable NSString *)primaryKey {
    return @"id";
}

- (instancetype)initWithImage:(UIImage *)image idContact:(NSString *)id {
    self = [super init];
    
    if (self) {
        self.id = id;
        self.imageData = UIImageJPEGRepresentation(image, 0.2);
    }
    return self;
}

@end
