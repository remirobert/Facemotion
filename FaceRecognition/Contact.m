//
//  Contact.m
//  FaceRecognition
//
//  Created by Remi Robert on 06/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <FCFileManager.h>
#import "Contact.h"

@implementation Contact

- (instancetype)init:(DetectFace *)face {
    self = [super init];
    
    if (self) {
        self.key = [[NSUUID UUID] UUIDString];
    }
    return self;
}

@end
