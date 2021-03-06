//
//  PNMaskedView.h
//  Created by Henry Cooke (me@prehensile.co.uk) on 2/11/10.
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

#import <UIKit/UIKit.h>


@interface PNMaskedView : UIView {
	UIView	*maskView;
}

@property( nonatomic, retain ) UIView	*maskView;

-(id)initWithMaskView:(UIView*)aMaskView;

@end
