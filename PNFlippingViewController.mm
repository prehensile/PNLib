//
//  PNFlippingViewController.m
//  Created by Henry Cooke (me@prehensile.co.uk) on 15/12/10.
//
//	Requires iOS 3.0+
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

#import "PNFlippingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Image.h"

@implementation PNFlippingViewController

@synthesize flipsideViewController;


-(void)showFlipside:(BOOL)bShowFlipside animated:(BOOL)bAnimated{
	
	if( bShowFlipside ){
	
		// setup image context
		UIView *v = self.view;
		CGRect bounds = v.bounds;
		CGFloat scale = 0.5;
		CGSize sz = CGSizeMake( bounds.size.width * scale, bounds.size.height * scale );
		UIGraphicsBeginImageContext( sz );
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		
		// draw current view, flipped
		CGContextSaveGState( ctx );
		CGContextTranslateCTM( ctx, sz.width, 0 );
		CGContextScaleCTM( ctx, -scale, scale );
		[ v.layer renderInContext: ctx ];
		CGContextRestoreGState( ctx );
		
		// get image
		UIImage *fi = UIGraphicsGetImageFromCurrentImageContext();
		
		// blur image
		ImageWrapper *wrapper = Image::createImage( fi, sz.width, sz.height );
		UIImage *blurred = wrapper.image->gaussianBlur().image->toUIImage();
		
		// draw blurred image, darkend, flipped rightside-up from uiimage
		/*CGContextSetBlendMode( ctx, kCGBlendModeDarken );
		CGContextSetAlpha( ctx, 0.75 );
		CGContextTranslateCTM( ctx, 0, sz.height );
		CGContextScaleCTM( ctx, 1, -1 );
		CGContextDrawImage( ctx, CGRectMake(0, 0, sz.width, sz.height), blurred.CGImage );
		
		// get image & finish
		fi = UIGraphicsGetImageFromCurrentImageContext();*/
		
		fi = blurred;
		UIGraphicsEndImageContext();
		
		// set flipside image on flipsideviewController
		if( self.flipsideViewController == nil ){
			PNFlipsideViewController *pvc = [ [PNFlipsideViewController alloc ] init ];
			self.flipsideViewController = pvc;
			[ pvc release ];
		}
		self.flipsideViewController.parentFlippingViewController = self;
		self.flipsideViewController.flipsideImage = fi;
		
		self.flipsideViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[ self presentModalViewController:self.flipsideViewController animated: bAnimated ];

	} else {
		[ self dismissModalViewControllerAnimated: bAnimated ];
	}
}

-(void)dealloc {
	[ self.flipsideViewController release ];
    [super dealloc];
}

@end


@implementation PNFlipsideViewController

@synthesize flipsideImage;
@synthesize flipsideImageView;
@synthesize parentFlippingViewController;


-(void)dealloc{
	[ self.flipsideImage release ];
	[ self.flipsideImageView release ];
	[ super dealloc ];
}

-(void)setFlipsideImage:(UIImage *)imageIn{
	[ imageIn retain ];
	[ flipsideImage release ];
	flipsideImage = imageIn;
	
	if( self.flipsideImageView == nil ){
		UIImageView *uiv = [[ UIImageView alloc ] initWithImage: nil ];
		//uiv.alpha = 0.5;
		[ self.view addSubview: uiv ];
		self.flipsideImageView = uiv;
		[ uiv release ];
	}
	self.flipsideImageView.image = imageIn;
	self.flipsideImageView.frame = self.view.bounds;
}

-(void)dismiss:(BOOL)animated{
	if( self.parentFlippingViewController != nil ){
		[ self.parentFlippingViewController showFlipside: NO animated: animated ];
	}
}

@end

