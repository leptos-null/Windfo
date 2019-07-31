//
//  WFWindForecastModel.m
//  Windfo
//
//  Created by Leptos on 11/14/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "WFWindForecastModel.h"
#import "AWUnitType.h"

@implementation WFWindForecastModel

- (instancetype)initWithDetailDictionary:(NSDictionary *)dictionary {
    if (self = [self init]) {
        _date = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"EpochDateTime"] doubleValue]];
        
        NSNumber *gustValue = dictionary[@"WindGust"][@"Speed"][@"Value"];
        _gustSpeed = [gustValue doubleValue];
        
        NSDictionary *windTop = dictionary[@"Wind"];
        NSDictionary *windSpeedTop = windTop[@"Speed"];
        NSDictionary *windDirectionTop = windTop[@"Direction"];
        
        _windSpeed = [windSpeedTop[@"Value"] doubleValue];
        _windDirection = [windDirectionTop[@"Degrees"] doubleValue];
        
        _localizedSpeedUnit = windSpeedTop[@"Unit"];
        _localizedSpeedAccessibilityUnit = AWUnitTypeToString([windSpeedTop[@"UnitType"] integerValue]);
        _localizedCardinalDirection = windDirectionTop[@"Localized"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %.2f G %.2f %@, %.0f %@", self.class, self, self.windSpeed, self.gustSpeed,
            self.localizedSpeedUnit, self.windDirection, self.localizedCardinalDirection];
}

@end
