//
//  AppDelegate.m
//  FaceRecognition
//
//  Created by Remi Robert on 29/03/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)configureApperance {
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [UINavigationBar appearance].shadowImage = [UIImage new];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

@end
