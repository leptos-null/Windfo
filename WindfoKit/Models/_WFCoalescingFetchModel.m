//
//  _WFCoalescingFetchModel.m
//  Windfo
//
//  Created by Leptos on 11/15/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "_WFCoalescingFetchModel.h"

@implementation _WFCoalescingFetchModel {
    WFWindSpeedDirectionCompletion _completion;
}

- (instancetype)initWithCompletion:(WFWindSpeedDirectionCompletion)completionHandler {
    if (self = [self init]) {
        _completion = completionHandler;
    }
    return self;
}
// TODO: Thread safety
- (void)setCurrentModel:(WFWeatherWindModel *)currentModel {
    _currentModel = currentModel;
    if (self.forecastModels) {
        _completion(currentModel, self.forecastModels, nil);
    }
}

- (void)setForecastModels:(NSArray<WFWindForecastModel *> *)forecastModels {
    _forecastModels = forecastModels;
    if (self.currentModel) {
        _completion(self.currentModel, forecastModels, nil);
    }
}

@end
