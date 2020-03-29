//
//  WFViewController.h
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "../../WindfoKit/Services/WFWeatherService.h"
#import "../../WindfoKit/Models/WFArrowOverlay.h"

typedef NS_ENUM(NSUInteger, WFSegmentIndex) {
    WFSegmentIndexCompass,
    WFSegmentIndexMap,
    WFSegmentIndexForecast,
    WFSegmentIndexCaseCount
};

@interface WFViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *windDirectionLabel;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (strong, nonatomic) IBOutlet UIView *compassView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *forecastTableView;

@property (nonatomic) CLLocationDirection windDirection;
@property (nonatomic) CLLocationDirection currentHeading;

@property (strong, nonatomic, readonly) CAShapeLayer *compassDrawLayer;
@property (strong, nonatomic, readonly) CAShapeLayer *directionDrawLayer;

@property (strong, nonatomic) NSDate *lastUpdateDate;
@property (strong, nonatomic) WFWeatherWindModel *currentModel;
@property (strong, nonatomic) NSArray<WFWindForecastModel *> *forecastModels;
@property (strong, nonatomic) WFArrowOverlay *arrowOverlay;

- (void)updateLabelsForCurrentLocation;

@end
