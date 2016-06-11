//
//  ContactCollectionViewCell.m
//  FaceRecognition
//
//  Created by Remi Robert on 11/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "ContactCollectionViewCell.h"

@interface ContactCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@end

@implementation ContactCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configure:(ContactModel *)model {
    self.imageView.image = model.picture;
    self.labelName.text = model.name;
}

@end
