//
//  FSAppDelegate.m
//  FiSoMusicPlayer
//
//  Created by Tomoyuki Ito on 2013/08/31.
//  Copyright (c) 2013年 REVERTO. All rights reserved.
//

#import "FSAppDelegate.h"
#import "FSMainViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface FSAppDelegate ()

@property FSMainViewController *mainVC;

@end

@implementation FSAppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // initialization: Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 10;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-37381910-3"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.mainVC = [[FSMainViewController alloc] initWithNibName:@"FSMainViewController"
                                                                          bundle:nil];
    UINavigationController *naviC = [[UINavigationController alloc] initWithRootViewController:self.mainVC];
    self.window.rootViewController = naviC;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.mainVC reloadMediaItemList];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
