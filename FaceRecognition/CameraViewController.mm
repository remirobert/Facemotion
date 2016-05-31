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
@end

@implementation CameraViewController

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
    [self.view bringSubviewToFront:self.collectionView];
    [self.view bringSubviewToFront:self.buttonFlipCamera];
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
        
        NSArray<Face*> *facesDetected = [FaceDetector detectFace:dst];
        
        self.currentValue = currentTimestampValue + 0.25;
        
        if (self.faces.count == 0) {
            [self.faces addObjectsFromArray:facesDetected];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
        else {
            NSLog(@"🍪 number stack faces : %lu", (unsigned long)self.faces.count);
            if (facesDetected.firstObject) {
                if (![FaceRecognition trainingFace:[self.faces allObjects] withFace:facesDetected.firstObject]) {
                    NSLog(@"🍋 add new unknow face !!");
                    [self.faces addObject:facesDetected.firstObject];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView reloadData];
                    });
                }
            }
        }
        CGImageRelease(cgimage);
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
}

@end
