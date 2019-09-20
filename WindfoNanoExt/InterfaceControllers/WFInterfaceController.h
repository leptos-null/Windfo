//
//  WFInterfaceController.h
//  WindfoNanoExt
//
//  Created by Leptos on 9/16/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <WatchKit/WatchKit.h>

#import "../../WindfoKit/Services/WFWeatherService.h"

@interface WFInterfaceController : WKInterfaceController

@property (strong, nonatomic) NSDate *lastUpdateDate;
@property (strong, nonatomic) WFWeatherWindModel *currentModel;
@property (strong, nonatomic) NSArray<WFWindForecastModel *> *forecastModels;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *locationLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *windSpeedLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *windDirectionLabel;

@property (strong, nonatomic) IBOutlet WKInterfaceImage *compassImage;

@property (strong, nonatomic) IBOutlet WKInterfaceTable *forecastTable;

@property (nonatomic) BOOL showingCompass;

@property (nonatomic) CLLocationDirection windDirection;
@property (nonatomic) CLLocationDirection currentHeading;

@end
