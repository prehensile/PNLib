//
//  PNFlippingViewController.m
//
//  Created by Henry Cooke on 15/12/10.
//
//	Requires iOS 3.0+
// 

#import "PNFlippingViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation PNFlippingViewController

@synthesize flipsideViewController;


-(void)showFlipside:(BOOL)bShowFlipside animated:(BOOL)bAnimated{
	
	if( bShowFlipside ){
	
		// draw current view to flipside image, mirrored horizontally
		UIView *v = self.view;
		CGRect bounds = v.bounds;
		CGFloat scale = 0.25;
		CGSize sz = CGSizeMake( bounds.size.width * scale, bounds.size.height * scale );
		UIGraphicsBeginImageContext( sz );
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM( ctx, sz.width, 0 );
		CGContextScaleCTM( ctx, -scale, scale );
		[ v.layer renderInContext: ctx ];
		// darken
		CGContextSetBlendMode( ctx, kCGBlendModeDarken );
		[ v.layer renderInContext: ctx ];
		
		UIImage *fi = UIGraphicsGetImageFromCurrentImageContext();
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
		uiv.alpha = 0.5;
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

