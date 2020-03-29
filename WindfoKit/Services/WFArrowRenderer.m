//
//  WFArrowRenderer.m
//  Windfo
//
//  Created by Leptos on 3/28/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import "WFArrowRenderer.h"
#import "../Models/WFArrowOverlay.h"

@implementation WFArrowRenderer

- (void)createPath {
    if ([self.overlay isKindOfClass:[WFArrowOverlay class]]) {
        WFArrowOverlay *overlay = self.overlay;
        self.path = [overlay.arrowPath CGPath];
    }
}

@end
