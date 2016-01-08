//
//  EnvelopeContainer.m
//  quince
//
//  Created by max on 3/8/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//
//
//	If you have any questions contact quince@maximilianmarcoll.de
//
//	This file is part of quince.
//
//	quince is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	quince is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with quince.  If not, see <http://www.gnu.org/licenses/>.
//

#import "EnvelopeContainer.h"
//#import <QuinceApi/Sequence.h>
#import <QuinceApi/QuinceObject.h>
#import <QuinceApi/QuinceDocument.h>
#import <QuinceApi/ChildView.h>
#import <QuinceApi/Envelope.h>
#include <malloc/malloc.h>

#define kDeltaX 4

@implementation EnvelopeContainer

-(id)initWithFrame:(NSRect)frame{	
	if ((self = [super initWithFrame:frame])) {
		
		wins = NULL;
    }
    return self;
}	


-(void)dealloc{

	if(fillPaths) [fillPaths release];
	if(strokePaths)	[strokePaths release];
	//if(windows)	[windows release];
    if(wins) free(wins);
	[super dealloc];
}

-(void)mouseDown:(NSEvent *)event{
	
 //   BOOL childHit=NO;
//	NSPoint clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if ([event clickCount]==2 /*&& clickInPath*/){
			
		NSColorPanel * panel = [NSColorPanel sharedColorPanel];
        [panel setShowsAlpha:YES];
		[panel setTarget:[self contentController]];
		[panel setAction:@selector(changeColor:)];  
        [panel setColor:[[self contentController]valueForKey:@"color"]];
		[[NSColorPanel sharedColorPanel]makeKeyAndOrderFront:nil];
		
	}
}
 
-(NSString *)defaultChildViewClassName{return nil;}//@"EnvelopeChild";}

 -(void)prepareToDisplayObjectWithController:(QuinceObjectController *)mc{
     NSLog(@"EnvelopeCotainer: prepareToDisplayObjectWithController");
	Envelope * env = [mc content];
	double ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	 double duration = [[env valueForKey:@"duration"]doubleValue];
	long w = duration *  ppx;
	
	float widthNeeded = w;
	
	if([self frame].size.width < widthNeeded)
		[[[self layerController] mainController] resizeViewsForWidth:widthNeeded]; // bähh
	
	 [self setContentController:mc];
	
	 if(![env samplesPerWindow] || ![env samples]){
		 //[document presentAlertWithText:@"no data found! nothing to display"];
		 return;
	 }

	 [self createViewsForQuinceObjectController:mc];
     
}


-(void)createViewsForQuinceObjectController:(QuinceObjectController *)mc{

    NSLog(@"EnvelopeCotainer: createViewsForQuinceObjectController");
	[self createWindows];
	if(fillPaths) [fillPaths removeAllObjects];
	else fillPaths = [[NSMutableArray alloc]init];
	if(strokePaths)	[strokePaths removeAllObjects];
	else strokePaths = [[NSMutableArray alloc]init];
	
	int N=0, framesPerPath = 350;
	double frameDuration = [[self valueForKey:@"frameDuration"]doubleValue];
	double framesPerWindow = [[self valueForKey:@"framesPerWindow"]doubleValue];
	double x=0,y=0, time;
	NSPoint startPoint = NSMakePoint(x, y);
	NSPoint point;
    long winCount = [[self valueForKey:@"winCount"]longValue]; // [windows count]
    [document setProgressTask:@"creating view..."];
    [document displayProgress:YES];
	
    for(long i = 0;i<winCount;i+= N){
        [document setProgress:(100.0/winCount)*i];
         
		NSBezierPath * p = [[NSBezierPath alloc]init];
		NSBezierPath * q = [[NSBezierPath alloc]init];
		[p moveToPoint:startPoint];
		[q moveToPoint:NSMakePoint(x, y)];
		
        N = winCount > i + framesPerPath ? framesPerPath : winCount-i;
        
		//N = [windows count] > i + framesPerPath ? framesPerPath : [windows count]-i;
		
		for(int a = 0;a<N;a++){
            if(i>0){
                point = NSMakePoint(x, y);
                [p lineToPoint:point];
            }
			//y = [[self convertVolumeToY:[NSNumber numberWithDouble:20.0 * log10([[windows objectAtIndex:i+a]floatValue])]]doubleValue];
            //NSLog(@"(i+a):%ld , wins: %lu", (i+a), malloc_size(wins)/(sizeof(float)));
            y = [[self convertVolumeToY:[NSNumber numberWithDouble:20.0 * log10(wins[i+a])]]doubleValue];
			int fpwi = framesPerWindow+0.5;
			time = frameDuration * fpwi * (i+a  );
			x = [[self convertTimeToX:[NSNumber numberWithDouble:time]]doubleValue];
			point = NSMakePoint(x, y);
			[p lineToPoint:point];
			[q lineToPoint:NSMakePoint(x, y)];
		}
        
		startPoint = NSMakePoint(x, 0);
		[p lineToPoint:startPoint];
		[p closePath];
		[q setLineWidth:1];
		[fillPaths addObject:p];
		[strokePaths addObject:q];
		[p release];
		[q release];
		
	}
    [document displayProgress:NO];
}



-(void)createWindows{
    
    [document setProgressTask:@"EnvelopeContainer: creating envelope windows..."];
    [document setProgress:0];
    [document displayProgress:YES];
    

    
	/*if(windows){
		//[windows makeObjectsPerformSelector:@selector(release)];
		[windows removeAllObjects];
	}
	else
		windows = [[NSMutableArray alloc]init];
	*/
    
	Envelope * envelope = [[self contentController] content]; 
	//NSArray * audio = [envelope envelope];
    long index, count = [envelope count];//[audio count];
    float * samples = [envelope samples];
    if(wins){
        long s = malloc_size(wins);
        //NSLog(@"size: %ld", s);
        if(!s)
            free(wins);
    }
    else{
        wins = malloc(count*sizeof(float));
        if(!wins || malloc_size(wins)/sizeof(float) < count){
            [document presentAlertWithText:@"EnvelopeContainer: Could not allocate memory for envelope windows."];
            return;
        }
    }
    
    NSLog(@"EnvelopeContainer: count: %ld", count);
    NSLog(@"EnvelopeContainer: creating windows now...");
    
	int N;
	double candidate, ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	float deltaX = kDeltaX;

	float max = 0;
		
	double windowDur = 1.0 / ppx * deltaX;
	double frameDur = [envelope windowDuration];
    double timeOffset = [[envelope valueForKey:@"start"]doubleValue];
	double framesPerWindow = windowDur / frameDur;
	
	if(framesPerWindow < 1.0){
		framesPerWindow = 1.0;
		windowDur = frameDur;
	}
	
	[self setValue:[NSNumber numberWithDouble:windowDur] forKey:@"windowDuration"];
	[self setValue:[NSNumber numberWithDouble:framesPerWindow] forKey:@"framesPerWindow"];
	[self setValue:[NSNumber numberWithDouble:frameDur] forKey:@"frameDuration"];
	
	int framesPerWindowI = framesPerWindow+0.5;

    
    float sr = [[envelope sampleRate]floatValue];
    float zero = 0.000000000001;
    int windowOffset = (sr*timeOffset)/ framesPerWindowI;
    NSLog(@"windowOffset: %d", windowOffset);
    index = 0;
    
    //experimental<

    //for(long i=0;i<windowOffset;i++)
       //[windows addObject:[NSNumber numberWithFloat:zero]];

    for(long i=0;i<windowOffset;i++)
        wins[index++] = zero;
    
	//  >experimental

    for(long i=0;i<count;i+= N) {
        
        [document setProgress:(100.0/count)*i];
        
		N = count < i+framesPerWindowI ? count-i : framesPerWindowI;
		max = 0;
		for(int a=0;a<N;a++){
			candidate = samples[i+a];//[[audio objectAtIndex:i+a]doubleValue];
			if (candidate > max)
				max = candidate;
		}

       // experimental<
        wins[index++]=max;
		//[windows addObject:[NSNumber numberWithFloat:max]];
        
        //  >experimental
        
	}
    //NSLog(@"windows count: %d", [windows count]);
    NSLog(@"wins count: %ld", index);
    [self setValue:[NSNumber numberWithLong:index] forKey:@"winCount"];

}

/*
 -(void)createWindows{
 if(windows){
 //[windows makeObjectsPerformSelector:@selector(release)];
 [windows removeAllObjects];
 }
 else
 windows = [[NSMutableArray alloc]init];
 
 Envelope * envelope = [[self contentController] content];
 NSArray * audio = [envelope envelope];
 int N;
 double candidate, ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
 float deltaX = kDeltaX;
 float sr = [[envelope sampleRate]floatValue];// 44100.0;
 int envelopeSamplesPerWindow = [[envelope samplesPerWindow]intValue];
 double spwF = deltaX / ppx * sr / envelopeSamplesPerWindow;
 float max = 0;
 int spw = spwF*0.5;
 //NSLog(@"spw: %d", spw);
 [self setValue:[NSNumber numberWithInt:spw] forKey:@"samplesPerWindow"];
 for(long i=0;i<[audio count];i+= N) {
 N = [audio count] < i+spw ? [audio count]-i : spw;
 max = 0;
 for(int a=0;a<N;a++){
 candidate = [[audio objectAtIndex:i+a]doubleValue];
 if (candidate > max)
 max = candidate;
 }
 
 [windows addObject:[NSNumber numberWithFloat:max]];
 }
 }
 
*/

-(void)scaleByX:(float)x andY:(float)y{
	//NSLog(@"scaleByX: andY:");
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
	[self createViewsForQuinceObjectController:[self contentController]];
	[self setNeedsDisplay:YES];
}


-(void)drawRect:(NSRect)rect{
	
	[super drawRect:rect];
	
	[[NSGraphicsContext currentContext]setShouldAntialias:YES];

	[NSBezierPath setDefaultLineWidth:0];
	
		//[[NSColor colorWithDeviceRed:0.6 green:0.6 blue:1 alpha:1]set];	
	NSArray * pathsToFill = [self pathsFromArray:fillPaths inRect:rect];

	if(![[self contentController] valueForKey:@"color"]){
		[[NSColor colorWithDeviceRed:0.4 green:0.45 blue:.6 alpha:1]set];
	}
	else {
		[(NSColor*)[[self contentController] valueForKey:@"color"]set];
	}

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

-(BOOL)allowsPlayback{return NO;}

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
 [self createViewsForQuinceObjectController:[self contentController]];
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
-(void)createViewsForQuinceObjectController:(QuinceObjectController *)mc{

	QuinceObject * quince = [mc content];
	NSImage * image = [quince valueForKey:@"image"];
	NSRect imageFrame = [self imageFrame];
	imageView = [[NSImageView alloc]initWithFrame:imageFrame];
	[imageView setImageAlignment:NSImageAlignBottomLeft];
	[imageView setImage:image];
	[imageView setImageScaling:NSScaleToFit];
	[self addSubview:imageView];
}	
	
-(NSRect)imageFrame{
	QuinceObject * quince = [[self contentController]content];
	if(!quince)
		NSLog(@"imageContainer : no quince here!!");
	if(![self contentController])
		NSLog(@"imageContainer : no controller here!!");
	
	float width = [[quince valueForKey:@"image"]size].width;
	double ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	double ewd = [[quince valueForKey:@"envelopeWindowDuration"]doubleValue];
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
