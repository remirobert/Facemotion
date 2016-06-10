//
//  FaceCollectionViewCell.m
//  FaceRecognition
//
//  Created by Remi Robert on 31/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "FaceCollectionViewCell.h"

@interface FaceCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFace;
@end

@implementation FaceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageViewFace.layer.cornerRadius = 35;
    self.imageViewFace.layer.masksToBounds = true;
    self.imageViewFace.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.4] CGColor];
    self.imageViewFace.layer.borderWidth = 2;
    self.imageViewFace.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)prepareForReuse {
    self.imageViewFace.image = nil;
}

- (void)configure:(DetectFace *)face {
    UIImage *faceFrame = [face.faces firstObject];
    if (faceFrame) {
        self.imageViewFace.image = faceFrame;
    }
}

- (void)configureWithImage:(UIImage *)face {
    self.imageViewFace.image = face;
}

@end
