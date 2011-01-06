//
//  PNMath.h
//  Created by Henry Cooke (me@prehensile.co.uk) on 06/01/2011.
//
//	Various useful math bits
//
/*
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * You can obtain a copy of the license at http://www.sun.com/cddl/cddl.html
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * Copyright 2010 Henry Cooke.  All rights reserved.
 * Use is subject to license terms.
 */

struct PNPolarCoordinate {
	double t;
	double r;
};
typedef struct PNPolarCoordinate PNPolarCoordinate;

@interface PNMath : NSObject {

}

+(double)degreesToRadians:(double)degrees;
+(double)radiansToDegrees:(double)radians;

+(PNPolarCoordinate)pointToPolar:(CGPoint)pt withPole:(CGPoint)pole;
+(CGPoint)polarToPoint:(PNPolarCoordinate)pc withPole:(CGPoint)pole;

@end
