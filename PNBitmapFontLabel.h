//
//  PNBitmapFontLabel.h
//  Created by Henry Cooke (me@prehensile.co.uk) on 1/12/10.
//
//	Uses the .fnt / .png format used in Cocos2D.
//	More info & font export tools available at:
//		http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:labels#bitmapfontatlas
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

#define PNBitmapFontNoPathException		@"NoFontPathException"

@interface PNBitmapFontGlyph : NSObject {
	NSString	*cid;
	NSInteger	x;
	NSInteger	y;
	NSInteger	width;
	NSInteger	height;
	NSInteger	xoffset;
	NSInteger	yoffset;
	NSInteger	xadvance;
	NSString	*page;
	NSInteger	chnl;
}

@property( nonatomic, copy )	NSString	*cid;
@property( nonatomic, assign )	NSInteger	x;
@property( nonatomic, assign )	NSInteger	y;
@property( nonatomic, assign )	NSInteger	width;
@property( nonatomic, assign )	NSInteger	height;
@property( nonatomic, assign )	NSInteger	xoffset;
@property( nonatomic, assign )	NSInteger	yoffset;
@property( nonatomic, assign )	NSInteger	xadvance;
@property( nonatomic, copy )	NSString	*page;
@property( nonatomic, assign )	NSInteger	chnl;

-(id)initWithString:(NSString*)lineIn;

@end


@interface PNBitmapFont : NSObject {
	NSDictionary	*dctPages;
	NSDictionary	*dctGlyphs;
	NSString		*pthFnt;
	NSInteger		lineHeight;
}
@property( nonatomic, retain )	NSDictionary	*dctPages;
@property( nonatomic, copy )	NSString		*pthFnt;
@property( nonatomic, retain )	NSDictionary	*dctGlyphs;
-(id)initWithFntFilePath:(NSString*)fntPath;
-(UIImage*)imageForString:(NSString*)inString;
@end


@interface PNBitmapFontManager : NSObject {
	NSMutableDictionary		*dctFonts;
}
@property( nonatomic, retain )	NSMutableDictionary		*dctFonts;
+(PNBitmapFontManager*)sharedInstance;
-(PNBitmapFont*)fontForFntPath:(NSString*)fntPath;
-(void)unloadFonts;
@end


@interface PNBitmapFontLabel : UILabel {
	NSString		*pthFont;
}
/**
 * The path to a .fnt file which this label will use to render text.
 */
@property( nonatomic, copy )	NSString		*pthFont;
-(id)initWithFrame:(CGRect)r fntFile:(NSString*)fntPath;
@end




