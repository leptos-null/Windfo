//
//  WFWeatherWindModel.h
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

@import CoreLocation;

@interface WFWeatherWindModel : NSObject

@property (nonatomic, readonly) double metricSpeed;
@property (nonatomic, readonly) double imperialSpeed;

@property (nonatomic, readonly) double metricGust;
@property (nonatomic, readonly) double imperialGust;

@property (strong, nonatomic, readonly) NSString *localizedMetricUnit;
@property (strong, nonatomic, readonly) NSString *localizedImperialUnit;

@property (strong, nonatomic, readonly) NSString *localizedMetricAccessibilityUnit;
@property (strong, nonatomic, readonly) NSString *localizedImperialAccessibilityUnit;

@property (nonatomic, readonly) CLLocationDirection direction;
@property (strong, nonatomic, readonly) NSString *localizedCardinalDirection;

@property (strong, nonatomic, readonly) NSDate *updateTime;

@property (strong, nonatomic, readonly) NSString *localizedLocationName;

- (instancetype)initWithConditions:(NSDictionary *)conditions locationInfo:(NSDictionary *)locationInfo;

@end
