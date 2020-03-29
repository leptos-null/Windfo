//
//  WFArrowOverlay.m
//  Windfo
//
//  Created by Leptos on 3/28/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import "WFArrowOverlay.h"
#import "../Services/WFHeaderArithmetic.h"

@implementation WFArrowOverlay
@synthesize coordinate = _coordinate;

- (instancetype)initWithCenter:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        _coordinate = coordinate;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (UIBezierPath *)arrowPath {
    CGFloat const scale = 20; // sizing factor
    CGRect const drawRect = CGRectMake(0, 0, 30 * scale, 41 * scale);
    CGFloat const baseInset = 10 * scale;
    CGFloat const arrowHeight = 13 * scale;
    
    UIBezierPath *arrowDraw = [UIBezierPath bezierPath];
    [arrowDraw moveToPoint:CGPointMake(drawRect.size.width/2, 0)]; // triangle top
    [arrowDraw addLineToPoint:CGPointMake(drawRect.size.width, arrowHeight)]; // triangle right
    [arrowDraw addLineToPoint:CGPointMake(drawRect.size.width - baseInset, arrowHeight)]; // intersect right
    [arrowDraw addLineToPoint:CGPointMake(drawRect.size.width - baseInset, drawRect.size.height)]; // bottom right
    [arrowDraw addLineToPoint:CGPointMake(baseInset, drawRect.size.height)]; // bottom left
    [arrowDraw addLineToPoint:CGPointMake(baseInset, arrowHeight)]; // intersect left
    [arrowDraw addLineToPoint:CGPointMake(0, arrowHeight)]; // triangle left
    [arrowDraw closePath]; // close to triangle top
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, CGRectGetMidX(drawRect), CGRectGetMidY(drawRect));
    transform = CGAffineTransformRotate(transform, d2r(self.arrowDirection));
    transform = CGAffineTransformTranslate(transform, -CGRectGetMidX(drawRect), -CGRectGetMidY(drawRect));
    [arrowDraw applyTransform:transform];
    
    return arrowDraw;
}

- (MKMapRect)boundingMapRect {
    CGSize arrowSize = self.arrowPath.bounds.size;
    MKMapRect mapRect;
    mapRect.origin = MKMapPointForCoordinate(self.coordinate);
    mapRect.size.width = arrowSize.width;
    mapRect.size.height = arrowSize.height;
    mapRect.origin.x -= mapRect.size.width/2;
    mapRect.origin.y -= mapRect.size.height/2;
    return mapRect;
}

@end
