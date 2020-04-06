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

typedef NS_ENUM(NSUInteger, WFIBackgroundStyle) {
    /// Fill the entire background
    WFIBackgroundStyleFill,
    /// Fill a circle inside the inset
    WFIBackgroundStyleCircle,
    /// No fill
    WFIBackgroundStyleGlyph,
};

@implementation WFIViewController

- (UIImage *)iconForDimension:(CGFloat)dimension scale:(CGFloat)scale inset:(BOOL)inset background:(WFIBackgroundStyle)style {
    CGFloat const offset = inset ? dimension/16 : 0;
    CGRect const fullFrame = CGRectMake(0, 0, dimension, dimension);
    dimension -= (offset * 2);
    CGRect const frame = CGRectMake(offset, offset, dimension, dimension);
    
    UIGraphicsBeginImageContextWithOptions(fullFrame.size, NO, scale);
    
    [[UIColor blackColor] setFill];
    [[UIColor whiteColor] setStroke];
    
    UIBezierPath *fillPath = nil;
    switch (style) {
        case WFIBackgroundStyleFill:
            fillPath = [UIBezierPath bezierPathWithRect:fullFrame];
            break;
        case WFIBackgroundStyleCircle:
            fillPath = [UIBezierPath bezierPathWithOvalInRect:frame];
            break;
        default:
            break;
    }
    [fillPath fill];
    
    UIBezierPath *stroke = [UIBezierPath bezierPath];
    
    // reverse engineered from 1024 canvas
    CGFloat const canvasFactor = dimension/1024.0;
    
    stroke.lineWidth = 28 * canvasFactor;
    stroke.lineCapStyle = kCGLineCapRound;
    
    /* Arc: (126, 546) -> (254, 418) */
    [stroke addArcWithCenter:CGPointMake(254 * canvasFactor + offset, 546 * canvasFactor + offset)
                      radius:(128 * canvasFactor) startAngle:(M_PI_2 * 2) endAngle:(M_PI_2 * 3) clockwise:YES];
    
    /* Arc: (608, 418) -> (608, 158) */
    [stroke addArcWithCenter:CGPointMake(608 * canvasFactor + offset, 288 * canvasFactor + offset)
                      radius:(130 * canvasFactor) startAngle:(M_PI_2 * 1) endAngle:(M_PI_2 * 3) clockwise:NO];
    
    [stroke moveToPoint:CGPointMake(448 * canvasFactor + offset, 352 * canvasFactor + offset)];
    [stroke addLineToPoint:CGPointMake(548 * canvasFactor + offset, 352 * canvasFactor + offset)];
    
    [stroke moveToPoint:CGPointMake(546 * canvasFactor + offset, 286 * canvasFactor + offset)];
    /* Arc: (546, 286) -> (611, 351) */
    [stroke addArcWithCenter:CGPointMake(611 * canvasFactor + offset, 286 * canvasFactor + offset)
                      radius:(65 * canvasFactor) startAngle:(M_PI_2 * 2) endAngle:(M_PI_2 * 1) clockwise:YES];
    
    [stroke moveToPoint:CGPointMake(254 * canvasFactor + offset, 482 * canvasFactor + offset)];
    [stroke addLineToPoint:CGPointMake(758 * canvasFactor + offset, 482 * canvasFactor + offset)];
    
    [stroke moveToPoint:CGPointMake(318 * canvasFactor + offset, 546 * canvasFactor + offset)];
    [stroke addLineToPoint:CGPointMake(904 * canvasFactor + offset, 546 * canvasFactor + offset)];
    
    [stroke moveToPoint:CGPointMake(398 * canvasFactor + offset, 610 * canvasFactor + offset)];
    /* Arc: (722, 610) -> (722, 870) */
    [stroke addArcWithCenter:CGPointMake(722 * canvasFactor + offset, 740 * canvasFactor + offset)
                      radius:(130 * canvasFactor) startAngle:(M_PI_2 * 3) endAngle:(M_PI_2 * 1) clockwise:YES];
    
    [stroke moveToPoint:CGPointMake(528 * canvasFactor + offset, 676 * canvasFactor + offset)];
    [stroke addLineToPoint:CGPointMake(630 * canvasFactor + offset, 676 * canvasFactor + offset)];
    
    [stroke moveToPoint:CGPointMake(725 * canvasFactor + offset, 675 * canvasFactor + offset)];
    /* Arc: (725, 675) -> (660, 740) */
    [stroke addArcWithCenter:CGPointMake(725 * canvasFactor + offset, 740 * canvasFactor + offset)
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
        WFIBackgroundStyle style = fill ? WFIBackgroundStyleFill : WFIBackgroundStyleCircle;
        UIImage *render = [self iconForDimension:numSize.doubleValue scale:numScale.doubleValue inset:inset background:style];
        NSData *fileData = UIImagePNGRepresentation(render);
        assert([fileData writeToFile:[appiconset stringByAppendingPathComponent:fileName] atomically:YES]);
        image[@"filename"] = fileName;
    }
    NSData *serial = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    assert([serial writeToFile:manifest atomically:YES]);
}

// return a string because it's used in the file name.
// if a float is returned, the caller would be responsible formatting into a string
- (NSString *)_sizeForComplicationRole:(NSString *)role screen:(NSString *)screenWidth {
    // https://developer.apple.com/design/human-interface-guidelines/watchos/icons-and-images/complication-images/
    // as of early April 2020
    //   "<=145" -> 38mm
    //   ">161" -> 40mm
    //   ">145" -> 42mm
    //   ">183" -> 44mm
    NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *lookup = @{
        @"circular" : @{
                @"<=145" : @"16",
                @">161"  : @"18",
                @">145"  : @"18",
                @">183"  : @"20",
        },
        @"extra-large" : @{
                @"<=145" : @"91",
                @">161"  : @"101.5",
                @">145"  : @"101.5",
                @">183"  : @"112",
        },
        @"graphic-bezel" : @{
                @"<=145" : @"42",
                @">161"  : @"42",
                @">145"  : @"42",
                @">183"  : @"47",
        },
        @"graphic-circular" : @{
                @"<=145" : @"42",
                @">161"  : @"42",
                @">145"  : @"42",
                @">183"  : @"47",
        },
        @"graphic-corner" : @{
                @"<=145" : @"20",
                @">161"  : @"20",
                @">145"  : @"20",
                @">183"  : @"22",
        },
        @"graphic-large-rectangular" : @{ /* not square */
                @"<=145" : @"20", /* 75x47 */
                @">161"  : @"47", /* 150x47 */
                @">145"  : @"47", /* 150x47 */
                @">183"  : @"54", /* 171x54 */
        },
        @"modular" : @{
                @"<=145" : @"26",
                @">161"  : @"29",
                @">145"  : @"29",
                @">183"  : @"32",
        },
        @"utilitarian" : @{
                @"<=145" : @"20",
                @">161"  : @"22",
                @">145"  : @"22",
                @">183"  : @"25",
        }
    };
    NSDictionary *family = lookup[role];
    assert(family != nil);
    NSString *screen = family[screenWidth];
    assert(screen != nil);
    return screen;
}

- (void)_writeComplicationGlyphForImageSet:(NSString *)imageSet role:(NSString *)role {
    NSString *manifest = [imageSet stringByAppendingPathComponent:@"Contents.json"];
    NSData *parse = [NSData dataWithContentsOfFile:manifest];
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:parse options:(NSJSONReadingMutableContainers) error:&error];
    for (NSMutableDictionary<NSString *, NSString *> *image in dict[@"images"]) {
        NSString *scale = image[@"scale"];
        assert(scale != nil);
        NSInteger scaleLastIndex = scale.length - 1;
        assert([scale characterAtIndex:scaleLastIndex] == 'x');
        NSString *numScale = [scale substringToIndex:scaleLastIndex];
        
        NSString *screenWidth = image[@"screen-width"];
        if (screenWidth == nil) {
            continue;
        }
        NSString *size = [self _sizeForComplicationRole:role screen:screenWidth];
        
        NSString *fileName = [NSString stringWithFormat:@"AppGlyph%1$@x%1$@@%2$@.png", size, scale];
        WFIBackgroundStyle style = WFIBackgroundStyleGlyph;
        UIImage *render = [self iconForDimension:size.doubleValue scale:numScale.doubleValue inset:NO background:style];
        NSData *fileData = UIImagePNGRepresentation(render);
        assert([fileData writeToFile:[imageSet stringByAppendingPathComponent:fileName] atomically:YES]);
        image[@"filename"] = fileName;
    }
    NSData *serial = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    assert([serial writeToFile:manifest atomically:YES]);
}

// e.g. "Assets.xcassets/Complication.complicationset"
- (void)writeIconAssetsForComplicationSet:(NSString *)complicationset {
    NSString *manifest = [complicationset stringByAppendingPathComponent:@"Contents.json"];
    NSData *parse = [NSData dataWithContentsOfFile:manifest];
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:parse options:0 error:&error];
    for (NSDictionary *asset in dict[@"assets"]) {
        NSString *imageset = [complicationset stringByAppendingPathComponent:asset[@"filename"]];
        [self _writeComplicationGlyphForImageSet:imageset role:asset[@"role"]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *file = @__FILE__;
    NSString *projectRoot = file.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSString *mobileSet = [projectRoot stringByAppendingPathComponent:@"Windfo/Assets.xcassets/AppIcon.appiconset"];
    NSString *nanoSet = [projectRoot stringByAppendingPathComponent:@"WindfoNano/Assets.xcassets/AppIcon.appiconset"];
    NSString *glyphSet = [projectRoot stringByAppendingPathComponent:@"WindfoNanoExt/Assets.xcassets/"
                          "Complication.complicationset"];
    [self writeIconAssetsForIconSet:mobileSet inset:NO];
    [self writeIconAssetsForIconSet:nanoSet inset:NO];
    [self writeIconAssetsForComplicationSet:glyphSet];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIImageView *imageView = self.iconView;
    CGRect const rect = imageView.frame;
    WFIBackgroundStyle style = WFIBackgroundStyleCircle;
    imageView.image = [self iconForDimension:fmin(rect.size.width, rect.size.height) scale:0 inset:NO background:style];
}

@end
