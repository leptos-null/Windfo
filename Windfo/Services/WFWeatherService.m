//
//  WFWeatherService.m
//  Windfo
//
//  Created by Leptos on 11/12/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "WFWeatherService.h"
#import "../Models/_WFCoalescingFetchModel.h"

#if defined(__has_include) && __has_include("WFSecretKeys.h")
#   import "WFSecretKeys.h"
#else
#   error See README for instruction to set API key
#endif

// http://apidev.accuweather.com/developers/
#define kAccuWeatherVersion @"v1"

#ifndef kAccuWeatherHostname
#    if DEBUG
#       define kAccuWeatherHostname @"apidev.accuweather.com"
#    else
#       define kAccuWeatherHostname @"api.accuweather.com"
#    endif
#endif

NSErrorDomain const WFServiceErrorDomain = @"WFServiceErrorDomain";

@implementation WFWeatherService

+ (void)_windSpeedDirectionForInfo:(NSDictionary *)locationInfo locale:(NSLocale *)locale completion:(WFWindSpeedDirectionCompletion)completion {
    NSString *locationFile = [locationInfo[@"Key"] stringByAppendingPathExtension:@"json"];
    
    _WFCoalescingFetchModel *coalescingModel = [[_WFCoalescingFetchModel alloc] initWithCompletion:completion];
    
    // https://developer.accuweather.com/accuweather-current-conditions-api/apis/get/currentconditions/v1/%7BlocationKey%7D
    NSURLComponents *conditionComps = [NSURLComponents new];
    conditionComps.host = kAccuWeatherHostname;
    conditionComps.scheme = @"https";
    conditionComps.path = [@"/currentconditions/" kAccuWeatherVersion stringByAppendingPathComponent:locationFile];
    conditionComps.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"apikey" value:kAccuWeatherKey],
        [NSURLQueryItem queryItemWithName:@"language" value:locale.languageCode],
        [NSURLQueryItem queryItemWithName:@"details" value:@"true"]
    ];
    [[NSURLSession.sharedSession dataTaskWithURL:conditionComps.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, nil, error);
        } else {
            NSArray *conditionContainer = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                completion(nil, nil, error);
            } else {
                NSDictionary *condition = conditionContainer.firstObject;
                coalescingModel.currentModel = [[WFWeatherWindModel alloc] initWithConditions:condition locationInfo:locationInfo];
            }
        }
    }] resume];
    
    // https://developer.accuweather.com/accuweather-forecast-api/apis/get/forecasts/v1/hourly/24hour/%7BlocationKey%7D
    NSURLComponents *forecastComps = [NSURLComponents new];
    forecastComps.host = kAccuWeatherHostname;
    forecastComps.scheme = @"https";
    forecastComps.path = [@"/forecasts/" kAccuWeatherVersion "/hourly/24hour" stringByAppendingPathComponent:locationFile];
    forecastComps.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"apikey" value:kAccuWeatherKey],
        [NSURLQueryItem queryItemWithName:@"language" value:locale.languageCode],
        [NSURLQueryItem queryItemWithName:@"details" value:@"true"],
        [NSURLQueryItem queryItemWithName:@"metric" value:locale.usesMetricSystem ? @"true" : @"false"]
    ];
    [[NSURLSession.sharedSession dataTaskWithURL:forecastComps.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, nil, error);
        } else {
            NSArray *forecastInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSMutableArray<WFWindForecastModel *> *forecastModels = [NSMutableArray arrayWithCapacity:forecastInfo.count];
            for (NSDictionary *detailDict in forecastInfo) {
                [forecastModels addObject:[[WFWindForecastModel alloc] initWithDetailDictionary:detailDict]];
            }
            coalescingModel.forecastModels = [forecastModels copy];
        }
    }] resume];
};

+ (void)windSpeedDirectionForLocation:(CLLocation *)location locale:(NSLocale *)locale completion:(WFWindSpeedDirectionCompletion)completion {
    if (!completion) {
        return;
    }
    if (!locale) {
        locale = NSLocale.currentLocale;
    }
    
    NSString *mainQuery = nil;
    NSString *locationEndpoint = nil;
    if (location) {
        CLLocationCoordinate2D coordinates = location.coordinate;
        mainQuery = [NSString stringWithFormat:@"%f,%f", coordinates.latitude, coordinates.longitude];
        locationEndpoint = @"/locations/" kAccuWeatherVersion "/geoposition/search.json";
    } else {
        mainQuery = nil;
        locationEndpoint = @"/locations/" kAccuWeatherVersion "/cities/ipaddress.json";
    }
    
    // https://developer.accuweather.com/accuweather-locations-api/apis/get/locations/v1/cities/geoposition/search
    // https://developer.accuweather.com/accuweather-locations-api/apis/get/locations/v1/cities/ipaddress
    NSURLComponents *urlComps = [NSURLComponents new];
    urlComps.host = kAccuWeatherHostname;
    urlComps.scheme = @"https";
    urlComps.path = locationEndpoint;
    urlComps.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"q" value:mainQuery],
        [NSURLQueryItem queryItemWithName:@"apikey" value:kAccuWeatherKey],
        [NSURLQueryItem queryItemWithName:@"language" value:locale.languageCode]
    ];
    
    [[NSURLSession.sharedSession dataTaskWithURL:urlComps.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        id body = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            completion(nil, nil, error);
            return;
        }
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *casted = (NSHTTPURLResponse *)response;
            if (casted.statusCode != 200) {
                completion(nil, nil, [NSError errorWithDomain:@"AWHTTPErrorDomain" code:[body[@"Code"] integerValue] userInfo:@{
                    NSLocalizedDescriptionKey : body[@"Message"]
                }]);
                return;
            }
        }
        NSDictionary *realInfo = nil;
        if ([body isKindOfClass:[NSDictionary class]]) {
            realInfo = body;
        } else if ([body isKindOfClass:[NSArray class]]) {
            realInfo = [body firstObject];
        } else {
            NSCAssert(0, @"Unknown JSON object: %@", body);
        }
        if (realInfo == nil) {
            completion(nil, nil, [NSError errorWithDomain:WFServiceErrorDomain code:2 userInfo:@{
                NSLocalizedDescriptionKey : @"No locations found"
            }]);
            return;
        }
        [self _windSpeedDirectionForInfo:realInfo locale:locale completion:completion];
    }] resume];
}

@end
