//
//  WFForecastTableViewCell.m
//  Windfo
//
//  Created by Leptos on 8/10/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "WFForecastTableViewCell.h"

@implementation WFForecastTableViewCell

+ (NSString *)reusableIdentifier {
    return @"ForecastCell";
}

- (NSString *)_timeLabelStringForDate:(NSDate *)date {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        // dateFormatter.dateStyle = NSDateFormatterShortStyle;
        // dateFormatter.doesRelativeDateFormatting = YES;
        dateFormatter.timeZone = NSTimeZone.localTimeZone;
        dateFormatter.locale = NSLocale.autoupdatingCurrentLocale;
        dateFormatter.calendar = NSCalendar.autoupdatingCurrentCalendar;
    });
    return [dateFormatter stringFromDate:date];
}

- (void)setModel:(WFWindForecastModel *)model {
    _model = model;
    
    self.timeLabel.text = [self _timeLabelStringForDate:model.date];
    
    self.windLabel.text = [NSString stringWithFormat:@"%.1f G %.1f %@ %.0f %@",
                           model.windSpeed, model.gustSpeed, model.localizedSpeedUnit,
                           model.windDirection, model.localizedCardinalDirection];
    self.windLabel.accessibilityLabel = [NSString stringWithFormat:@"%.1f gusting %.1f %@, %.0f° %@",
                                         model.windSpeed, model.gustSpeed, model.localizedSpeedAccessibilityUnit,
                                         model.windDirection, model.localizedCardinalDirection];
}

@end
