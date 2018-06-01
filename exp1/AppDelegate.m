//
//  AppDelegate.m
//  exp1
//
//  Created by imac on 29/05/18.
//  Copyright © 2018 paytren. All rights reserved.
//

#import "AppDelegate.h"
#import "IBCAppFacade.h"
#import "Config.h"
#import "NowPlayingList.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [[IBCAppFacade getInstance] startup:nil];
    /*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NowPlayingList* centerController= [NowPlayingList new];
    //PTMenuUI* rightController=[PTMenuUI new];
    
    
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController
                                                                                    leftViewController:nil];
    
    deckController.panningMode = IIViewDeckPanningViewPanning;
    deckController.leftSize = 0;
    //    deckController.rightSize = 250;
    //    deckController.topSize = 30;
    //    deckController.bottomSize = 40;
    // Override point for customization after application launch.
    [[IBCAppFacade getInstance] startup:nil];
    
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
    // Let the device know we want to receive push notifications
    if([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        // IOS8++
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else {
        // IOS7
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    
    NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //Accept push notification when app is not open
    if (remoteNotif) {
        [self application:application didReceiveRemoteNotification:remoteNotif];
    }
     */
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
   // UIViewController *viewController = // determine the initial view controller here and instantiate   it with [storyboard instantiateViewControllerWithIdentifier:<storyboard id>];
    
    NowPlayingList * nowPlaying = [NowPlayingList new];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:nowPlaying];
    
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
