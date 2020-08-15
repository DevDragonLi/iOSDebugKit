//
//  AppDelegate.m
//  ZDDebugKit
//
//  Created by DragonLi on 28/7/2020.
//  Copyright © 2020 zd. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]init];
    self.window.rootViewController = [ViewController new];
    [self.window makeKeyAndVisible];

    return YES;
}



@end
