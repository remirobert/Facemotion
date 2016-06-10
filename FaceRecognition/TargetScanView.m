//
//  TargetScanView.m
//  FaceRecognition
//
//  Created by Remi Robert on 10/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "TargetScanView.h"

@implementation TargetScanView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor( context, [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor);
    CGContextFillRect( context, rect );
    
    CGSize sizeScreen = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    CGSize sizeHole = CGSizeMake(sizeScreen.width - 50, sizeScreen.width - 50);
    
    CGRect holeRectIntersection = CGRectIntersection(CGRectMake(sizeScreen.width / 2 - sizeHole.width / 2,
                                                                 100, sizeHole.width, sizeHole.height), rect);
    
    if (CGRectIntersectsRect(holeRectIntersection, rect)) {
        CGContextAddEllipseInRect(context, holeRectIntersection);
        CGContextClip(context);
        CGContextClearRect(context, holeRectIntersection);
        CGContextSetFillColorWithColor( context, [UIColor clearColor].CGColor );
        CGContextFillRect( context, holeRectIntersection);
    }
}

@end
