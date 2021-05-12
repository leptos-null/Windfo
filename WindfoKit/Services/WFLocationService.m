//
//  WFLocationService.m
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "WFLocationService.h"

@implementation WFLocationService {
    CLLocationManager *_locationManager;
    NSMutableSet<WFLocationDidChangeCallback> *_locationCallbacks;
    NSMutableSet<WFHeadingDidChangeCallback> *_headingCallbacks;
}

+ (instancetype)sharedService {
    static dispatch_once_t dispatchOnce;
    static WFLocationService *ret = nil;
    dispatch_once(&dispatchOnce, ^{
        ret = [self new];
    });
    return ret;
}

- (instancetype)init {
    if (self = [super init]) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 500;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        _locationCallbacks = [NSMutableSet set];
        if (CLLocationManager.headingAvailable) {
            _headingCallbacks = [NSMutableSet set];
        }
    }
    return self;
}

- (void)requestLocationPermissions {
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
    }
}

- (void)requestLocation {
    [_locationManager requestLocation];
}

- (void)startUpdatingLocation {
    [_locationManager startUpdatingLocation];
}
- (void)stopUpdatingLocation {
    [_locationManager stopUpdatingLocation];
}

- (void)startUpdatingHeading API_UNAVAILABLE(macos, tvos) {
    [_locationManager startUpdatingHeading];
}
- (void)stopUpdatingHeading API_UNAVAILABLE(macos, tvos) {
    [_locationManager stopUpdatingHeading];
}

- (void)addCallbackForLocationChange:(WFLocationDidChangeCallback)callback {
    [_locationCallbacks addObject:callback];
}
- (void)addCallbackForHeadingChange:(WFHeadingDidChangeCallback)callback API_UNAVAILABLE(macos, tvos) {
    [_headingCallbacks addObject:callback];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *const location = locations.lastObject;
    _location = location;
    for (WFLocationDidChangeCallback callback in _locationCallbacks) {
        callback(location);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading API_UNAVAILABLE(tvos) {
    CLLocationDirection const direction = newHeading.trueHeading;
    for (WFHeadingDidChangeCallback callback in _headingCallbacks) {
        callback(direction);
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [manager startUpdatingLocation];
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManagerDidFailWithError: %@", error);
}

@end
