//
//  WFWeatherWindModel.m
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "WFWeatherWindModel.h"
#import "AWUnitType.h"

@implementation WFWeatherWindModel

- (instancetype)initWithConditions:(NSDictionary *)conditions locationInfo:(NSDictionary *)locationInfo {
    if (self = [self init]) {
        NSDictionary *windInfo = conditions[@"Wind"];
        NSDictionary *gustInfo = conditions[@"WindGust"][@"Speed"];
        NSDictionary *speedInfo = windInfo[@"Speed"];
        NSDictionary *metricInfo = speedInfo[@"Metric"];
        NSDictionary *imperialInfo = speedInfo[@"Imperial"];
        NSDictionary *directionInfo = windInfo[@"Direction"];
        
        NSTimeInterval timestamp = [conditions[@"EpochTime"] doubleValue];
        
        _metricSpeed = [metricInfo[@"Value"] doubleValue];
        _imperialSpeed = [imperialInfo[@"Value"] doubleValue];
        _metricGust = [gustInfo[@"Metric"][@"Value"] doubleValue];
        _imperialGust = [gustInfo[@"Imperial"][@"Value"] doubleValue];
        _localizedMetricUnit = metricInfo[@"Unit"];
        _localizedImperialUnit = imperialInfo[@"Unit"];
        _localizedMetricAccessibilityUnit = AWUnitTypeToString([metricInfo[@"UnitType"] integerValue]);
        _localizedImperialAccessibilityUnit = AWUnitTypeToString([imperialInfo[@"UnitType"] integerValue]);
        _direction = [directionInfo[@"Degrees"] doubleValue];
        _localizedCardinalDirection = directionInfo[@"Localized"];
        _updateTime = [NSDate dateWithTimeIntervalSince1970:timestamp];
        _localizedLocationName = locationInfo[@"LocalizedName"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %.2f %@ %.2f %@", self.class, self,
            self.imperialSpeed, self.localizedImperialUnit, self.direction, self.localizedCardinalDirection];
}

@end
