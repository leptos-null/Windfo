//
//  WFWindForecastModel.h
//  Windfo
//
//  Created by Leptos on 11/14/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

@import CoreLocation;

@interface WFWindForecastModel : NSObject

@property (nonatomic, readonly) double windSpeed;
@property (nonatomic, readonly) double gustSpeed;
@property (nonatomic, readonly) CLLocationDirection windDirection;

@property (strong, nonatomic, readonly) NSString *localizedCardinalDirection;
@property (strong, nonatomic, readonly) NSString *localizedSpeedUnit;
@property (strong, nonatomic, readonly) NSString *localizedSpeedAccessibilityUnit;

@property (strong, nonatomic, readonly) NSDate *date;

- (instancetype)initWithDetailDictionary:(NSDictionary *)dictionary;

@end
