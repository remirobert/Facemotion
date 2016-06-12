//
//  CameraViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 28/05/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "CameraViewController.h"
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>
#include <opencv2/highgui/cap_ios.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>

#import "OrientationDevice.h"
#import "OpenCVImageProcessing.h"
#import "ImageProcessing.h"
#import "FaceDetector.h"
#import "FaceRecognition.h"
#import "FaceCollectionViewCell.h"
#import "DetectFace.h"
#import "GradientView.h"
#import "DetailDetectionFaceViewController.h"
#import "TargetScanView.h"
#import "CreateNewContactTableViewController.h"
#import "ProcessingRecognitionTableViewController.h"
#import "UIImage+Resize.h"

#include <iostream>
#include <fstream>
#include <sstream>

#define MAX_DETECTED_FACES 10

@interface CameraViewController () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *buttonClearDetection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintClear;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *effectView;
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
@property (nonatomic, strong) NSMutableArray<UIView *> *viewsFace;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) NSMutableArray<DetectFace *> *detectedFaces;
@property (nonatomic, assign) BOOL isPaused;
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

- (NSMutableArray *)detectedFaces {
    if (!_detectedFaces) {
        _detectedFaces = [[NSMutableArray alloc] initWithCapacity:MAX_TRAILER_SIZE];
    }
    return _detectedFaces;
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
    [self.view.layer insertSublayer:self.layerPreview atIndex:0];
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
    
    if (size.height < frameSize.height )
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    else
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    
    return videoBox;
}

- (NSArray *)featuresForImage:(CIImage *)image {
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[OrientationDevice exifOrientation]
                                                             forKey:CIDetectorImageOrientation];
    return [self.faceDetector featuresInImage:image options:imageOptions];
}

- (CGRect)frameForFeature:(CIFaceFeature *)feature
               previewBox:(CGRect)previewBox
            cleanAperture:(CGRect)cleanAperture {
    
    CGRect faceRect = feature.bounds;
    CGFloat temp = faceRect.size.width;
    faceRect.size.width = faceRect.size.height;
    faceRect.size.height = temp;
    temp = faceRect.origin.x;
    faceRect.origin.x = faceRect.origin.y;
    faceRect.origin.y = temp;
    CGFloat widthScaleBy = previewBox.size.width / cleanAperture.size.height;
    CGFloat heightScaleBy = previewBox.size.height / cleanAperture.size.width;
    faceRect.size.width *= widthScaleBy;
    faceRect.size.height *= heightScaleBy;
    faceRect.origin.x *= widthScaleBy;
    faceRect.origin.y *= heightScaleBy;
    return faceRect;
}

- (void)cleanDetectedFaces:(NSArray *)features {
    [self.detectedFaces enumerateObjectsUsingBlock:^(DetectFace * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL detected = false;
        for (CIFaceFeature *feature in features) {
            if (feature.trackingID == obj.trackId) {
                detected = true;
                break;
            }
        }
        if (!detected) {
            [self.detectedFaces removeObject:obj];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)addNewFaceFrame:(CIFaceFeature *)feature frame:(UIImage *)frameImage {
    if (!feature.hasMouthPosition || !feature.hasLeftEyePosition || !feature.hasRightEyePosition) {
        return;
    }
    frameImage = [frameImage resizedImageToSize:CGSizeMake(150, 150)];
    for (DetectFace *detectedFace in self.detectedFaces) {
        if (detectedFace.trackId == feature.trackingID) {
            [detectedFace addFrame:frameImage];
            return;
        }
    }
    
    DetectFace *newFace = [[DetectFace alloc] initWithTrackId:feature.trackingID];
    [newFace addFrame:frameImage];
    
    if (self.detectedFaces.count >= MAX_TRAILER_SIZE) {
        [self.detectedFaces removeObjectAtIndex:0];
    }
    [self.detectedFaces addObject:newFace];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (self.isPaused) {
        return;
    }
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    float currentTimestampValue = (float)timestamp.value / timestamp.timescale;
    
    if (currentTimestampValue >= self.currentValue) {
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:nil];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgimage = [context createCGImage:ciImage
                                           fromRect:CGRectMake(0, 0,
                                                               CVPixelBufferGetWidth(pixelBuffer),
                                                               CVPixelBufferGetHeight(pixelBuffer))];
        UIImage *image = [UIImage imageWithCGImage:cgimage];
        CGImageRelease(cgimage);
        
        NSArray *features = [self featuresForImage:ciImage];
        [self cleanDetectedFaces:features];
        
        CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
        CGRect cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);
        
        CGSize parentFrameSize = [self.view frame].size;
        NSString *gravity = [self.layerPreview videoGravity];
        CGRect previewBox = [self videoPreviewBoxForGravity:gravity
                                                  frameSize:parentFrameSize
                                               apertureSize:cleanAperture.size];
        
        CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
        transform = CGAffineTransformTranslate(transform,
                                               0, -self.view.bounds.size.height);
        
        
        NSLog(@"🤖 number detected frames : %lu", (unsigned long)self.detectedFaces.count);
        for (CIFaceFeature *feature in features) {
            if (!feature.hasMouthPosition || !feature.hasLeftEyePosition || !feature.hasRightEyePosition) {
                continue;
            }
            CGRect faceRect = [self frameForFeature:feature previewBox:previewBox cleanAperture:cleanAperture];
            
            CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage,
                                                               CGRectMake(feature.bounds.origin.x,
                                                                          image.size.height - (feature.bounds.size.height + feature.bounds.origin.y),
                                                                          feature.bounds.size.width,
                                                                          feature.bounds.size.height));
            UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        
            CGImageRelease(imageRef);
            [self addNewFaceFrame:feature frame:croppedImage];
        }
        self.currentValue = currentTimestampValue + 0.50;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isPaused = false;
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    [self initMetadataOutput];

    [UIView animateWithDuration:1 animations:^{
        self.loadingView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.loadingView removeFromSuperview];
    }];
}

- (void)initCamera {
    [self initDevice];
    [self initInputDevice:self.backDevice];
    [self.session startRunning];
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

- (IBAction)clearFaces:(id)sender {
    NSLog(@"clear call");
    [self.detectedFaces removeAllObjects];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.detectedFaces.count > 0  && self.bottomConstraintCollection.constant < 0) {
        self.bottomConstraintCollection.constant = 44;
        [self.effectView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.6
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
                                [self.view layoutIfNeeded];
                            } completion:^(BOOL finished) {}];
        
        [UIView animateWithDuration:0.5
                              delay:0.5
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.6
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
                                self.bottomConstraintClear.constant = 136 + 44;
                                [self.view layoutIfNeeded];
                            } completion:^(BOOL finished) {}];
    }
    else if (self.detectedFaces.count == 0 && self.bottomConstraintCollection.constant > -128) {
        self.bottomConstraintCollection.constant = -128;
        self.bottomConstraintClear.constant = -136;
        [self.effectView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    return self.detectedFaces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FaceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceCollectionViewCell" forIndexPath:indexPath];
    DetectFace *currentFace = [self.detectedFaces objectAtIndex:indexPath.row];
    [cell configure:currentFace];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.isPaused = true;
    [self performSegueWithIdentifier:@"processingSegue" sender:[self.detectedFaces objectAtIndex:indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"processingSegue"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        ((ProcessingRecognitionTableViewController *)navigationController.viewControllers.firstObject).face = (DetectFace *)sender;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.buttonClearDetection.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.buttonClearDetection.layer.borderWidth = 2;
    self.buttonClearDetection.layer.cornerRadius = 15;
    
    [self checkPermissionCamera];
    self.currentValue = 0;
    
    self.isPaused = false;
    self.collectionViewLayout.itemSize = CGSizeMake(100, 100);
    self.collectionViewLayout.minimumLineSpacing = 0;
    self.collectionViewLayout.minimumInteritemSpacing = 0;
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"FaceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FaceCollectionViewCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.bottomConstraintCollection.constant = -128;
    self.bottomConstraintClear.constant = -136;
    
    TargetScanView *targetView = (TargetScanView *)[[[UINib nibWithNibName:@"TargetScanView" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    [self.view insertSubview:targetView atIndex:0];
    [targetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [self.detectedFaces removeAllObjects];
    [self.collectionView reloadData];
}

@end
