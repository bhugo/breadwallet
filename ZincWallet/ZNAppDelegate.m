//
//  ZNAppDelegate.m
//  ZincWallet
//
//  Created by Aaron Voisine on 5/8/13.
//  Copyright (c) 2013 zinc. All rights reserved.
//

#import "ZNAppDelegate.h"
#import "NSString+Base58.h"

@implementation ZNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self keepUpAppearances];

    //XXX need to upgrade openssl (and other libs) to latest
    
    //XXX need a way to recieve pushes when unconfirmed transactions to a wallet address happen
    // (this could obviate the need to walk all the addresses looking for new transactions)

    //XXX need to implement pin code
    
    //XXX figure what to do about bluetooth
    // this will notify user if bluetooth is disabled (on 4S and newer devices that support BTLE)
    //CBCentralManager *cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    //[self centralManagerDidUpdateState:cbManager]; // Show initial state
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of
    // temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use
    // this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application
    // state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate:
    // when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes
    // made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application
    // was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also
    // applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
annotation:(id)annotation
{
    if (! url.host && url.resourceSpecifier) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", url.scheme, url.resourceSpecifier]];
    }

    if (! [url.scheme isEqual:@"bitcoin"] || ! [url.host isValidBitcoinAddress]) return NO;

    [[NSNotificationCenter defaultCenter] postNotificationName:bitcoinURLNotification object:self
     userInfo:@{@"url":url}];
    
    return YES;
}

#pragma mark - appearance

- (void)keepUpAppearances
{
    //XXX icon idea, super stylized qr code/camera guide
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    if ([UIDevice.currentDevice.systemVersion intValue] < 7) {
        // HelveticaNeue-Medium is missing the BTC char :(
        [[UINavigationBar appearance]
         setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor lightGrayColor],
                                  UITextAttributeTextShadowColor:[UIColor whiteColor],
                                  UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)],
                                  UITextAttributeFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0]}];
        
    
        //[[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:0.95 alpha:1.0]];
    
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0],
                                  UITextAttributeTextShadowColor:[UIColor whiteColor],
                                  UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)],
                                  UITextAttributeFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]}
         forState:UIControlStateNormal];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],
                                  UITextAttributeTextShadowColor:[UIColor whiteColor],
                                  UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0.0, 0.0)],
                                  UITextAttributeFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]}
         forState:UIControlStateHighlighted];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:[[UIImage imageNamed:@"back-bg-white.png"]
                                       resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 15.0, 16.0, 5.0)]
         forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:[[UIImage imageNamed:@"back-bg-blue.png"]
                                       resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 5.0)]
         forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonTitlePositionAdjustment:UIOffsetMake(0.0, -1.0) forBarMetrics:UIBarMetricsDefault];

        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:[[UIImage imageNamed:@"button-bg-white.png"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 5.0, 16.0, 5.0)]
         forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:[[UIImage imageNamed:@"button-bg-blue"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 5.0, 15.0, 5.0)]
         forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    }
    //XXX need a custom back button bg image
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)cbManager
{
    switch (cbManager.state) {
        case CBCentralManagerStateResetting: NSLog(@"system BT connection momentarily lost."); break;
        case CBCentralManagerStateUnsupported: NSLog(@"BT Low Energy not suppoerted."); break;
        case CBCentralManagerStateUnauthorized: NSLog(@"BT Low Energy not authorized."); break;
        case CBCentralManagerStatePoweredOff: NSLog(@"BT off."); break;
        case CBCentralManagerStatePoweredOn: NSLog(@"BT on."); break;
        default: NSLog(@"BT State unknown."); break;
    }    
}
@end
