//
//  PNBitmapFontLabel.m
//
//  Created by Henry Cooke on 1/12/10.
//

#import "PNBitmapFontLabel.h"
#import <QuartzCore/CALayer.h>


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

-(id)initWithFntFilePath:(NSString*)fntPath{
	if( self=[super init] ){
		self.pthFnt = fntPath;
		self.dctPages = nil;
		self.dctGlyphs = nil;
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
	[ self releaseCFImageDictionary: self.dctPages ];
	[ self.dctPages release ];
	[ self.dctGlyphs release ];
	[ super dealloc ];
}

-(void)loadParseFont{
	
	// working vars
	NSString *strFnt = [ NSString stringWithContentsOfFile: self.pthFnt usedEncoding: nil error: nil ];
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

-(UIImage*)imageForString:(NSString*)inString{
	
	if( self.dctGlyphs == nil ) [ self loadParseFont ];
	
	NSUInteger i=0,x=0,y=0,w=0;
	NSUInteger h = lineHeight;
	NSUInteger l = [ inString length ];
	
	// first pass: calculate width & get glyphs
	unichar chr;
	NSMutableArray *glyphs = [[ NSMutableArray alloc ] initWithCapacity: l ];
	PNBitmapFontGlyph *glyph;
	for( i=0; i<l; i++ ){
		chr = [ inString characterAtIndex: i ];
		glyph = [ dctGlyphs objectForKey: [ NSString stringWithFormat:@"%d", chr ] ];
		if( glyph != nil ){
			[ glyphs addObject: glyph ];
			w+= glyph.xadvance;
			if( i == 0 ){
				if( glyph.xoffset < 0 ){
					w += -glyph.xoffset;
					x += -glyph.xoffset;
				}
			}
		}
	}
	
	/* second pass: render glyphs */
	
	// working vars
	UIImage *imageOut = nil;
	CGImageRef imgGlyph, imgPage;
	UIGraphicsBeginImageContext( CGSizeMake( w, h ) );
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if( context != nil ){
		
		// step through glpyhs
		NSMutableDictionary *glyphCache = [[ NSMutableDictionary alloc ] init ];
		for ( i=0; i<l; i++) {
			glyph = [ glyphs objectAtIndex: i ];
			imgPage = (CGImageRef)[ (NSValue*)[ dctPages objectForKey: glyph.page ] nonretainedObjectValue ];
			imgGlyph = (CGImageRef)[ (NSValue*)[ glyphCache objectForKey: glyph.cid ] nonretainedObjectValue ];
			if( imgGlyph == nil ){
				imgGlyph = CGImageCreateWithImageInRect( imgPage, CGRectMake(glyph.x, glyph.y, glyph.width, glyph.height ) );
				[ glyphCache setObject: [ NSValue valueWithNonretainedObject: (id)imgGlyph ] forKey: glyph.cid ];
			}
			CGContextDrawImage( context, CGRectMake( x + glyph.xoffset, y + glyph.yoffset, glyph.width, glyph.height ), imgGlyph );
			x+= glyph.xadvance;
		}
		[ self releaseCFImageDictionary: glyphCache ];
		[ glyphCache release ]; 
		
		// render context to image
		CGImageRef cgOut = CGBitmapContextCreateImage( context );
		// clear context
		CGRect imageRect = CGRectMake(0, 0, w, h);
		CGContextClearRect( context, imageRect );
		// darw image back in, which somehow magically flips it back up
		CGContextDrawImage( context, imageRect, cgOut );
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

-(PNBitmapFont*)fontForFntPath:(NSString*)fntPath{
	// create master font dictionary, if needed
	if( self.dctFonts == nil ){
		NSMutableDictionary *dct = [[ NSMutableDictionary alloc ] init ];
		self.dctFonts = dct;
		[ dct release ];
	}
	// fetch font from master, if already loaded
	PNBitmapFont *font = [ self.dctFonts objectForKey: fntPath ];
	if( font == nil ){
		// font not loaded, load it
		font = [[ PNBitmapFont alloc ] initWithFntFilePath: fntPath ];
		[ self.dctFonts setObject: font forKey: fntPath ];
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

@synthesize text;
@synthesize pthFont;

-(id)initWithFrame:(CGRect)r fntFile:(NSString*)fntPath{
	if( self = [ super initWithFrame: r ] ){
		self.pthFont = fntPath;
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
	PNBitmapFont *font = [[ PNBitmapFontManager sharedInstance ] fontForFntPath: self.pthFont ];
	UIImage *textImage = [ font imageForString: self.text ];
	// returned image is @2x
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState( ctx );
	CGContextScaleCTM( ctx, 0.5, 0.5 );
	[ textImage drawInRect: rect ];
	CGContextRestoreGState( ctx );
}

-(void)dealloc{
	[ self.text release ];
	[ self.pthFont release ];
	[ super dealloc ];
}

@end


