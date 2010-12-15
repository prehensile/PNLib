//
//  PNFlippingViewController.h
//
//  Created by Henry Cooke on 15/12/10.
//

@class PNFlippingViewController;


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
	PNFlipsideViewController		*flipsideViewController;
}

@property( nonatomic, retain )	PNFlipsideViewController		*flipsideViewController;

-(void)showFlipside:(BOOL)bShowFlipside animated:(BOOL)bAnimated;

@end