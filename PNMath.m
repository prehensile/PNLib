//
//  PNMath.m
//  Beacon
//
//  Created by Henry Cooke on 6/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PNMath.h"


@implementation PNMath

+(double)degreesToRadians:(double)degrees{
	return( degrees * 0.01745327 ); // degrees * pi over 180
}

+(double)radiansToDegrees:(double)radians{
	return( radians * 57.2957795 ); // radians * 180 over pi
}

+(PNPolarCoordinate)pointToPolar:(CGPoint)pt withPole:(CGPoint)pole{
	float bearing = atan2f(  pt.y - pole.y, pt.x - pole.x );
	float dx = pt.x - pole.x;
	float dy = pt.y - pole.y;
	float distance = sqrtf( (dx*dx) + (dy*dy) );
	PNPolarCoordinate pc;
	pc.t = bearing;
	pc.r = distance;
	return( pc );
}

+(CGPoint)polarToPoint:(PNPolarCoordinate)pc withPole:(CGPoint)pole{
	CGPoint pt;
	pt.x = pole.x + ( cosf( pc.t ) * pc.r );
	pt.y = pole.y + ( sinf( pc.t ) * pc.r );
	return( pt );
}

@end
