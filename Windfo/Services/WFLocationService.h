//
//  WFLocationService.h
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

@import CoreLocation;

typedef void(^WFLocationDidChangeCallback)(CLLocation *location);
typedef void(^WFHeadingDidChangeCallback)(CLLocationDirection heading);

@interface WFLocationService : NSObject <CLLocationManagerDelegate>

@property (class, nonatomic, readonly) WFLocationService *sharedService;
@property (strong, nonatomic, readonly) CLLocation *location;

- (void)requestLocationPermissions;

- (void)requestLocation;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

- (void)startUpdatingHeading API_UNAVAILABLE(macos, watchos, tvos);
- (void)stopUpdatingHeading API_UNAVAILABLE(macos, watchos, tvos);

- (void)addCallbackForLocationChange:(WFLocationDidChangeCallback)callback;
- (void)addCallbackForHeadingChange:(WFHeadingDidChangeCallback)callback API_UNAVAILABLE(macos, watchos, tvos);

@end
