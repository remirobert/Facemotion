//
//  CameraViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 28/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#include <opencv2/highgui/cap_ios.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>

#import "OpenCVImageProcessing.h"
#import "ImageProcessing.h"
#import "FaceDetector.h"
#import "FaceRecognition.h"
#import "FaceCollectionViewCell.h"

#include <iostream>
#include <fstream>
#include <sstream>

@interface CameraViewController () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPreview;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;
@property (weak, nonatomic) IBOutlet UIButton *buttonFlipCamera;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *frontDevice;
@property (nonatomic, strong) AVCaptureDevice *backDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureDataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layerPreview;
@property (nonatomic, assign) float currentValue;
@property (nonatomic, strong) NSMutableSet<Face *> *faces;
@property (nonatomic, strong) NSMutableArray<UIView *> *viewsFace;
@property (nonatomic, strong) CIDetector *faceDetector;
@end

@implementation CameraViewController

- (CIDetector *)faceDetector {
    if (!_faceDetector) {
        NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy,
                                         @(YES), CIDetectorTracking, nil];
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    }
    return _faceDetector;
}

- (NSMutableArray *)viewsFace {
    if (!_viewsFace) {
        _viewsFace = [NSMutableArray new];
    }
    return _viewsFace;
}

- (NSMutableSet *)faces {
    if (!_faces) {
        _faces = [NSMutableSet new];
    }
    return _faces;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureMetadataOutput *)captureDataOutput {
    if (!_captureDataOutput) {
        _captureDataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureDataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _captureDataOutput;
}

- (AVCaptureStillImageOutput *)stillImageOutput {
    if (!_stillImageOutput) {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    }
    return _stillImageOutput;
}

- (AVCaptureVideoDataOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("videoutputaueeur", NULL)];
    }
    return _videoOutput;
}

- (AVCaptureVideoPreviewLayer *)layerPreview {
    if (!_layerPreview) {
        _layerPreview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _layerPreview.frame = self.view.bounds;
        _layerPreview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _layerPreview;
}

- (void)initDevice {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        switch (device.position) {
            case AVCaptureDevicePositionBack:
                self.backDevice = device;
                break;
                
            case AVCaptureDevicePositionFront:
                self.frontDevice = device;
                break;
                
            default:
                break;
        }
    }
}

- (void)initInputDevice:(AVCaptureDevice *)device {
    NSError *error;
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (self.deviceInput) {
        if ([self.session canAddInput:self.deviceInput]) {
            [self.session addInput:self.deviceInput];
        }
    }
    else {
        NSLog(@"error %@", error);
    }
}

- (void)initMetadataOutput {
    if ([self.session canAddOutput:self.captureDataOutput]) {
        [self.session addOutput:self.captureDataOutput];
        [self.captureDataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    }
}

- (void)viewDidLayoutSubviews {
    [self.view.layer addSublayer:self.layerPreview];
    [self.view bringSubviewToFront:self.collectionView];
    [self.view bringSubviewToFront:self.buttonFlipCamera];
    [self.view bringSubviewToFront:self.imageViewPreview];
    
    
    for (UIView *view in self.viewsFace) {
        [self.view bringSubviewToFront:view];
    }
}

- (UIImage*)imageByCropping2:(UIImage *)imageToCrop toRect:(CGRect)rect

{
    
    //create a context to do our clipping in
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //create a rect with the size we want to crop the image to
    //the X and Y here are zero so we start at the beginning of our
    //newly created context
    
    CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    CGContextClipToRect( currentContext, clippedRect);
    
    //create a rect equivalent to the full size of the image
    //offset the rect by the X and Y we want to start the crop
    //from in order to cut off anything before them
    
    CGRect drawRect = CGRectMake(rect.origin.x * -1,
                                 rect.origin.y * -1,
                                 imageToCrop.size.width,
                                 imageToCrop.size.height);
    
    //draw the image to our clipped context using our offset rect
    
    CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
    
    //pull the image from our cropped context
    
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    
    //pop the context to get back to the default
    
    UIGraphicsEndImageContext();
    
    //Note: this is autoreleased
    
    return cropped;
    
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
UIImage* rotate(UIImage* src, UIImageOrientation orientation)
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect {
    cv::Mat frame = [OpenCVImageProcessing cvMatFromUIImage:[ImageProcessing fixrotation:imageToCrop]];

    cv::Mat croppedImage = cv::Mat(frame, cv::Rect(rect.origin.x, rect.origin.x, rect.size.width, rect.size.height)).clone();
    return [OpenCVImageProcessing UIImageFromCVMat:croppedImage];
}

+ (UIImage *) UIViewToImage:(UIView *)view
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    //
    // CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    CGSize imageSize = CGSizeMake( (CGFloat)480.0, (CGFloat)640.0 );        // camera image size
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Start with the view...
    //
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    CGContextConcatCTM(context, [view transform]);
    CGContextTranslateCTM(context,-[view bounds].size.width * [[view layer] anchorPoint].x,-[view bounds].size.height * [[view layer] anchorPoint].y);
    [[view layer] renderInContext:context];
    CGContextRestoreGState(context);
    
    // ...then repeat for every subview from back to front
    //
    for (UIView *subView in [view subviews])
    {
        if ( [subView respondsToSelector:@selector(screen)] )
            if ( [(UIWindow *)subView screen] == [UIScreen mainScreen] )
                continue;
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, [subView center].x, [subView center].y);
        CGContextConcatCTM(context, [subView transform]);
        CGContextTranslateCTM(context,-[subView bounds].size.width * [[subView layer] anchorPoint].x,-[subView bounds].size.height * [[subView layer] anchorPoint].y);
        [[subView layer] renderInContext:context];
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();   // autoreleased image
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    
    return;
    
    for (UIView *view in self.viewsFace) {
        [view removeFromSuperview];
    }
    [self.viewsFace removeAllObjects];
    for (AVMetadataObject *object in metadataObjects) {
        if ([object.type isEqualToString:AVMetadataObjectTypeFace]) {
            CGRect frameFace = object.bounds;
            CGSize sizeScreen = CGSizeMake(1920, 1080);
            
            NSLog(@"size face bounds : %f %f %f %f", frameFace.origin.x * CGRectGetWidth([UIScreen mainScreen].bounds), frameFace.origin.y * CGRectGetHeight([UIScreen mainScreen].bounds), frameFace.size.width, frameFace.size.height);
            
            CGRect rectCalculated = CGRectMake(frameFace.origin.x * CGRectGetWidth([UIScreen mainScreen].bounds), frameFace.origin.y * CGRectGetHeight([UIScreen mainScreen].bounds), 100, 100);
            
            UIView *newView = [[UIView alloc] initWithFrame:rectCalculated];
            newView.layer.borderColor = [[[UIColor redColor] colorWithAlphaComponent:0.5] CGColor];
            newView.layer.borderWidth = 1;
            newView.backgroundColor = [UIColor clearColor];
            [self.viewsFace addObject:newView];
            [self.view addSubview:newView];
        }
    }
}

- (NSNumber *) exifOrientation: (UIDeviceOrientation) orientation
{
    int exifOrientation;
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
                                                     //            if (self.isUsingFrontFacingCamera)
                                                     //                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
                                                     //            else
            exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
                                                     //            if (self.isUsingFrontFacingCamera)
                                                     //                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
                                                     //            else
            exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    return [NSNumber numberWithInt:exifOrientation];
}

- (CGRect)videoPreviewBoxForGravity:(NSString *)gravity
                          frameSize:(CGSize)frameSize
                       apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width)
        videoBox.origin.x = (frameSize.width - size.width) / 2;
    else
        videoBox.origin.x = (size.width - frameSize.width) / 2;
    
    if ( size.height < frameSize.height )
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    else
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    
    return videoBox;
}

- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    return newImage;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    float currentTimestampValue = (float)timestamp.value / timestamp.timescale;
    
    if (currentTimestampValue >= self.currentValue) {
        
//        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
//        CIImage *ciimage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
//                                                          options:nil];
//        
//        CIContext *context = [CIContext contextWithOptions:nil];
//        CGImageRef cgimage = [context createCGImage:ciimage
//                                           fromRect:CGRectMake(0, 0,
//                                                               CVPixelBufferGetWidth(pixelBuffer),
//                                                               CVPixelBufferGetHeight(pixelBuffer))];
//        UIImage *image = [UIImage imageWithCGImage:cgimage];
//        cv::Mat grayMat = [OpenCVImageProcessing cvMatFromUIImage:image];
//        cv::Mat dst;
//        cv::transpose(grayMat, dst);
//        cv::flip(dst, dst, 2);
//        image = [OpenCVImageProcessing UIImageFromCVMat:dst];
//        
//        NSArray *features = [self.faceDetector featuresInImage:ciimage
//                                                       options:nil];
//        
//        CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
//        CGRect cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);
//        
//        CGSize parentFrameSize = [self.view frame].size;
//        NSString *gravity = [self.layerPreview videoGravity];
//        BOOL isMirrored = [self.layerPreview isMirrored];
//        CGRect previewBox = [self videoPreviewBoxForGravity:gravity
//                                                  frameSize:parentFrameSize
//                                               apertureSize:cleanAperture.size];
//
//        
//        NSLog(@"number faces : %d", features.count);
//
//        for (CIFaceFeature *feature in features) {
//            CGRect faceRect = feature.bounds;
//            
//            NSLog(@"tracking id : %d", feature.trackingID);
//            
//            // flip preview width and height
//            CGFloat temp = faceRect.size.width;
//            faceRect.size.width = faceRect.size.height;
//            faceRect.size.height = temp;
//            temp = faceRect.origin.x;
//            faceRect.origin.x = faceRect.origin.y;
//            faceRect.origin.y = temp;
//            // scale coordinates so they fit in the preview box, which may be scaled
//            CGFloat widthScaleBy = previewBox.size.width / cleanAperture.size.height;
//            CGFloat heightScaleBy = previewBox.size.height / cleanAperture.size.width;
//            faceRect.size.width *= widthScaleBy;
//            faceRect.size.height *= heightScaleBy;
//            faceRect.origin.x *= widthScaleBy;
//            faceRect.origin.y *= heightScaleBy;
//            
//            UIImage *previewImage = [self imageByCropping:image toRect:faceRect];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.imageViewPreview.image = previewImage;
//            });
//        }
//        
//        
//        CGImageRelease(cgimage);

        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
                                                          options:nil];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgimage = [context createCGImage:ciImage
                                           fromRect:CGRectMake(0, 0,
                                                               CVPixelBufferGetWidth(pixelBuffer),
                                                               CVPixelBufferGetHeight(pixelBuffer))];

        UIImage *image = [UIImage imageWithCGImage:cgimage];
        
        cv::Mat grayMat = [OpenCVImageProcessing cvMatFromUIImage:image];
        cv::Mat dst;
        cv::transpose(grayMat, dst);
//        cv::flip(dst, dst, 2);
        image = [OpenCVImageProcessing UIImageFromCVMat:dst];

        CGImageRelease(cgimage);

//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.imageViewPreview.image = image;
//        });
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.imageViewPreview.image = [ImageProcessing fixrotation:imageCI];
//        });
//        
        if (attachments) {
            CFRelease(attachments);
        }
        
        // make sure your device orientation is not locked.
        UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
        
        NSDictionary *imageOptions = nil;
        
        imageOptions = [NSDictionary dictionaryWithObject:[self exifOrientation:curDeviceOrientation]
                                                   forKey:CIDetectorImageOrientation];
        
        
        NSLog(@"CI detector : %@", ciImage);
        NSArray *features = [self.faceDetector featuresInImage:ciImage
                                                       options:imageOptions];
        
        // get the clean aperture
        // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
        // that represents image data valid for display.
        CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
        CGRect cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
        
        NSLog(@"number faces detected : %lu", (unsigned long)features.count);
//        
//        for (UIView *view in self.viewsFace) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [view removeFromSuperview];
//            });
//        }
        
        CGSize parentFrameSize = [self.view frame].size;
        NSString *gravity = [self.layerPreview videoGravity];
        BOOL isMirrored = [self.layerPreview isMirrored];
        CGRect previewBox = [self videoPreviewBoxForGravity:gravity
                                                  frameSize:parentFrameSize
                                               apertureSize:cleanAperture.size];
        
        [self.viewsFace removeAllObjects];
        
        CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
        transform = CGAffineTransformTranslate(transform,
                                               0, -self.view.bounds.size.height);
        
        for (CIFaceFeature *feature in features) {
            CGRect faceRect = feature.bounds;
            
            NSLog(@"tracking id : %d", feature.trackingID);
    
            
            // flip preview width and height
            CGFloat temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            // scale coordinates so they fit in the preview box, which may be scaled
            CGFloat widthScaleBy = previewBox.size.width / cleanAperture.size.height;
            CGFloat heightScaleBy = previewBox.size.height / cleanAperture.size.width;
            faceRect.size.width *= widthScaleBy;
            faceRect.size.height *= heightScaleBy;
            faceRect.origin.x *= widthScaleBy;
            faceRect.origin.y *= heightScaleBy;
            
            CGRect newBounds = CGRectMake(feature.bounds.origin.x,
                                          image.size.height - feature.bounds.origin.y - feature.bounds.size.height,
                                          feature.bounds.size.width,
                                          feature.bounds.size.height);

            
//            faceRect = CGRectApplyAffineTransform(feature.bounds, transform);
            
            NSLog(@"frame face : %f %f %f %f", faceRect.origin.x, faceRect.origin.y, faceRect.size.width, faceRect.size.height);
            NSLog(@"frame face : %f %f %f %f", feature.bounds.origin.x, feature.bounds.origin.y, feature.bounds.size.width, feature.bounds.size.height);
            
            UIView *frame = [[UIView alloc] initWithFrame:faceRect];
            frame.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.6];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view addSubview:frame];
                
                CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(feature.bounds.origin.y, feature.bounds.origin.x, feature.bounds.size.width, feature.bounds.size.height));
                UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
                
//                cv::Mat grayMat2 = [OpenCVImageProcessing cvMatFromUIImage:croppedImage];
//                cv::Mat dst2;
//                cv::transpose(grayMat2, dst2);
//                cv::flip(dst2, dst2, 2);
//                croppedImage = [OpenCVImageProcessing UIImageFromCVMat:dst2];

                CGImageRelease(imageRef);
                
//                cv::Mat croppedImageGray = cv::Mat(dst, cv::Rect(feature.bounds.origin.x, feature.bounds.origin.y, feature.bounds.size.width, feature.bounds.size.height)).clone();
//                croppedImage = [OpenCVImageProcessing UIImageFromCVMat:croppedImageGray];
                self.imageViewPreview.image = croppedImage;
            });
            [self.viewsFace addObject:frame];
            
            
            
//            NSLog(@"image : %@", image);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.imageViewPreview.image = image;
//            });
//            
//            UIImage *previewImage = [self imageByCropping:imageCI toRect:faceRect];
//            NSLog(@"frame original image : %f %f %f %f", faceRect.origin.x, faceRect.origin.y, faceRect.size.width, faceRect.size.height);
//            NSLog(@"size original image : %f %f", imageCI.size.width, imageCI.size.height);
//            NSLog(@"image CI : %@", imageCI);
//            NSLog(@"preview image CI : %@", previewImage);
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (previewImage) {
//                }
//            });
        }
//                    [self drawFaces:features
//                        forVideoBox:cleanAperture
//                        orientation:curDeviceOrientation];
        
        self.currentValue = currentTimestampValue + 0.25;
        
        //        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        //        if (pixelBuffer == nil) {
        //            NSLog(@"pixelBuffer is nil");
        //            return;
        //        }
        //        CIImage *;; = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        //
        //        CIContext *context = [CIContext contextWithOptions:nil];
        //        CGImageRef cgimage = [context createCGImage:ciimage
        //                                           fromRect:CGRectMake(0, 0,
        //                                                               CVPixelBufferGetWidth(pixelBuffer),
        //                                                               CVPixelBufferGetHeight(pixelBuffer))];
        //        UIImage *image = [UIImage imageWithCGImage:cgimage];
        //        image = [ImageProcessing fixrotation:image];
        //        cv::Mat grayMat = [OpenCVImageProcessing cvMatFromUIImage:image];
        //        cv::Mat dst;
        //        cv::transpose(grayMat, dst);
        //        cv::flip(dst, dst, 2);
        //
        //        NSArray<Face*> *facesDetected = [FaceDetector detectFace:dst];
        //
        //        self.currentValue = currentTimestampValue + 0.25;
        //
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            for (UIView *view in self.viewsFace) {
        //                [view removeFromSuperview];
        //            }
        //
        //            [self.viewsFace removeAllObjects];
        //            for (Face *currentFace in facesDetected) {
        //                UIView *newView = [UIView new];
        //
        //                CGFloat ratioWidth = CGRectGetWidth([UIScreen mainScreen].bounds) / 1920;
        //                CGFloat ratioHeight = CGRectGetHeight([UIScreen mainScreen].bounds) / 1080;
        //
        ////                CGRect frameView = CGRectMake(currentFace.rect.origin.x / ratioWidth, currentFace.rect.origin.y / ratioHeight, currentFace.rect.size.width, currentFace.rect.size.height);
        //
        //                newView.frame = currentFace.rect;
        //
        //                newView.backgroundColor = [UIColor clearColor];
        //                newView.layer.borderColor = [[[UIColor greenColor] colorWithAlphaComponent:0.5] CGColor];
        //                newView.layer.borderWidth = 3;
        //                [self.viewsFace addObject:newView];
        //                [self.view addSubview:newView];
        //            }
        //        });
        
        //        if (self.faces.count == 0) {
        //            [self.faces addObjectsFromArray:facesDetected];
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                [self.collectionView reloadData];
        //            });
        //        }
        //        else {
        //            NSLog(@"🍪 number stack faces : %lu", (unsigned long)self.faces.count);
        //            if (facesDetected.firstObject) {
        //                if (![FaceRecognition trainingFace:[self.faces allObjects] withFace:facesDetected.firstObject]) {
        //                    NSLog(@"🍋 add new unknow face !!");
        //                    [self.faces addObject:facesDetected.firstObject];
        //
        //                    dispatch_async(dispatch_get_main_queue(), ^{
        //                        [self.collectionView reloadData];
        //                    });
        //                }
        //            }
        //        }
        //        CGImageRelease(cgimage);
    }
}

- (void)initCamera {
    [self initDevice];
    [self initInputDevice:self.backDevice];
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    [self.session startRunning];
    [self initMetadataOutput];
}

- (void)checkPermissionCamera {
    AVAuthorizationStatus auth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (auth) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    [self initCamera];
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusAuthorized:
            [self initCamera];
            break;
            
        default:
            break;
    }
}

- (IBAction)flipCamera:(id)sender {
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.faces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceCollectionViewCell" forIndexPath:indexPath];
    Face *currentFace = [[self.faces allObjects] objectAtIndex:indexPath.row];
    [cell configure:currentFace];
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkPermissionCamera];
    self.currentValue = 0;
    
    self.collectionViewLayout.itemSize = CGSizeMake(100, 100);
    self.collectionViewLayout.minimumLineSpacing = 0;
    self.collectionViewLayout.minimumInteritemSpacing = 0;
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"FaceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FaceCollectionViewCell"];
    self.collectionView.dataSource = self;
    
    self.imageViewPreview.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
    self.imageViewPreview.layer.masksToBounds = true;
}

@end
