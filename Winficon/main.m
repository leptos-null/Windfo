//
//  main.m
//  Winficon
//
//  Created by Leptos on 4/4/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import "AppDelegate/WFIAppDelegate.h"

int main(int argc, char *argv[]) {
    NSString *appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([WFIAppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
