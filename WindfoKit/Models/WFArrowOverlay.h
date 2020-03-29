//
//  WFArrowOverlay.h
//  Windfo
//
//  Created by Leptos on 3/28/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface WFArrowOverlay : NSObject <MKOverlay>

- (instancetype)initWithCenter:(CLLocationCoordinate2D)coordinate;

@property (nonatomic) CLLocationDirection arrowDirection;
@property (strong, nonatomic, readonly) UIBezierPath *arrowPath;

@end
