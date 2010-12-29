//
//  PNFlippingViewController.h
//  Created by Henry Cooke (me@prehensile.co.uk) on 15/12/10.
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

@class PNFlippingViewController;

#define	kPNFlippingViewControllerTransitionDuration		1.0

@interface PNFlipsideViewController : UIViewController {
	UIImage						*flipsideImage;
	UIImageView					*flipsideImageView;
	PNFlippingViewController	*parentFlippingViewController;
}

@property( nonatomic, retain ) 	UIImage						*flipsideImage;
@property( nonatomic, retain ) 	UIImageView					*flipsideImageView;
@property( nonatomic, assign ) 	PNFlippingViewController	*parentFlippingViewController;

-(void)dismiss:(BOOL)animated;

@end;


@interface PNFlippingViewController : UIViewController {
	UIView							*holdingView;
	PNFlipsideViewController		*_flipsideViewControllerInternal;
	UIViewController				*flipsideViewController;
}

@property( nonatomic, retain )	PNFlipsideViewController		*_flipsideViewControllerInternal;
@property( nonatomic, retain )	UIViewController				*flipsideViewController;
@property( nonatomic, retain ) 	UIView							*holdingView;

-(void)showFlipside:(BOOL)bShowFlipside animated:(BOOL)bAnimated;

@end