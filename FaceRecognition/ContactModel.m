//
//  ContactModel.m
//  FaceRecognition
//
//  Created by Remi Robert on 11/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel

- (instancetype)initWithContact:(CNContact *)contact {
    self = [super init];
    
    if (self) {
        self.id = contact.identifier;
        self.name = contact.givenName;
        self.picture = [UIImage imageWithData:contact.imageData];
    }
    return self;
}

@end
