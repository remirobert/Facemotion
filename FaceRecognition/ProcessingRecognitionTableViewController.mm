//
//  ProcessingRecognitionTableViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 12/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "ProcessingRecognitionTableViewController.h"

@interface ProcessingRecognitionTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageviewResult;

@end

@implementation ProcessingRecognitionTableViewController

- (IBAction)cancelRecognition:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
