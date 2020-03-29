//
//  WFHeaderArithmetic.h
//  Windfo
//
//  Created by Leptos on 3/28/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#ifndef WFHeaderArithmetic_h
#define WFHeaderArithmetic_h

#define WFDegreesInCircle 360.0
#define WFRadiansInCircle (2 * M_PI)

// converts an angle value in radians to degrees
#define r2d(r) (((r)*WFDegreesInCircle)/WFRadiansInCircle)
// converts an angle value in degrees to radians
#define d2r(d) (((d)*WFRadiansInCircle)/WFDegreesInCircle)

/// Constrict a given value (positive or negative) into the range [0, b),
/// where the returned value is an interval offset of v
static inline double constrictValueBound(double v, double b) {
    return v - b*floor(v/b);
}

#endif /* WFHeaderArithmetic_h */
