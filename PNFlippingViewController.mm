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
@synthesize _flipsideViewControllerInternal;
@synthesize holdingView;


-(void)beginFlipAnimation{
	
	// perform first half of flip animation
	CATransform3D t = CATransform3DIdentity;
	t.m34 = 1.0 / -500;
	t = CATransform3DRotate( t, -M_PI*0.45, 0.0, 1.0, 0.0 );
	
	[ UIView beginAnimations: @"PNFlippingViewController" context: nil ];
	[ UIView setAnimationDuration: kPNFlippingViewControllerTransitionDuration * 0.5 ];
	//[ UIView setAnimationCurve: UIViewAnimationCurveEaseIn ];
	[ UIView setAnimationDelegate: self ];
	[ UIView setAnimationDidStopSelector: @selector(onFirstAnimationComplete:finished:context:) ];
	self.view.layer.transform = t;
	[ UIView commitAnimations ];
}

-(void)onFirstAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	
	/* perform second half of flip animation */
	
	// switch VCs
	if( [ self._flipsideViewControllerInternal.view.superview isEqual: self.view ] ){
		// flipside view is showing, detach it
		[ self._flipsideViewControllerInternal.view removeFromSuperview ];
		self._flipsideViewControllerInternal = nil;
		// reattach views from holdingView
		for( UIView *v in self.holdingView.subviews ){
			[ self.view addSubview: v ];
		}
		self.holdingView = nil;
		[ self viewWillAppear: YES ];
	} else {
		// flipside view is about to show, detach all subviews into holdingview
		UIView *v;
		if( self.holdingView == nil ){
			v = [[ UIView alloc ] initWithFrame: self.view.bounds ];
			self.holdingView = v;
			[ v release ];
		}
		for( UIView *v in self.view.subviews ){
			[ holdingView addSubview: v ];
		}
		// attach flipside view
		[ self._flipsideViewControllerInternal.view addSubview: self.flipsideViewController.view ];
		[ self.view addSubview: self._flipsideViewControllerInternal.view ];
		[ self.flipsideViewController viewWillAppear: YES ];
	}
	
	// setup transform
	CATransform3D t = CATransform3DIdentity;
	t.m34 = 1.0 / -500;
	//t = CATransform3DRotate( t, 0.0, 0.0, 0.0, 0.0 );
	t = CATransform3DRotate( t, M_PI*0.45, 0.0, 1.0, 0.0 );
	self.view.layer.transform = t;
	
	// animate
	t = CATransform3DIdentity;
	t.m34 = 1.0 / -500;
	t = CATransform3DRotate( t, 0.0, 0.0, 0.0, 0.0 );
	[ UIView beginAnimations: @"PNFlippingViewController" context: nil ];
	[ UIView setAnimationDuration: kPNFlippingViewControllerTransitionDuration * 0.5 ];
	[ UIView setAnimationCurve: UIViewAnimationCurveEaseOut ];
	self.view.layer.transform = t;
	[ UIView commitAnimations ];
}

-(void)showFlipside:(BOOL)bShowFlipside animated:(BOOL)bAnimated{
	
	if( bShowFlipside ){
	
		// setup image context
		UIView *v = self.view;
		CGRect bounds = v.bounds;
		CGFloat scale = 0.25;
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
		CGContextSetAlpha( ctx, 0.75 );*/
		CGContextTranslateCTM( ctx, 0, sz.height );
		CGContextScaleCTM( ctx, 1, -1 );
		CGRect imageRect = CGRectMake(0, 0, sz.width, sz.height);
		CGContextDrawImage( ctx, imageRect, blurred.CGImage );
		CGContextSetFillColorWithColor( ctx, [ UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.2 ].CGColor );
		CGContextFillRect( ctx, imageRect );
									   
		// get image & finish context
		fi = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		// set flipside image on flipsideviewController
		if( self._flipsideViewControllerInternal == nil ){
			PNFlipsideViewController *pvc = [ [PNFlipsideViewController alloc ] init ];
			self._flipsideViewControllerInternal = pvc;
			[ pvc release ];
		}
		self._flipsideViewControllerInternal.parentFlippingViewController = self;
		self._flipsideViewControllerInternal.flipsideImage = fi;
	} 
	
	// flip using custom animation instead of presentModalViewController
	[ self beginFlipAnimation ];
}

-(void)dealloc {
	[ self.holdingView release ];
	[ self.flipsideViewController release ];
	[ self._flipsideViewControllerInternal release ];
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

-(void)viewWillAppear:(BOOL)animated{
	
}

-(void)dismiss:(BOOL)animated{
	if( self.parentFlippingViewController != nil ){
		[ self.parentFlippingViewController showFlipside: NO animated: animated ];
	}
}

@end

