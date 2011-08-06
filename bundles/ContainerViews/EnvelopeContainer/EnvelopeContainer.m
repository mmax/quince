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

#define kDeltaX 4

@implementation EnvelopeContainer

-(void)dealloc{

	if(fillPaths) [fillPaths release];
	if(strokePaths)	[strokePaths release];
	if(windows)	[windows release];
	[super dealloc];
}

-(void)mouseDown:(NSEvent *)event{
	
 //   BOOL childHit=NO;
//	NSPoint clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if ([event clickCount]==2 /*&& clickInPath*/){
			
		NSColorPanel * panel = [NSColorPanel sharedColorPanel];
		[panel setTarget:[self contentController]];
		[panel setAction:@selector(changeColor:)];  
		[[NSColorPanel sharedColorPanel]makeKeyAndOrderFront:nil];
		
	}
}
 
-(NSString *)defaultChildViewClassName{return nil;}//@"EnvelopeChild";}

 -(void)prepareToDisplayObjectWithController:(QuinceObjectController *)mc{

	Envelope * env = [mc content];
	double ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	 double duration = [[env valueForKey:@"duration"]doubleValue];
	long w = duration *  ppx;
	
	float widthNeeded = w;
	
	if([self frame].size.width < widthNeeded)
		[[[self layerController] mainController] resizeViewsForWidth:widthNeeded]; // bähh
	
	 [self setContentController:mc];
	
	 if(![env valueForKey:@"samplesPerWindow"] || ![env envelope]){
		 [document presentAlertWithText:@"no data found! nothing to display"];
		 return;
	 }

	 [self createViewsForQuinceObjectController:mc];
     [document displayProgress:NO];
}


-(void)createViewsForQuinceObjectController:(QuinceObjectController *)mc{

    
	[self createWindows];
	if(fillPaths) [fillPaths removeAllObjects];
	else fillPaths = [[NSMutableArray alloc]init];
	if(strokePaths)	[strokePaths removeAllObjects];
	else strokePaths = [[NSMutableArray alloc]init];
	
	int N=0, framesPerPath = 350;
	//int spw = [[self valueForKey:@"samplesPerWindow"]intValue], 
	
	//Envelope * envelope = [mc content];
	//float sr = [[envelope sampleRate]floatValue];
	//double windowDuration = [[self valueForKey:@"windowDuration"]doubleValue];
	double frameDuration = [[self valueForKey:@"frameDuration"]doubleValue];

	double framesPerWindow = [[self valueForKey:@"framesPerWindow"]doubleValue];
	
	double /* prevX=0, prevY=0,  */x=0,y=0, time;//,time, spw = [[[[self contentController]content] valueForKey:@"samplesPerWindow"]doubleValue];
	NSPoint startPoint = NSMakePoint(x, y);
	NSPoint point;
    [document setProgressTask:@"creating view..."];
    [document displayProgress:YES];
    
	for(long i = 0;i<[windows count];i+= N){
        [document setProgress:(100.0/[windows count])*i];
         
		NSBezierPath * p = [[NSBezierPath alloc]init];
		NSBezierPath * q = [[NSBezierPath alloc]init];
		[p moveToPoint:startPoint];
		//[q moveToPoint:startPoint];
		//[p lineToPoint:NSMakePoint(x, y)];
		[q moveToPoint:NSMakePoint(x, y)];
		
		N = [windows count] > i + framesPerPath ? framesPerPath : [windows count]-i;
		
		for(int a = 0;a<N;a++){
			y = [[self convertVolumeToY:[NSNumber numberWithDouble:20.0 * log10([[windows objectAtIndex:i+a]floatValue])]]doubleValue];
			//time = spw / sr * (i+a);
			//time = (i+a)*windowDuration;
			int fpwi = framesPerWindow+0.5;
			time = frameDuration * fpwi * (i+a);
			x = [[self convertTimeToX:[NSNumber numberWithDouble:time]]doubleValue];
			//NSLog(@"a: %d, N: %d, x: %f, y: %f", a, N, x, y);
			point = NSMakePoint(x, y);
			[p lineToPoint:point];
			[q lineToPoint:NSMakePoint(x, y)];
			
			//prevX = x;
			//prevY = y;
		}
		
		startPoint = NSMakePoint(x, 0);
		[p lineToPoint:startPoint];
		[p closePath];
		//[q lineToPoint:startPoint];
		[q setLineWidth:1];

		//startPoint = NSMakePoint(x, y);
		[fillPaths addObject:p];
		[strokePaths addObject:q];
		[p release];
		[q release];
		
	}
    [document displayProgress:NO];
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
    
    [document setProgressTask:@"EnvelopeContainer: creating envelope windows..."];
    [document setProgress:0];
    [document displayProgress:YES];
    
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
	//float sr = [[envelope sampleRate]floatValue];// 44100.0;
	//int envelopeSamplesPerWindow = [[envelope samplesPerWindow]intValue];

	/* double spwF = deltaX / ppx * sr;
		int envSamplesPerFrame = [[envelope samplesPerWindow]intValue];
		double envFramesF = spwF / envSamplesPerFrame;
	 */	
	float max = 0;
	//int spw = spwF*0.5;
	
	//int framesPerWindow = envFramesF + 0.5;
	
	double windowDur = 1.0 / ppx * deltaX;
	double frameDur = [envelope windowDuration];
	double framesPerWindow = windowDur / frameDur;
	
	if(framesPerWindow < 1.0){
		framesPerWindow = 1.0;
		windowDur = frameDur;
	}
	
	//NSLog(@"ppx: %f, windowDur: %f, frameDur: %f, framesPerWindow: %f", ppx, windowDur, frameDur, framesPerWindow);	
	//double duration = [audio count] * frameDur;
	//NSLog(@"envelope duration: %@, computed duration: %f", [envelope duration], duration);
	//[self setValue:[NSNumber numberWithInt:spwF+0.5] forKey:@"samplesPerWindow"];
	[self setValue:[NSNumber numberWithDouble:windowDur] forKey:@"windowDuration"];
	[self setValue:[NSNumber numberWithDouble:framesPerWindow] forKey:@"framesPerWindow"];
	[self setValue:[NSNumber numberWithDouble:frameDur] forKey:@"frameDuration"];
	
	int framesPerWindowI = framesPerWindow+0.5;
	for(long i=0;i<[audio count];i+= N) {
        
        [document setProgress:(100.0/[audio count])*i];
        
		N = [audio count] < i+framesPerWindowI ? [audio count]-i : framesPerWindowI;
		max = 0;
		for(int a=0;a<N;a++){
			candidate = [[audio objectAtIndex:i+a]doubleValue];
			if (candidate > max)
				max = candidate;
		}

		[windows addObject:[NSNumber numberWithFloat:max]];
	}
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
		[[[self contentController] valueForKey:@"color"]set];
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
