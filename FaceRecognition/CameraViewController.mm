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

#include <iostream>
#include <fstream>
#include <sstream>

@interface CameraViewController () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFace;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPreview;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *frontDevice;
@property (nonatomic, strong) AVCaptureDevice *backDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureDataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layerPreview;
@property (nonatomic, assign) float currentValue;
@property (nonatomic, assign) cv::CascadeClassifier face_cascade;
@end

@implementation CameraViewController

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
        [_videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("videoutputaueeur",NULL)];
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
    [self.view bringSubviewToFront:self.imageViewFace];
    [self.view bringSubviewToFront:self.imageViewPreview];
}

- (UIImage *)cropImage:(UIImage *)image {
    CGRect croprect = CGRectMake(image.size.width / 4, image.size.height / 4 ,
                                 (image.size.width / 2), (image.size.height / 2));
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], croprect);
    return [UIImage imageWithCGImage:imageRef];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    float currentTimestampValue = (float)timestamp.value / timestamp.timescale;
    
    if (currentTimestampValue >= self.currentValue) {
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (pixelBuffer == nil) {
            NSLog(@"pixelBuffer is nil");
            return;
        }
        CIImage *ciimage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgimage = [context createCGImage:ciimage
                                           fromRect:CGRectMake(0, 0,
                                                               CVPixelBufferGetWidth(pixelBuffer),
                                                               CVPixelBufferGetHeight(pixelBuffer))];
        UIImage *image = [UIImage imageWithCGImage:cgimage];
        image = [ImageProcessing fixrotation:image];
        cv::Mat grayMat = [OpenCVImageProcessing cvMatFromUIImage:image];
        cv::Mat dst;
        cv::transpose(grayMat, dst);
        cv::flip(dst, dst, 2);
        UIImage *imageFace = [self detectFace:dst];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageViewFace.image = imageFace;
        });
        
        CGImageRelease(cgimage);
        self.currentValue = currentTimestampValue + 0.25;
    }
}

- (UIImage *)detectFace:(cv::Mat)frame {
    std::vector<cv::Rect> faces;
    cv::Size resizeImage(frame.size[1] / 10, frame.size[0] / 10);
    
    cv::Mat grayImage;
    cv::Mat smallImage;
    cv::cvtColor(frame, grayImage, cv::COLOR_BGR2GRAY);
    
    NSLog(@"⚠️ new size size image : %d %d", resizeImage.width, resizeImage.height);
    
    resize(grayImage, smallImage, resizeImage);
    //equalizeHist(grayImage, grayImage);
    
    self.face_cascade.detectMultiScale(smallImage, faces, 1.4, 3, 0, cv::Size(30, 30));
    NSLog(@"number faces detected : %lu", faces.size());
    for( size_t i = 0; i < faces.size(); i++ ) {
        NSLog(@"✅⚽️ position face detected : %d %d", faces[i].x, faces[i].y);
        NSLog(@"✅💨 size face detected : %d %d", faces[i].width, faces[i].height);
        cv::Point center(faces[i].x + resizeImage.width * 0.5, faces[i].y + resizeImage.height * 0.5);
        cv::Mat faceDetected = smallImage(faces[i]);
        
        cv::Mat croppedImage = cv::Mat(smallImage, cv::Rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height)).clone();
        
        cv::rectangle(smallImage, cvPoint(faces[i].x, faces[i].y), cvPoint(faces[i].x + faces[i].width, faces[i].y + faces[i].height), cv::Scalar(0, 255, 0));
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageViewPreview.image = [OpenCVImageProcessing UIImageFromCVMat:smallImage];
        });
        
        NSLog(@"⭐️👩 NEW IMAGE size frame created : %d %d", croppedImage.size[0], croppedImage.size[1]);
        return [OpenCVImageProcessing UIImageFromCVMat:croppedImage];
    }
    return [OpenCVImageProcessing UIImageFromCVMat:smallImage];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    std::string faceCascadePath = [[[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2"
                                                                ofType:@"xml"] UTF8String];
    
    NSLog(@"path ressource face file : %s", faceCascadePath.c_str());
    
    self.face_cascade = cv::CascadeClassifier(faceCascadePath);
    [self checkPermissionCamera];
    self.currentValue = 0;
    self.imageViewFace.image = [UIImage imageNamed:@"face-10"];
    self.imageViewFace.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewFace.layer.masksToBounds = true;
    self.imageViewFace.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
}

@end
