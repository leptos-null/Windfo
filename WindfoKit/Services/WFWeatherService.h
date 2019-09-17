//
//  WFWeatherService.h
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

@import Foundation;

#import "WFLocationService.h"
#import "../Models/WFWeatherWindModel.h"
#import "../Models/WFWindForecastModel.h"

FOUNDATION_EXPORT NSErrorDomain const WFServiceErrorDomain;

typedef void(^WFWindSpeedDirectionCompletion)(WFWeatherWindModel *, NSArray<WFWindForecastModel *> *, NSError *);

@interface WFWeatherService : NSObject

+ (void)windSpeedDirectionForLocation:(CLLocation *)location locale:(NSLocale *)locale completion:(WFWindSpeedDirectionCompletion)completion;

@end
