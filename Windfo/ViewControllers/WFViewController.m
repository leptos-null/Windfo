//
//  WFViewController.m
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "WFViewController.h"
#import "../Views/WFForecastTableViewCell.h"
#import "../../WindfoKit/Services/WFArrowRenderer.h"
#import "../../WindfoKit/Services/WFHeaderArithmetic.h"

@implementation WFViewController

// MARK: - UIViewController overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WFLocationService *locationService = WFLocationService.sharedService;
    [locationService requestLocationPermissions];
    __weak typeof(self) weakself = self;
    [locationService addCallbackForLocationChange:^(CLLocation *location) {
        [weakself updateLabelsForCurrentLocation];
    }];
    [locationService addCallbackForHeadingChange:^(CLLocationDirection heading) {
        weakself.currentHeading = heading;
    }];
    
    self.mapView.camera.altitude = 1000;
    
    UIRefreshControl *tableRefresh = [UIRefreshControl new];
    self.forecastTableView.refreshControl = tableRefresh;
    
    SEL const reloadAction = @selector(updateLabelsForCurrentLocation);
    NSNotificationCenter *notifCenter = NSNotificationCenter.defaultCenter;
    [notifCenter addObserver:self selector:reloadAction name:NSCurrentLocaleDidChangeNotification object:nil];
    [tableRefresh addTarget:self action:reloadAction forControlEvents:UIControlEventValueChanged];
    
    // TODO(UI) Look into these line widths
    //   should they adjust to the view size?
    //   should the directionDrawLayer be thinner?
    CAShapeLayer *compassDrawLayer = [CAShapeLayer layer];
    _compassDrawLayer = compassDrawLayer;
    compassDrawLayer.lineWidth = 1.5;
    compassDrawLayer.lineCap = kCALineCapRound;
    compassDrawLayer.lineJoin = kCALineJoinRound;
    compassDrawLayer.fillColor = UIColor.clearColor.CGColor;
    [self.compassView.layer addSublayer:compassDrawLayer];
    
    CAShapeLayer *directionDrawLayer = [CAShapeLayer layer];
    _directionDrawLayer = directionDrawLayer;
    directionDrawLayer.lineWidth = 1.5;
    directionDrawLayer.lineCap = kCALineCapRound;
    directionDrawLayer.lineJoin = kCALineJoinRound;
    directionDrawLayer.fillColor = UIColor.clearColor.CGColor;
    [compassDrawLayer addSublayer:directionDrawLayer];
    
    [self _updateCompassStrokeColors];
    
    BOOL canShowCompass = CLLocationManager.headingAvailable;
    
    UISegmentedControl *segmentControl = self.segmentControl;
    [segmentControl setEnabled:canShowCompass forSegmentAtIndex:WFSegmentIndexCompass];
    segmentControl.selectedSegmentIndex = canShowCompass ? WFSegmentIndexCompass : WFSegmentIndexMap;
    [self segmentControlChanged:segmentControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    WFLocationService *locationService = WFLocationService.sharedService;
    [locationService startUpdatingLocation];
    if (self.segmentControl.selectedSegmentIndex == WFSegmentIndexCompass) {
        [locationService startUpdatingHeading];
    }
    
    [self updateLabelsForCurrentLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    WFLocationService *locationService = WFLocationService.sharedService;
    [locationService stopUpdatingLocation];
    [locationService stopUpdatingHeading];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // BUG: when this is called, sometimes the bounds of our view of interest is not updated
    [self _updateCompassDrawing];
}

// MARK: UITraitEnvironment

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self _updateCompassStrokeColors];
        }
    }
}

// MARK: - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView == self.forecastTableView);
    NSParameterAssert(indexPath.section == 0);
    
    WFForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[WFForecastTableViewCell reusableIdentifier]];
    cell.model = self.forecastModels[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSParameterAssert(tableView == self.forecastTableView);
    NSParameterAssert(section == 0);
    return self.forecastModels.count;
}

// MARK: - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[WFArrowOverlay class]]) {
        WFArrowRenderer *renderer = [[WFArrowRenderer alloc] initWithOverlay:overlay];
        renderer.fillColor = UIColor.systemTealColor;
        renderer.strokeColor = UIColor.systemBlueColor;
        renderer.lineWidth = 2;
        return renderer;
    }
    return nil;
}

// MARK: - Setter overrides

- (void)setCurrentHeading:(CLLocationDirection)currentHeading {
    _currentHeading = currentHeading;
    [self rotateCompassForDirections];
}

- (void)setWindDirection:(CLLocationDirection)windDirection {
    _windDirection = windDirection;
    [self rotateCompassForDirections];
}

- (void)setForecastModels:(NSArray<WFWindForecastModel *> *)forecastModels {
    _forecastModels = forecastModels;
    [self.forecastTableView reloadData];
}

- (void)setCurrentModel:(WFWeatherWindModel *)currentModel {
    _currentModel = currentModel;
    
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
        dateFormatter.timeZone = NSTimeZone.localTimeZone;
        dateFormatter.locale = NSLocale.autoupdatingCurrentLocale;
        dateFormatter.calendar = NSCalendar.autoupdatingCurrentCalendar;
    });
    
    self.windDirection = currentModel.direction;
    
    self.locationLabel.text = currentModel.localizedLocationName;
    self.locationLabel.accessibilityValue = currentModel.localizedLocationName;
    self.timeLabel.text = [dateFormatter stringFromDate:currentModel.updateTime];
    
    BOOL useMetric = NSLocale.currentLocale.usesMetricSystem;
    self.windSpeedLabel.text = [NSString stringWithFormat:@"%.1f G %.1f %@",
        useMetric ? currentModel.metricSpeed : currentModel.imperialSpeed,
        useMetric ? currentModel.metricGust : currentModel.imperialGust,
        useMetric ? currentModel.localizedMetricUnit : currentModel.localizedImperialUnit];
    self.windSpeedLabel.accessibilityValue = [NSString stringWithFormat:@"%.1f gusting %.1f %@",
        useMetric ? currentModel.metricSpeed : currentModel.imperialSpeed,
        useMetric ? currentModel.metricGust : currentModel.imperialGust,
        useMetric ? currentModel.localizedMetricAccessibilityUnit : currentModel.localizedImperialAccessibilityUnit];
    self.windDirectionLabel.text = [NSString stringWithFormat:@"%.0f° %@",
                                    currentModel.direction, currentModel.localizedCardinalDirection];
}

- (void)setArrowOverlay:(WFArrowOverlay *)arrowOverlay {
    MKMapView *mapView = self.mapView;
    WFArrowOverlay *previousOverlay = self.arrowOverlay;
    if (previousOverlay) {
        [mapView removeOverlay:previousOverlay];
    }
    
    _arrowOverlay = arrowOverlay;
    [mapView addOverlay:arrowOverlay level:MKOverlayLevelAboveRoads];
}

// MARK: - Public methods

- (IBAction)updateLabelsForCurrentLocation {
    UIRefreshControl *tableRefreshControl = self.forecastTableView.refreshControl;
    if (!tableRefreshControl.refreshing) {
        [tableRefreshControl beginRefreshing];
    }
    
    CLLocation *location = WFLocationService.sharedService.location;
    NSDate *start = [NSDate date];
    __weak typeof(self) weakself = self;
    [WFWeatherService windSpeedDirectionForLocation:location locale:nil completion:^(WFWeatherWindModel *model, NSArray<WFWindForecastModel *> *forecast, NSError *error) {
        if (error) {
            NSLog(@"windSpeedDirectionError: %@", error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakself.lastUpdateDate timeIntervalSinceDate:start] <= 0) {
                    weakself.currentModel = model;
                    weakself.forecastModels = forecast;
                    weakself.lastUpdateDate = start;
                    
                    WFArrowOverlay *arrow = [[WFArrowOverlay alloc] initWithCenter:location.coordinate];
                    // `direction` is where the wind is coming from,
                    // but we want to point in the direction the wind is going
                    arrow.arrowDirection = self.currentModel.direction - WFDegreesInCircle/2;
                    weakself.arrowOverlay = arrow;
                    
                    weakself.mapView.camera.centerCoordinate = location.coordinate;
                    
                    [tableRefreshControl endRefreshing];
                }
            });
        }
    }];
}

- (IBAction)segmentControlChanged:(UISegmentedControl *)segmentControl {
    [self updateLabelsForCurrentLocation];
    
    switch (segmentControl.selectedSegmentIndex) {
        case WFSegmentIndexCompass:
            [WFLocationService.sharedService startUpdatingHeading];
            self.compassView.hidden = NO;
            self.mapView.hidden = YES;
            self.forecastTableView.hidden = YES;
            break;
        case WFSegmentIndexMap:
            [WFLocationService.sharedService stopUpdatingHeading];
            self.compassView.hidden = YES;
            self.mapView.hidden = NO;
            self.forecastTableView.hidden = YES;
            break;
        case WFSegmentIndexForecast:
            [WFLocationService.sharedService stopUpdatingHeading];
            self.compassView.hidden = YES;
            self.mapView.hidden = YES;
            self.forecastTableView.hidden = NO;
            break;
        default:
            NSLog(@"Unknown segmentIndex: %@", segmentControl);
            break;
    }
}

// MARK: - Compass updates

- (void)rotateCompassForDirections {
    CLLocationDirection heading = self.windDirection - self.currentHeading; // (-360, +360)
    heading = constrictValueBound(heading, WFDegreesInCircle); // [0, 360) equivalent
    heading -= WFDegreesInCircle/2; // [180, 180) other way
    double headingRadians = d2r(heading);
    self.compassView.transform = CGAffineTransformMakeRotation(headingRadians);
    
    self.compassView.accessibilityValue = [NSString stringWithFormat:@"%.0f° %@",
                                           fabs(heading), signbit(heading) ? @"left" : @"right"];
}

- (void)_updateCompassDrawing {
    CGRect drawRect = self.compassView.bounds;
    drawRect.origin = CGPointZero;
    UIBezierPath *compassDraw = [UIBezierPath bezierPathWithOvalInRect:drawRect];
    self.compassDrawLayer.path = compassDraw.CGPath;
    CGFloat compassCircumference = CGRectGetWidth(drawRect) * M_PI;
    CGFloat lineWorkArea = compassCircumference/90;
    // doing this instead of @[1, 9] makes the dashes grow subtly
    self.compassDrawLayer.lineDashPattern = @[ @(lineWorkArea*0.1), @(lineWorkArea*0.9) ];
    // self.compassDrawLayer.lineDashPattern = @[ @(1), @(9) ];
    
    UIBezierPath *triangleDraw = [UIBezierPath bezierPath];
    CGFloat drawRectMid = CGRectGetMidX(drawRect);
    CGFloat triangleSideLength = CGRectGetHeight(drawRect)/5;
    CGFloat triangleHeighOffset = triangleSideLength/4;
    CGFloat triangleHeight = triangleSideLength * sin(M_PI/3.0);
    CGFloat triangleBaseSet = triangleSideLength/2;
    
    [triangleDraw moveToPoint:CGPointMake(drawRectMid, triangleHeighOffset)];
    [triangleDraw addLineToPoint:CGPointMake(drawRectMid + triangleBaseSet, triangleHeight + triangleHeighOffset)];
    [triangleDraw addLineToPoint:CGPointMake(drawRectMid - triangleBaseSet, triangleHeight + triangleHeighOffset)];
    [triangleDraw closePath];
    self.directionDrawLayer.path = triangleDraw.CGPath;
}

- (void)_updateCompassStrokeColors {
    UIColor *strokeColor;
    if (@available(iOS 13.0, *)) {
        strokeColor = UIColor.labelColor;
    } else {
        strokeColor = UIColor.darkTextColor;
    }
    
    _compassDrawLayer.strokeColor = strokeColor.CGColor;
    _directionDrawLayer.strokeColor = strokeColor.CGColor;
}

@end
