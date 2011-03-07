//
//  EnvelopeBasic.m
//  EnvlopeBasic
//
//  Created by max on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EnvelopeContainer.h"
#import <MintApi/Sequence.h>
#import <MintApi/MintObject.h>
#import <MintApi/MintDocument.h>
#import <MintApi/MintChildView.h>
#import <MintApi/Envelope.h>

#define kDeltaX 4

@implementation EnvelopeContainer

-(void)dealloc{

	if(fillPaths) [fillPaths release];
	if(strokePaths)	[strokePaths release];
	if(windows)	[windows release];
	[super dealloc];
}

-(void)mouseDown:(NSEvent *)event{/* do nothing!*/}
 
-(NSString *)defaultChildViewClassName{return nil;}//@"EnvelopeChild";}

 -(void)prepareToDisplayMintObjectWithController:(MintObjectController *)mc{

	Envelope * env = [mc content];
	double ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	 double duration = [[env valueForKey:@"duration"]doubleValue];
	long w = duration *  ppx;
	
	float widthNeeded = w;
	
	if([self frame].size.width < widthNeeded)
		[[[self layerController] mainController] resizeViewsForWidth:widthNeeded]; // bähh
	
	 [self setContentController:mc];
	
	 if(![env samplesPerWindow] || ![env envelope]){
		 [document presentAlertWithText:@"no data found! nothing to display"];
		 return;
	 }

	 [self createViewsForMintObjectController:mc];
}


-(void)createViewsForMintObjectController:(MintObjectController *)mc{

	[self createWindows];
	if(fillPaths) [fillPaths removeAllObjects];
	else fillPaths = [[NSMutableArray alloc]init];
	if(strokePaths)	[strokePaths removeAllObjects];
	else strokePaths = [[NSMutableArray alloc]init];
	
	int N=0, spw = [[self valueForKey:@"framesPerWindow"]intValue], framesPerPath = 150;
	double prevX=0, prevY=0, x=0,y=0, time;//,time, spw = [[[[self contentController]content] valueForKey:@"samplesPerWindow"]doubleValue];
	NSPoint startPoint = NSMakePoint(0, 0);
	Envelope * envelope = [mc content];
	float sr = [[envelope sampleRate]floatValue];
	NSPoint point;
	for(long i = 0;i<[windows count];i+= N){
		NSBezierPath * p = [[NSBezierPath alloc]init];
		NSBezierPath * q = [[NSBezierPath alloc]init];
		[p moveToPoint:startPoint];
		[p lineToPoint:NSMakePoint(x, y)];
		[q moveToPoint:NSMakePoint(x, y)];
		
		N = [windows count] > i + framesPerPath ? framesPerPath : [windows count]-i;
		
		for(int a = 0;a<N;a++){
			y = [[self convertVolumeToY:[NSNumber numberWithDouble:20.0 * log10([[windows objectAtIndex:i+a]floatValue])]]doubleValue];
			time = spw / sr * (i+a);
			//x = kDeltaX * (i+a);//
			x = [[self convertTimeToX:[NSNumber numberWithDouble:time]]doubleValue];
			//NSLog(@"a: %d, N: %d, x: %f, y: %f", a, N, x, y);
			point = NSMakePoint(x, y);
			[p lineToPoint:point];
			[q lineToPoint:NSMakePoint(x, y)];
			
			prevX = x;
			prevY = y;
		}
		startPoint = NSMakePoint(x, 0);
		[p lineToPoint:startPoint];
		[q setLineWidth:1];
		[fillPaths addObject:p];
		[strokePaths addObject:q];
		[p release];
		[q release];
		
	}
	//NSLog(@"%@", paths);
		/* path = [[NSBezierPath alloc]init];
				[path moveToPoint:NSMakePoint(0, 0)];
				NSArray * audio = (NSArray *)[[mc content]data];
				double x,y,time, spw = [[[[self contentController]content] valueForKey:@"samplesPerWindow"]doubleValue];
				
				for(long i = 0;i<[audio count];i++){
					y = [[self convertVolumeToY:[NSNumber numberWithDouble:20.0 * log10([[audio objectAtIndex:i]floatValue])]]doubleValue];
					time = spw / 44100.0 * i;
					x = [[self convertTimeToX:[NSNumber numberWithDouble:time]]doubleValue];
					[path lineToPoint:NSMakePoint(x, y)];
				}
				[path lineToPoint:NSMakePoint(x, 0)];
				[path closePath];
		 */	 
}



-(void)createWindows{
	if(windows){
		//[windows makeObjectsPerformSelector:@selector(release)];
		[windows removeAllObjects];
	}
	else
		windows = [[NSMutableArray alloc]init];
	Envelope * envelope = [[self contentController] content];
	
	NSArray * audio = (NSArray *)[[[self contentController] content]envelope];
	int N;
	double candidate, ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	float deltaX = kDeltaX;
	float sr = [[envelope sampleRate]floatValue];
	int spw = [[envelope samplesPerWindow]intValue];
	double framesPerWindowFloat = deltaX / ppx * sr;//(sr/spw);
	float max = 0;
	int framesPerWindow = framesPerWindowFloat*0.5;
	NSLog(@"%@: spw: %d", [self className], framesPerWindow);
	[self setValue:[NSNumber numberWithInt:framesPerWindow] forKey:@"framesPerWindow"];
	for(long i=0;i<[audio count];i+= N) {
		N = [audio count] < i+spw ? [audio count]-i : framesPerWindow;
		max = 0;
		for(int a=0;a<N;a++){
			candidate = [[audio objectAtIndex:i+a]doubleValue];
			if (candidate > max)
				max = candidate;
		}

		[windows addObject:[NSNumber numberWithFloat:max]];
	}
	NSLog(@"createWindows:done");
}

-(void)scaleByX:(float)x andY:(float)y{
	
	NSAffineTransform * transform = [NSAffineTransform transform];
	[transform scaleXBy:x yBy:y];
	/* [path transformUsingAffineTransform:transform]; */
	
	for(NSBezierPath * p in fillPaths)
		[p transformUsingAffineTransform:transform];
	
	 for(NSBezierPath * q in strokePaths)
		[q transformUsingAffineTransform:transform]; 
	
	[self setNeedsDisplay:YES];
}

-(void)updateViewsForCurrentSize{
	[self createViewsForMintObjectController:[self contentController]];
	[self setNeedsDisplay:YES];
}


-(void)drawRect:(NSRect)rect{
	
	[super drawRect:rect];
	
	[[NSGraphicsContext currentContext]setShouldAntialias:YES];

	[NSBezierPath setDefaultLineWidth:0];
	
		//[[NSColor colorWithDeviceRed:0.6 green:0.6 blue:1 alpha:1]set];	
	NSArray * pathsToFill = [self pathsFromArray:fillPaths inRect:rect];

	[[NSColor colorWithDeviceRed:0.4 green:0.45 blue:.6 alpha:1]set];

	for(NSBezierPath * p in pathsToFill){
		[p fill];
		[p stroke];
	}

	[[NSColor colorWithDeviceRed:0.1 green:0.1 blue:.1 alpha:1]set];
	
	NSArray * pathsToStroke = [self pathsFromArray:strokePaths inRect:rect];
	
	[pathsToStroke makeObjectsPerformSelector:@selector(stroke)];
	 /* for(NSBezierPath * q in pathsToStroke)
	    [q stroke];
	  */
}		

-(NSArray *)pathsFromArray: (NSArray *)paths inRect:(NSRect)rect{

	NSMutableArray * u = [[NSMutableArray alloc]init];
	for(NSBezierPath * p in paths){
		if(NSIntersectsRect([p bounds], rect))
		   [u addObject:p];
	}
	return [u autorelease];
	//return paths;
}

-(NSArray *)types{
	return [NSArray arrayWithObject:[NSString stringWithString:@"Envelope"]];
}

/* -(double) windowsPerPixel{
 
 double	ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
 float	samplesPerWindow = [[[[self contentController]content] valueForKey:@"samplesPerWindow"]floatValue];
 float	sr = 44100.0;
 double	secondsPerPixel = 1.0 / ppx;
 double	samplesPerPixel = secondsPerPixel * sr;
 double	windowsPerPixel = samplesPerPixel / samplesPerWindow;
 [self setValue:[NSNumber numberWithDouble:windowsPerPixel] forKey:@"windowsPerPixel"];
 return windowsPerPixel;
 } */

/* -(void)setPixelsPerUnitX:(NSNumber *)newPpx{
 
 
 [super setPixelsPerUnitX:newPpx];
 //[self windowsPerPixel];
 [path release];
 [self createViewsForMintObjectController:[self contentController]];
 [self setNeedsDisplay:YES];
 } */

/* double oldWps = [[self valueForKey:@"windowsPerPixel"]doubleValue];	
 [super setPixelsPerUnitX:newPpx];
 double newWps = [self windowsPerPixel];//[[self valueForKey:@"windowsPerPixel"]doubleValue];	
 NSAffineTransform * transform = [NSAffineTransform transform];
 double xFactor = 1.0 / (newWps / oldWps);
 [transform scaleXBy:xFactor yBy:1.0];
 [path transformUsingAffineTransform:transform];
 [self setNeedsDisplay:YES]; */

/*
-(void)createViewsForMintObjectController:(MintObjectController *)mc{

	MintObject * mint = [mc content];
	NSImage * image = [mint valueForKey:@"image"];
	NSRect imageFrame = [self imageFrame];
	imageView = [[NSImageView alloc]initWithFrame:imageFrame];
	[imageView setImageAlignment:NSImageAlignBottomLeft];
	[imageView setImage:image];
	[imageView setImageScaling:NSScaleToFit];
	[self addSubview:imageView];
}	
	
-(NSRect)imageFrame{
	MintObject * mint = [[self contentController]content];
	if(!mint)
		NSLog(@"imageContainer : no mint here!!");
	if(![self contentController])
		NSLog(@"imageContainer : no controller here!!");
	
	float width = [[mint valueForKey:@"image"]size].width;
	double ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	double ewd = [[mint valueForKey:@"envelopeWindowDuration"]doubleValue];
	long w = width * ewd *  ppx;
	NSRect imageFrame = NSMakeRect(0, 0, w, [self frame].size.height);
	return imageFrame;	
}

-(void)setPixelsPerUnitX:(NSNumber *)newPpx{
	
	[super setPixelsPerUnitX:newPpx];
	if(imageView)
		[imageView setFrame:[self imageFrame]];
}

-(void)dealloc{
	[imageView release];
	[[self contentController]release];
	[super dealloc];
}

 */@end
