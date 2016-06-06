//
//  FaceCollectionViewCell.h
//  FaceRecognition
//
//  Created by Remi Robert on 31/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectFace.h"

@interface FaceCollectionViewCell : UICollectionViewCell
- (void)configure:(DetectFace *)face;
- (void)configureWithImage:(UIImage *)face;
@end
