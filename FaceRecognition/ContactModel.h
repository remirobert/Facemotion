//
//  ContactModel.h
//  FaceRecognition
//
//  Created by Remi Robert on 11/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

@interface ContactModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *picture;
- (instancetype)initWithContact:(CNContact *)contact;
@end
