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
}

- (void)prepareForReuse {
    self.imageViewFace.image = nil;
}

- (void)configure:(Face *)face {
    self.imageViewFace.image = face.faceImage;
}

@end
