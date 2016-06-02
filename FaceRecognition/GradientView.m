//
//  GradientView.m
//  FaceRecognition
//
//  Created by Remi Robert on 02/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (void)drawRect:(CGRect)rect {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.8] CGColor],
                       (id)[[UIColor blackColor] CGColor], nil];
    [self.layer insertSublayer:gradient atIndex:0];
}

@end
