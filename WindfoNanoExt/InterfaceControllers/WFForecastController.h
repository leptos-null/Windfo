//
//  WFForecastController.h
//  WindfoNanoExt
//
//  Created by Leptos on 9/18/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "../../WindfoKit/Models/WFWindForecastModel.h"

@interface WFForecastController : NSObject

@property (class, strong, nonatomic, readonly) NSString *rowType;

@property (strong, nonatomic) WFWindForecastModel *model;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *speedLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *directionLabel;

@end
