//
//  WFForecastController.m
//  WindfoNanoExt
//
//  Created by Leptos on 9/18/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "WFForecastController.h"

@implementation WFForecastController

+ (NSString *)rowType {
    return @"Forecast";
}

- (NSString *)_timeLabelStringForDate:(NSDate *)date {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.timeZone = NSTimeZone.localTimeZone;
        dateFormatter.locale = NSLocale.autoupdatingCurrentLocale;
        dateFormatter.calendar = NSCalendar.autoupdatingCurrentCalendar;
    });
    return [dateFormatter stringFromDate:date];
}

- (void)setModel:(WFWindForecastModel *)model {
    _model = model;
    
    self.timeLabel.text = [self _timeLabelStringForDate:model.date];
    
    self.speedLabel.text = [NSString stringWithFormat:@"%.1f G %.1f %@",
                            model.windSpeed, model.gustSpeed, model.localizedSpeedUnit];
    self.speedLabel.accessibilityLabel = [NSString stringWithFormat:@"%.1f gusting %.1f %@",
                                          model.windSpeed, model.gustSpeed, model.localizedSpeedAccessibilityUnit];
    
    self.directionLabel.text = [NSString stringWithFormat:@"%.0f %@",
                                model.windDirection, model.localizedCardinalDirection];
    self.directionLabel.accessibilityLabel = [NSString stringWithFormat:@"%.0f° %@",
                                              model.windDirection, model.localizedCardinalDirection];
    
}

@end
