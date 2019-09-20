//
//  WFInterfaceController.m
//  WindfoNanoExt
//
//  Created by Leptos on 9/16/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "WFInterfaceController.h"
#import "WFForecastController.h"

@implementation WFInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    WFLocationService *locationService = WFLocationService.sharedService;
    [locationService requestLocationPermissions];
    __weak typeof(self) weakself = self;
    [locationService addCallbackForLocationChange:^(CLLocation *location) {
        [weakself updateLabelsForCurrentLocation];
    }];
    [locationService addCallbackForHeadingChange:^(CLLocationDirection heading) {
        weakself.currentHeading = heading;
    }];
    
    if (CLLocationManager.headingAvailable || DEBUG) {
        CGFloat compassDiameter = self.contentFrame.size.width * WKInterfaceDevice.currentDevice.screenScale * 0.15;
        UIImage *compassIcon = [self _compassImageForDiameter:compassDiameter triangleScale:1/3.0 rotation:M_PI_4];
        [self addMenuItemWithImage:compassIcon title:@"Compass" action:@selector(_compassMenuRequest)];
    }
    [self addMenuItemWithItemIcon:WKMenuItemIconPlay title:@"Forecast" action:@selector(_forecastMenuRequest)];
}

- (void)_compassMenuRequest {
    self.showingCompass = YES;
}

- (void)_forecastMenuRequest {
    self.showingCompass = NO;
}

- (void)willActivate {
    [super willActivate];
    
    WFLocationService *locationService = WFLocationService.sharedService;
    [locationService startUpdatingLocation];
    if (self.showingCompass) {
        [locationService startUpdatingHeading];
    }
    
    [self updateLabelsForCurrentLocation];
}

- (void)didDeactivate {
    [super didDeactivate];
    
    WFLocationService *locationService = WFLocationService.sharedService;
    [locationService stopUpdatingLocation];
    [locationService stopUpdatingHeading];
}

- (void)setCurrentHeading:(CLLocationDirection)currentHeading {
    _currentHeading = currentHeading;
    [self rotateCompassForDirections];
}

- (void)setWindDirection:(CLLocationDirection)windDirection {
    _windDirection = windDirection;
    [self rotateCompassForDirections];
}

- (void)setForecastModels:(NSArray<WFWindForecastModel *> *)forecastModels {
    _forecastModels = forecastModels;
    
    WKInterfaceTable *forecastTable = self.forecastTable;
    [forecastTable setNumberOfRows:forecastModels.count withRowType:WFForecastController.rowType];
    [forecastModels enumerateObjectsUsingBlock:^(WFWindForecastModel *model, NSUInteger idx, BOOL *stop) {
        WFForecastController *forecastController = [forecastTable rowControllerAtIndex:idx];
        forecastController.model = model;
    }];
}

- (void)setCurrentModel:(WFWeatherWindModel *)currentModel {
    _currentModel = currentModel;
    
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
        dateFormatter.timeZone = NSTimeZone.localTimeZone;
        dateFormatter.locale = NSLocale.autoupdatingCurrentLocale;
        dateFormatter.calendar = NSCalendar.autoupdatingCurrentCalendar;
    });
    
    self.windDirection = currentModel.direction;
    
    self.locationLabel.text = currentModel.localizedLocationName;
    self.locationLabel.accessibilityValue = currentModel.localizedLocationName;
    self.timeLabel.text = [dateFormatter stringFromDate:currentModel.updateTime];
    
    BOOL useMetric = NSLocale.currentLocale.usesMetricSystem;
    self.windSpeedLabel.text = [NSString stringWithFormat:@"%.1f G %.1f %@",
        useMetric ? currentModel.metricSpeed : currentModel.imperialSpeed,
        useMetric ? currentModel.metricGust : currentModel.imperialGust,
        useMetric ? currentModel.localizedMetricUnit : currentModel.localizedImperialUnit];
    self.windSpeedLabel.accessibilityValue = [NSString stringWithFormat:@"%.1f gusting %.1f %@",
        useMetric ? currentModel.metricSpeed : currentModel.imperialSpeed,
        useMetric ? currentModel.metricGust : currentModel.imperialGust,
        useMetric ? currentModel.localizedMetricAccessibilityUnit : currentModel.localizedImperialAccessibilityUnit];
    self.windDirectionLabel.text = [NSString stringWithFormat:@"%.0f° %@",
                                    currentModel.direction, currentModel.localizedCardinalDirection];
}

- (void)setShowingCompass:(BOOL)showingCompass {
    _showingCompass = showingCompass;
    
    [self updateLabelsForCurrentLocation];
    if (showingCompass) {
        [WFLocationService.sharedService startUpdatingHeading];
    } else {
        [WFLocationService.sharedService stopUpdatingHeading];
    }
    self.compassImage.hidden = !showingCompass;
    self.forecastTable.hidden = showingCompass;
}

- (IBAction)updateLabelsForCurrentLocation {
    CLLocation *location = WFLocationService.sharedService.location;
    NSDate *start = [NSDate date];
    __weak typeof(self) weakself = self;
    [WFWeatherService windSpeedDirectionForLocation:location locale:nil completion:^(WFWeatherWindModel *model, NSArray<WFWindForecastModel *> *forecast, NSError *error) {
        if (error) {
            NSLog(@"windSpeedDirectionError: %@", error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakself.lastUpdateDate timeIntervalSinceDate:start] <= 0) {
                    weakself.currentModel = model;
                    weakself.forecastModels = forecast;
                    weakself.lastUpdateDate = start;
                }
            });
        }
    }];
}

- (UIImage *)_compassImageForDiameter:(CGFloat)diameter triangleScale:(CGFloat)triangleScale rotation:(CGFloat)rotation {
    CGFloat const pathWidth = 2;

    CGRect drawRect = CGRectMake(0, 0, diameter, diameter);
    
    CGRect compassRect = CGRectInset(drawRect, pathWidth/2, pathWidth/2);
    UIBezierPath *compassDraw = [UIBezierPath bezierPathWithOvalInRect:compassRect];
    CGFloat drawRectMid = CGRectGetMidX(compassRect);
    CGFloat triangleSideLength = CGRectGetHeight(compassRect) * triangleScale;
    CGFloat triangleHeighOffset = triangleSideLength/3 + pathWidth/2;
    CGFloat triangleHeight = triangleSideLength * sin(M_PI/3.0);
    CGFloat triangleBaseSet = triangleSideLength/2;
    
    [compassDraw moveToPoint:CGPointMake(drawRectMid, triangleHeighOffset)];
    [compassDraw addLineToPoint:CGPointMake(drawRectMid + triangleBaseSet, triangleHeight + triangleHeighOffset)];
    [compassDraw addLineToPoint:CGPointMake(drawRectMid - triangleBaseSet, triangleHeight + triangleHeighOffset)];
    [compassDraw closePath];
    compassDraw.lineWidth = pathWidth;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, CGRectGetMidX(drawRect), CGRectGetMidY(drawRect));
    transform = CGAffineTransformRotate(transform, rotation);
    transform = CGAffineTransformTranslate(transform, -CGRectGetMidX(drawRect), -CGRectGetMidY(drawRect));
    [compassDraw applyTransform:transform];
    
    UIGraphicsBeginImageContextWithOptions(drawRect.size, NO, 0);
    [[UIColor lightGrayColor] setStroke];
    [compassDraw stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)rotateCompassForDirections {
    CLLocationDirection heading = self.windDirection - self.currentHeading; // (-360, +360)
    heading -= 360*floor(heading/360); // [0, 360) equivalent
    heading -= 180; // [180, 180) other way
    double headingRadians = heading * M_PI/180;
    
    self.compassImage.accessibilityValue = [NSString stringWithFormat:@"%.0f° %@",
                                            fabs(heading), signbit(heading) ? @"left" : @"right"];
    
    UIEdgeInsets contentInset;
    if (@available(watchOS 5.0, *)) {
        contentInset = self.contentSafeAreaInsets;
    } else {
        contentInset = UIEdgeInsetsZero;
    }
    
    CGRect drawRect = UIEdgeInsetsInsetRect(self.contentFrame, contentInset);
    drawRect.origin = CGPointZero;
    CGFloat minDim = fmin(drawRect.size.height, drawRect.size.width);
    self.compassImage.image = [self _compassImageForDiameter:minDim triangleScale:0.2 rotation:headingRadians];
}

@end
