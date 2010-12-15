//
//  MaskedView.h
//  Beacon
//
//  Created by Henry Cooke on 2/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PNMaskedView : UIView {
	UIView	*maskView;
}

@property( nonatomic, retain ) UIView	*maskView;

-(id)initWithMaskView:(UIView*)aMaskView;

@end
