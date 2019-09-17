//
//  _WFCoalescingFetchModel.h
//  Windfo
//
//  Created by Leptos on 11/15/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

@import Foundation;

#import "WFWeatherWindModel.h"
#import "WFWindForecastModel.h"
#import "../Services/WFWeatherService.h"

@interface _WFCoalescingFetchModel : NSObject

@property (strong, nonatomic) WFWeatherWindModel *currentModel;
@property (strong, nonatomic) NSArray<WFWindForecastModel *> *forecastModels;

- (instancetype)initWithCompletion:(WFWindSpeedDirectionCompletion)completionHandler;

@end
