//
//  SettingsTableViewController.m
//  FaceRecognition
//
//  Created by Remi Robert on 13/06/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchSpeech;
@end

@implementation SettingsTableViewController

- (IBAction)switchStateSpeech:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.switchSpeech.on forKey:@"speech"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
