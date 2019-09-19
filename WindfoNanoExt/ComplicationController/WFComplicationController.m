//
//  WFComplicationController.m
//  WindfoNanoExt
//
//  Created by Leptos on 9/18/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "WFComplicationController.h"

@implementation WFComplicationController

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication
                                            withHandler:(void(^)(CLKComplicationTimeTravelDirections))handler {
    handler(CLKComplicationTimeTravelDirectionNone);
}

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication
                                   withHandler:(void(^)(CLKComplicationTimelineEntry *))handler {
    handler(nil);
}

@end
