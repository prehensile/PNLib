//
//  PNBitmapFontLabel.m
//  Created by Henry Cooke (me@prehensile.co.uk) on 1/12/10.
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


#import "PNBitmapFontLabel.h"
#import <QuartzCore/CALayer.h>


@implementation PNBitmapFontControlCharacter

@synthesize chr;

-(id)initWithCharacter:(unichar)inChr{
	if ( self = [super init] ) {
		self.chr = inChr;
	}
	return( self );
}

@end


@implementation PNBitmapFontGlyph

@synthesize cid;
@synthesize x;
@synthesize y;
@synthesize width;
@synthesize height;
@synthesize xoffset;
@synthesize yoffset;
@synthesize xadvance;
@synthesize page;
@synthesize chnl;

-(id)initWithString:(NSString*)lineIn{
	if( self=[ super init ] ){
		
		NSArray *components = [ lineIn componentsSeparatedByString:@" " ];
		NSUInteger l = [ components count ] -1;
		NSString *component;
		NSArray *parts;
		NSUInteger numParts = 0;
		NSInteger intValue;
		
		for( NSUInteger i=0; i< l; i++ ){
			
			component = [ components objectAtIndex: i ];
			if( [ component length ] > 0 ){
				
				parts = [ component componentsSeparatedByString:@"=" ];
				
				if( numParts > 0 ) intValue = [[ parts objectAtIndex: 1 ] intValue ];
				
				switch ( numParts++ ) {
					case 1:
						self.cid = [ NSString stringWithFormat:@"%d", intValue ];
					case 2:
						x = intValue; 
						break;
					case 3:
						y = intValue; 
						break;
					case 4:
						width = intValue; 
						break;
					case 5:
						height = intValue; 
						break;
					case 6:
						xoffset = intValue; 
						break;
					case 7:
						yoffset = intValue; 
						break;
					case 8:
						xadvance = intValue; 
						break;
					case 9:
						self.page = [ NSString stringWithFormat:@"%d", intValue ]; 
						break;
					case 10:
						chnl = intValue; 
						break;
				}
				
			}
		}
	}
	return( self );
}

-(void)dealloc{
	[ self.cid release ];
	[ self.page release ];
	[ super dealloc ];
}

@end


@implementation PNBitmapFont

@synthesize pthFnt;
@synthesize dctPages;
@synthesize dctGlyphs;
@synthesize dctGlyphCache;


-(id)initWithFntFilePath:(NSString*)fntPath{
	if( self=[super init] ){
		self.pthFnt = fntPath;
		self.dctPages = nil;
		self.dctGlyphs = nil;
		self.dctGlyphCache = nil;
		lineHeight = 0;
	}
	return( self );
}

-(void)releaseCFImageDictionary:(NSDictionary*)dctIn{
	CGImageRef img;
	for( NSString *key in dctIn ){
		img = (CGImageRef)[ (NSValue*)[ dctIn objectForKey: key ] nonretainedObjectValue ];
		CGImageRelease( img );
	}
}

-(void)dealloc{
	[ self.pthFnt release ];
	if( self.dctGlyphCache != nil ){
		[ self releaseCFImageDictionary: self.dctGlyphCache ];
		[ self.dctGlyphCache release ];
	}
	if( self.dctPages != nil ){
		[ self releaseCFImageDictionary: self.dctPages ];
		[ self.dctPages release ];
	}
	[ self.dctGlyphs release ];
	[ super dealloc ];
}

-(void)loadParseFont{
	
	if( self.pthFnt == nil ){
		// no font path, throw an exception
		NSException *exception = [ NSException exceptionWithName: PNBitmapFontNoPathException
														  reason: @"PNBitmapFont has no font path"
														userInfo: nil ];
		[ exception raise ];
		return;
	}
	
	// working vars
	NSError *err = nil;
	NSString *strFnt = [ NSString stringWithContentsOfFile: self.pthFnt usedEncoding: nil error: &err ];
	
	if( err == nil ){
		
		NSUInteger idxStart = 0;
		NSUInteger idxEnd =0;
		NSRange lineRange = NSMakeRange( 0, 1 );
		NSUInteger l = [ strFnt length ];
		NSString *line;
		NSArray *parts;
		NSString *scratchString;
		NSMutableDictionary *pagesOut = [[ NSMutableDictionary alloc ] init ];
		NSMutableDictionary *glyphsOut = [[ NSMutableDictionary alloc ] init ];
		CGDataProviderRef srcPage;
		CGImageRef imgPage;
		NSFileManager *fm = [ NSFileManager defaultManager ];
		NSData *datPage;
		PNBitmapFontGlyph *glyph;
		
		while( idxEnd < l ){
			
			// get line
			[ strFnt getLineStart: &idxStart end: &idxEnd contentsEnd: nil forRange: lineRange ];
			lineRange.location = idxStart;
			lineRange.length = idxEnd - idxStart;
			line = [ strFnt substringWithRange: lineRange ];
			
			parts = [ line componentsSeparatedByString:@" " ];
			// get line header
			scratchString = [ parts objectAtIndex: 0 ];
			if( [ scratchString isEqualToString: @"common" ] ){
				/* parse common line*/
				scratchString = [[ [ parts objectAtIndex: 1 ] componentsSeparatedByString:@"=" ] objectAtIndex: 1 ];
				lineHeight = [ scratchString intValue ];
			} else if( [ scratchString isEqualToString: @"page" ] ){
				/* parse a page line */
				// get page filename
				scratchString = [[ [ parts objectAtIndex: 2 ] componentsSeparatedByString:@"\"" ] objectAtIndex: 1 ];
				scratchString = [ [ self.pthFnt stringByDeletingLastPathComponent ] stringByAppendingPathComponent: scratchString ];
				// load
				datPage = [ fm contentsAtPath: scratchString ];
				if( datPage != nil ){
					srcPage = CGDataProviderCreateWithCFData( (CFDataRef)datPage );
					if( srcPage != nil ){
						imgPage = CGImageCreateWithPNGDataProvider( srcPage, NULL, NO, kCGRenderingIntentDefault );  
						if( imgPage != nil ){
							// save to pages dict
							scratchString = [[ [ parts objectAtIndex: 1 ] componentsSeparatedByString:@"=" ] objectAtIndex: 1 ];
							[ pagesOut setObject: [ NSValue valueWithNonretainedObject: (id)imgPage ] forKey: scratchString ];
						}
					}
				}
			} else if( [ scratchString isEqualToString: @"char" ] ){
				// parse a glpyh line
				glyph = [[ PNBitmapFontGlyph alloc ] initWithString: line ];
				scratchString = [[[ parts objectAtIndex: 1 ] componentsSeparatedByString:@"=" ] objectAtIndex: 1 ];
				[ glyphsOut setObject: glyph forKey: scratchString ];
				[ glyph release ];
			}
			
			// advance line
			lineRange.location = idxEnd;
			lineRange.length = 1;
		}
		
		self.dctGlyphs = [[ NSDictionary alloc ] initWithDictionary: glyphsOut ];
		[ glyphsOut release ];
		
		self.dctPages = [ [ NSDictionary alloc ] initWithDictionary: pagesOut ];
		[ pagesOut release ];
	}
}

-(UIImage*)imageForString:(NSString*)inString
				textColor:(UIColor*)textColor
				 numberOfLines:(NSInteger)numLinesIn
			lineBreakMode:(UILineBreakMode)lineBreakMode{
	
	if( self.dctGlyphs == nil ) [ self loadParseFont ];
	
	// may still be nil if load failed
	if( self.dctGlyphs != nil ){
		
		// working vars
		NSInteger i=0,x=0,y=0,w=0,h=0;
		NSInteger xMargin=0,minXMargin=0,yMargin=0,maxLineWidth=0,lineWidth=0;
		NSInteger l = [ inString length ];
		NSInteger numLines = 1;
		unichar chr;
		NSMutableArray *glyphs = [[ NSMutableArray alloc ] initWithCapacity: l ];
		id glyph;
		PNBitmapFontGlyph *g;
		PNBitmapFontControlCharacter *cc;
		
		// first pass: calculate width & get glyphs
		for( i=0; i<l; i++ ){
			glyph = nil;
			// get a character
			chr = [ inString characterAtIndex: i ];
			if( chr < 0x20 ){ // control character
				switch ( chr ) {
					case 0x0A: // newline
						if( ( numLinesIn > 0 ) && ( numLines + 1 > numLinesIn ) ){
							l=i; // don't parse any more glyphs & set length for drawing pass
						} else {
							if( lineWidth > maxLineWidth )  maxLineWidth = lineWidth;
							lineWidth = 0;
							numLines++;
						}
						break;
				}
				if( i <l ){
					// if we didn't just abort
					glyph = [[ PNBitmapFontControlCharacter alloc ] initWithCharacter: chr ];
				}
			} else {
				// regular character, get a glyph from parsed table
				g = [ dctGlyphs objectForKey: [ NSString stringWithFormat:@"%d", chr ] ];
				if( g != nil ){
					if( lineWidth == 0 ){
						if( g.xoffset < 0 ){
							xMargin = g.xoffset;
							lineWidth -= xMargin;
							if( xMargin < minXMargin ) minXMargin = xMargin;
						}
						if( (numLines==1) & (g.yoffset<0) ){
							yMargin = g.yoffset;
							h -= yMargin;
						}
					}
					lineWidth += g.xadvance;
					glyph = g;
				}
			}
			// add glyph to working array
			if( glyph != nil ) [ glyphs addObject: glyph ];
		}
		w = maxLineWidth;
		xMargin = minXMargin;
		h = lineHeight * numLines;
		
		/* second pass: render glyphs */
		
		// working vars
		UIImage *imageOut = nil;
		CGImageRef imgGlyph, imgPage;
		UIGraphicsBeginImageContext( CGSizeMake( w, h ) );
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextTranslateCTM( context, 0.0, h );
		CGContextScaleCTM( context, 1.0, -1.0 );
		
		if( context != nil ){
			
			/* step through glyphs */
			if( self.dctGlyphCache == nil ){
				NSMutableDictionary *glyphCache = [[ NSMutableDictionary alloc ] init ];
				self.dctGlyphCache = glyphCache;
				[ glyphCache release ];
			}
			y = yMargin;
			x = xMargin;
			for ( i=0; i<l; i++) {
				glyph = [ glyphs objectAtIndex: i ];
				if( [ glyph isMemberOfClass: [ PNBitmapFontGlyph class ] ] ){
					// bitmap glyph, render it
					g = (PNBitmapFontGlyph*)glyph;
					if( g.width > 0 && g.height > 0 ){
						imgPage = (CGImageRef)[ (NSValue*)[ dctPages objectForKey: g.page ] nonretainedObjectValue ];
						imgGlyph = (CGImageRef)[ (NSValue*)[ dctGlyphCache objectForKey: g.cid ] nonretainedObjectValue ];
						if( imgGlyph == nil ){
							imgGlyph = CGImageCreateWithImageInRect( imgPage, CGRectMake(g.x, g.y, g.width, g.height ) );
							[ dctGlyphCache setObject: [ NSValue valueWithNonretainedObject: (id)imgGlyph ] forKey: g.cid ];
						}
						CGContextDrawImage( context, CGRectMake( x + g.xoffset, y+h-g.height-g.yoffset, g.width, g.height ), imgGlyph );
					}
					x+= g.xadvance;
				} else if( [ glyph isMemberOfClass: [ PNBitmapFontControlCharacter class ] ] ){
					// control character, act on it
					cc = (PNBitmapFontControlCharacter*)glyph;
					switch ( cc.chr ) {
						case 0x0A: // newline
							x = xMargin;
							y -= lineHeight;
							// TODO: implement lineBreakModes
							break;
					}
				}
			}
			
			/* render context to image */
			CGImageRef cgOut = CGBitmapContextCreateImage( context );
			
			// clear context
			CGRect imageRect = CGRectMake(0, 0, w, h);
			CGContextClearRect( context, imageRect );
			// set clipping mask to rendered text image
			CGContextClipToMask( context, imageRect, cgOut );
			// fill in textColor
			CGContextSetFillColorWithColor( context, textColor.CGColor );
			CGContextFillRect( context, imageRect );	
			CGImageRelease( cgOut );
			// now return
			cgOut = CGBitmapContextCreateImage( context );
			imageOut = [ [UIImage alloc] initWithCGImage: cgOut ];
			CGImageRelease( cgOut );
			
		}
		UIGraphicsEndImageContext();
		[ glyphs release ];
		
		return( [ imageOut autorelease ] );
	}
	
	return nil;
}

@end


@implementation PNBitmapFontManager

@synthesize dctFonts;

static PNBitmapFontManager *_sharedInstance = nil;
+(PNBitmapFontManager*)sharedInstance{
	if( _sharedInstance == nil ){
		_sharedInstance = [[ PNBitmapFontManager alloc ] init ];
	}
	return( _sharedInstance );
}

-(PNBitmapFont*)fontForFontName:(NSString*)fontName{
	// create master font dictionary, if needed
	if( self.dctFonts == nil ){
		NSMutableDictionary *dct = [[ NSMutableDictionary alloc ] init ];
		self.dctFonts = dct;
		[ dct release ];
	}
	// fetch font from master, if already loaded
	PNBitmapFont *font = [ self.dctFonts objectForKey: fontName ];
	if( font == nil ){
		// font not loaded, load it
		NSString *fntPath = nil;
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
			if( [[UIScreen mainScreen] scale] == 2 )
				// retina display (or 2x ipad)
				fntPath = [[ NSBundle mainBundle ] pathForResource: [ fontName stringByAppendingString:@"@2x"] ofType: @"fnt" ];
		if( fntPath == nil ) fntPath = [[ NSBundle mainBundle ] pathForResource: fontName ofType: @"fnt" ];
		font = [[ PNBitmapFont alloc ] initWithFntFilePath: fntPath ];
		[ self.dctFonts setObject: font forKey: fontName ];
	}
	return( font );
}

-(void)unloadFonts{
	[ self.dctFonts release ];
	self.dctFonts = nil;
}

-(void)dealloc{
	[ self unloadFonts ];
	[ super dealloc ];
}

@end


@implementation PNBitmapFontLabel

@synthesize fontName;

-(id)initWithFrame:(CGRect)r fontName:(NSString*)inFontName{
	if( self = [ super initWithFrame: r ] ){
		self.fontName = inFontName;
		// set layer shadow to UILabel defaults
		self.layer.shadowRadius = 0.0;
		self.layer.shadowOffset = CGSizeMake( 0.0, -2.0 );
	}
	return( self );
}

-(void)setShadowColor:(UIColor *)color{
	self.layer.shadowColor = color.CGColor;
	[ super setShadowColor: color ];
}

-(void)drawRect:(CGRect)rect{
	
	if( self.fontName != nil ){
		// get font from font manager
		PNBitmapFont *font = [[ PNBitmapFontManager sharedInstance ] fontForFontName: self.fontName ];
		if( font != nil ){
			// render text
			UIImage *textImage = [ font imageForString: self.text
											 textColor: self.textColor
										 numberOfLines: self.numberOfLines
										 lineBreakMode: self.lineBreakMode ];
			if( textImage != nil ){
				// construct display rect for text
				CGPoint pt = rect.origin;
				CGSize rsz = rect.size;
				CGSize isz = textImage.size;
				CGRect r = CGRectMake( pt.x, pt.y, isz.width, isz.height );
				// align rendered text
				switch ( self.textAlignment ) {
					case UITextAlignmentRight:
						r.origin.x = floorf( rect.origin.x + rsz.width - r.size.width );
						break;
					case UITextAlignmentCenter:
						r.origin.x = floorf( rect.origin.x + (rsz.width*0.5) - (r.size.width*0.5) );
						break;
				}
				// center vertically, same as UILabel
				r.origin.y = floorf( rect.origin.y + (rsz.height*0.5)-(r.size.height*0.5) );
				// draw rendered text in constructed rect
				[ textImage drawInRect: r ];
				return;
			}
		}
	}
	
	// fallback
	[ super drawRect: rect ];
}

-(void)dealloc{
	[ self.fontName release ];
	[ super dealloc ];
}

@end


