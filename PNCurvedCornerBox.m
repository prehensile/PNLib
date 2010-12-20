//
//  PNCurvedCornerBox.m
//  Created by Henry Cooke (me@prehensile.co.uk) on 20/12/10.
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

#import "PNCurvedCornerBox.h"

@implementation PNCurvedCornerBox

@synthesize cornerRadius;
@synthesize	borderColor;
@synthesize	borderWidth;
@synthesize	gradientLayer;
@synthesize	gradientTopColor;
@synthesize	gradientBottomColor;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void)setCornerRadius:(CGFloat)rad{
	cornerRadius = rad;
	self.layer.cornerRadius = rad;
	if( gradientLayer != nil ) gradientLayer.cornerRadius = rad;
}

-(void)setBorderColor:(UIColor*)c{
	[ c retain ];
	[ borderColor release ];
	borderColor = c;
	self.layer.borderColor = c.CGColor;
}

-(void)setBorderWidth:(CGFloat)w{
	borderWidth = w;
	self.layer.borderWidth = w;
}

-(CAGradientLayer*)gradientLayer{
	if( gradientLayer == nil ){
		gradientLayer = [[ CAGradientLayer alloc ] init ];
		gradientLayer.frame = self.layer.bounds;
		gradientLayer.cornerRadius = self.layer.cornerRadius;
		UIView *holder = [[ UIView alloc ] initWithFrame: self.bounds ];
		[ holder.layer addSublayer: gradientLayer ];
		[ self insertSubview: holder atIndex: 0 ];
		[ holder release ];
	}
	return( gradientLayer );
}

-(void)setVerticalGradient:(NSArray*)colors{
	CAGradientLayer *gradient = self.gradientLayer;
	gradient.colors = colors;
	gradient.startPoint = CGPointMake(0.0, 0.0);
	gradient.endPoint = CGPointMake(0.0, 1.0 );
}

-(void)setGradientTopColor:(UIColor *)c{
	[ c retain ];
	[ gradientTopColor release ];
	gradientTopColor = c;
	
	CGColorRef bottomColor = ( self.gradientBottomColor == nil ) ? self.backgroundColor.CGColor : self.gradientBottomColor.CGColor;
	NSArray *colors = [ [NSArray alloc] initWithObjects: (id)c.CGColor, bottomColor, nil ];
	[ self setVerticalGradient: colors ];
	[ colors release ];
	
}

-(void)setGradientBottomColor:(UIColor *)c{
	[ c retain ];
	[ gradientBottomColor release ];
	gradientBottomColor = c;
	
	CGColorRef topColor = ( self.gradientTopColor == nil ) ? self.backgroundColor.CGColor : self.gradientTopColor.CGColor;
	NSArray *colors = [ [NSArray alloc] initWithObjects: (id)topColor, c.CGColor, nil ];
	[ self setVerticalGradient: colors ];
	[ colors release ];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[ self.borderColor release ];
	[ self.gradientLayer release ];
	[ self.gradientTopColor release ];
	[ self.gradientBottomColor release ];
    [super dealloc];
}


@end
