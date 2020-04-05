//
//  WFIViewController.m
//  Winficon
//
//  Created by Leptos on 4/4/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import "WFIViewController.h"

/* This project is heavily based on
 * https://github.com/leptos-null/OneTime/tree/master/oneticon
 */

#if !DEBUG
#   error This tool is not for public use
#endif

@implementation WFIViewController

- (UIImage *)iconForDimension:(CGFloat)dimension scale:(CGFloat)scale inset:(BOOL)inset fill:(BOOL)fillBackground {
    CGFloat const offset = inset ? dimension/16 : 0;
    CGRect const fullFrame = CGRectMake(0, 0, dimension, dimension);
    dimension -= (offset * 2);
    CGRect const frame = CGRectMake(offset, offset, dimension, dimension);
    
    UIGraphicsBeginImageContextWithOptions(fullFrame.size, NO, scale);
    
    [[UIColor blackColor] setFill];
    [[UIColor whiteColor] setStroke];
    
    if (fillBackground) {
        [[UIBezierPath bezierPathWithRect:fullFrame] fill];
    }
    
    [[UIBezierPath bezierPathWithOvalInRect:frame] fill];
    
    UIBezierPath *stroke = [UIBezierPath bezierPath];
    
    // reverse engineered from 1024 canvas
    CGFloat const canvasFactor = dimension/1024.0;
    
    stroke.lineWidth = 28 * canvasFactor;
    stroke.lineCapStyle = kCGLineCapRound;
    
    /* Arc: (126, 546) -> (254, 418) */
    [stroke addArcWithCenter:CGPointMake(254 * canvasFactor, 546 * canvasFactor)
                      radius:(128 * canvasFactor) startAngle:(M_PI_2 * 2) endAngle:(M_PI_2 * 3) clockwise:YES];
    
    /* Arc: (608, 418) -> (608, 158) */
    [stroke addArcWithCenter:CGPointMake(608 * canvasFactor, 288 * canvasFactor)
                      radius:(130 * canvasFactor) startAngle:(M_PI_2 * 1) endAngle:(M_PI_2 * 3) clockwise:NO];
    
    [stroke moveToPoint:CGPointMake(448 * canvasFactor, 352 * canvasFactor)];
    [stroke addLineToPoint:CGPointMake(548 * canvasFactor, 352 * canvasFactor)];
    
    [stroke moveToPoint:CGPointMake(546 * canvasFactor, 286 * canvasFactor)];
    /* Arc: (546, 286) -> (611, 351) */
    [stroke addArcWithCenter:CGPointMake(611 * canvasFactor, 286 * canvasFactor)
                      radius:(65 * canvasFactor) startAngle:(M_PI_2 * 2) endAngle:(M_PI_2 * 1) clockwise:YES];
    
    [stroke moveToPoint:CGPointMake(254 * canvasFactor, 482 * canvasFactor)];
    [stroke addLineToPoint:CGPointMake(758 * canvasFactor, 482 * canvasFactor)];
    
    [stroke moveToPoint:CGPointMake(318 * canvasFactor, 546 * canvasFactor)];
    [stroke addLineToPoint:CGPointMake(904 * canvasFactor, 546 * canvasFactor)];
    
    [stroke moveToPoint:CGPointMake(398 * canvasFactor, 610 * canvasFactor)];
    /* Arc: (722, 610) -> (722, 870) */
    [stroke addArcWithCenter:CGPointMake(722 * canvasFactor, 740 * canvasFactor)
                      radius:(130 * canvasFactor) startAngle:(M_PI_2 * 3) endAngle:(M_PI_2 * 1) clockwise:YES];
    
    [stroke moveToPoint:CGPointMake(528 * canvasFactor, 676 * canvasFactor)];
    [stroke addLineToPoint:CGPointMake(630 * canvasFactor, 676 * canvasFactor)];
    
    [stroke moveToPoint:CGPointMake(725 * canvasFactor, 675 * canvasFactor)];
    /* Arc: (725, 675) -> (660, 740) */
    [stroke addArcWithCenter:CGPointMake(725 * canvasFactor, 740 * canvasFactor)
                      radius:(65 * canvasFactor) startAngle:(M_PI_2 * 3) endAngle:(M_PI_2 * 2) clockwise:YES];
    
    [stroke stroke];
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

// e.g. "Assets.xcassets/AppIcon.appiconset"
- (void)writeIconAssetsForIconSet:(NSString *)appiconset inset:(BOOL)inset {
    NSString *manifest = [appiconset stringByAppendingPathComponent:@"Contents.json"];
    NSData *parse = [NSData dataWithContentsOfFile:manifest];
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:parse options:(NSJSONReadingMutableContainers) error:&error];
    NSArray<NSString *> *fillIdioms = @[
        @"iphone",
        @"ipad",
        @"ios-marketing",
        @"watch-marketing"
    ];
    NSArray<NSMutableDictionary<NSString *, NSString *> *> *images = dict[@"images"];
    for (NSMutableDictionary<NSString *, NSString *> *image in images) {
        NSString *scale = image[@"scale"];
        NSString *size = image[@"size"];
        NSInteger scaleLastIndex = scale.length - 1;
        assert([scale characterAtIndex:scaleLastIndex] == 'x');
        NSString *numScale = [scale substringToIndex:scaleLastIndex];
        
        NSArray<NSString *> *sizeParts = [size componentsSeparatedByString:@"x"];
        assert(sizeParts.count == 2);
        NSString *numSize = sizeParts.firstObject;
        assert([numSize isEqualToString:sizeParts.lastObject]);
        
        NSString *fileName = [NSString stringWithFormat:@"AppIcon%@@%@.png", size, scale];
        BOOL fill = [fillIdioms containsObject:image[@"idiom"]];
        UIImage *render = [self iconForDimension:numSize.doubleValue scale:numScale.doubleValue inset:inset fill:fill];
        NSData *fileData = UIImagePNGRepresentation(render);
        assert([fileData writeToFile:[appiconset stringByAppendingPathComponent:fileName] atomically:YES]);
        image[@"filename"] = fileName;
    }
    NSData *serial = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    assert([serial writeToFile:manifest atomically:YES]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *file = @__FILE__;
    NSString *projectRoot = file.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSString *mobileSet = [projectRoot stringByAppendingPathComponent:@"Windfo/Assets.xcassets/AppIcon.appiconset"];
    NSString *nanoSet = [projectRoot stringByAppendingPathComponent:@"WindfoNano/Assets.xcassets/AppIcon.appiconset"];
    [self writeIconAssetsForIconSet:mobileSet inset:YES];
    [self writeIconAssetsForIconSet:nanoSet inset:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIImageView *imageView = self.iconView;
    CGRect const rect = imageView.frame;
    imageView.image = [self iconForDimension:fmin(rect.size.width, rect.size.height) scale:0 inset:NO fill:NO];
}

@end
