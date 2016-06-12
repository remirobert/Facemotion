//
//  FaceContact.h
//  FaceRecognition
//
//  Created by Remi Robert on 12/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm.h>

@interface FaceContact : RLMObject
@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) NSInteger idRecognition;
@property (nonatomic, strong) NSData *imageData;
- (instancetype)initWithImage:(UIImage *)image idContact:(NSString *)id;
@end
