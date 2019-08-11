//
//  WFForecastTableViewCell.h
//  Windfo
//
//  Created by Leptos on 8/10/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/WFWindForecastModel.h"

@interface WFForecastTableViewCell : UITableViewCell

@property (class, strong, nonatomic, readonly) NSString *reusableIdentifier;

@property (strong, nonatomic) WFWindForecastModel *model;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *windLabel;

@end
