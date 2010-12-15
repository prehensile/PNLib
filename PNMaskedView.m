//
//  MaskedView.m
//  Beacon
//
//  Created by Henry Cooke on 2/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNMaskedView.h"
#import <QuartzCore/QuartzCore.h>


@implementation PNMaskedView

@synthesize maskView;


-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
		self.opaque = NO;
    }
    return self;
}

-(id)initWithMaskView:(UIView*)aMaskView{
	if (self = [ self initWithFrame: aMaskView.frame ]) {
		self.maskView = aMaskView;
		self.layer.mask = aMaskView.layer;
    }
    return self;
}

-(void)dealloc{
	[ self.maskView release ];
	[ super dealloc ];
}

@end
