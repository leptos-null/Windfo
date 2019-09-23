//
//  WFAppDelegate.m
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "WFAppDelegate.h"

@implementation WFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // I can't find it any where in the documentation, but unless this call is here,
    //   the menu bar is not what's in the storyboard
    if (@available(iOS 13.0, *)) {
        [UIMenuSystem.mainSystem setNeedsRebuild];
    }
    return YES;
}

@end
