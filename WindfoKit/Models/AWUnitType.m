//
//  AWUnitConverter.m
//  Windfo
//
//  Created by Leptos on 7/29/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "AWUnitType.h"

NSUnit *AWUnitTypeToUnit(AWUnitType type) {
    NSUnit *ret = nil;
    switch (type) {
        case AWUnitTypeFeet:
            ret = NSUnitLength.feet;
            break;
        case AWUnitTypeInches:
            ret = NSUnitLength.inches;
            break;
        case AWUnitTypeMiles:
            ret = NSUnitLength.miles;
            break;
        case AWUnitTypeMillimeter:
            ret = NSUnitLength.millimeters;
            break;
        case AWUnitTypeCentimeter:
            ret = NSUnitLength.centimeters;
            break;
        case AWUnitTypeMeter:
            ret = NSUnitLength.meters;
            break;
        case AWUnitTypeKilometer:
            ret = NSUnitLength.kilometers;
            break;
        case AWUnitTypeKilometersPerHour:
            ret = NSUnitSpeed.kilometersPerHour;
            break;
        case AWUnitTypeKnots:
            ret = NSUnitSpeed.knots;
            break;
        case AWUnitTypeMilesPerHour:
            ret = NSUnitSpeed.milesPerHour;
            break;
        case AWUnitTypeMetersPerSecond:
            ret = NSUnitSpeed.metersPerSecond;
            break;
        case AWUnitTypeHectoPascals:
            ret = NSUnitPressure.hectopascals;
            break;
        case AWUnitTypeInchesOfMercury:
            ret = NSUnitPressure.inchesOfMercury;
            break;
        case AWUnitTypeKiloPascals:
            ret = NSUnitPressure.kilopascals;
            break;
        case AWUnitTypeMillibars:
            ret = NSUnitPressure.millibars;
            break;
        case AWUnitTypeMillimetersOfMercury:
            ret = NSUnitPressure.millimetersOfMercury;
            break;
        case AWUnitTypePoundsPerSquareInch:
            ret = NSUnitPressure.poundsForcePerSquareInch;
            break;
        case AWUnitTypeCelsius:
            ret = NSUnitTemperature.celsius;
            break;
        case AWUnitTypeFahrenheit:
            ret = NSUnitTemperature.fahrenheit;
            break;
        case AWUnitTypeKelvin:
            ret = NSUnitTemperature.kelvin;
            break;
        case AWUnitTypePercent:
            //
            break;
        case AWUnitTypeFloat:
            //
            break;
        case AWUnitTypeInteger:
            //
            break;
        default:
            break;
    }
    return ret;
}

NSString *AWUnitTypeToString(AWUnitType type) {
    static NSMeasurementFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSMeasurementFormatter new];
        formatter.locale = NSLocale.autoupdatingCurrentLocale;
        formatter.unitStyle = NSFormattingUnitStyleLong;
    });
    return [formatter stringFromUnit:AWUnitTypeToUnit(type)];
}
