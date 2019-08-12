//
//  WFViewController.h
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

@import UIKit;

#import "../Services/WFWeatherService.h"

typedef NS_ENUM(NSUInteger, WFCompassForecastSegment) {
    WFCompassForecastSegmentCompass,
    WFCompassForecastSegmentForecast,
    WFCompassForecastSegmentCaseCount
};

@interface WFViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *windDirectionLabel;

@property (strong, nonatomic) IBOutlet UISegmentedControl *compassForecastControl;

@property (strong, nonatomic) IBOutlet UIView *compassView;
@property (strong, nonatomic) IBOutlet UITableView *forecastTableView;

@property (nonatomic) CLLocationDirection windDirection;
@property (nonatomic) CLLocationDirection currentHeading;

@property (strong, nonatomic, readonly) CAShapeLayer *compassDrawLayer;
@property (strong, nonatomic, readonly) CAShapeLayer *directionDrawLayer;

@property (strong, nonatomic) NSDate *lastUpdateDate;
@property (strong, nonatomic) WFWeatherWindModel *currentModel;
@property (strong, nonatomic) NSArray<WFWindForecastModel *> *forecastModels;

@property (nonatomic) BOOL showingCompass;

- (void)updateLabelsForCurrentLocation;

@end
