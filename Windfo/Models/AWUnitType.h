//
//  AWUnitConverter.h
//  Windfo
//
//  Created by Leptos on 7/29/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

// AccuWeather descibed UnitTypes: https://apidev.accuweather.com/developers/unitTypes
typedef NS_ENUM(NSInteger, AWUnitType) {
    AWUnitTypeFeet,
    AWUnitTypeInches,
    AWUnitTypeMiles,
    AWUnitTypeMillimeter,
    AWUnitTypeCentimeter,
    AWUnitTypeMeter,
    AWUnitTypeKilometer,
    AWUnitTypeKilometersPerHour,
    AWUnitTypeKnots,
    AWUnitTypeMilesPerHour,
    AWUnitTypeMetersPerSecond,
    AWUnitTypeHectoPascals,
    AWUnitTypeInchesOfMercury,
    AWUnitTypeKiloPascals,
    AWUnitTypeMillibars,
    AWUnitTypeMillimetersOfMercury,
    AWUnitTypePoundsPerSquareInch,
    AWUnitTypeCelsius,
    AWUnitTypeFahrenheit,
    AWUnitTypeKelvin,
    AWUnitTypePercent,
    AWUnitTypeFloat,
    AWUnitTypeInteger
};

NSUnit *AWUnitTypeToUnit(AWUnitType);
NSString *AWUnitTypeToString(AWUnitType);
