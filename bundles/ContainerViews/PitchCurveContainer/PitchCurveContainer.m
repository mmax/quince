//
//  PitchCurveContainer.m
//  quince
//
//  Created by max on 8/6/11.
//  Copyright 2011 Maximilian Marcoll. All rights reserved.
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


#import "PitchCurveContainer.h"


@implementation PitchCurveContainer


-(void)dealloc{
    
	if(fillPaths) [fillPaths release];
	if(strokePaths)	[strokePaths release];
	if(windows)	[windows release];
	[super dealloc];
}

-(void)mouseDown:(NSEvent *)event{

	
	if ([event clickCount]==2 /*&& clickInPath*/){
        
		NSColorPanel * panel = [NSColorPanel sharedColorPanel];
		[panel setTarget:[self contentController]];
		[panel setAction:@selector(changeColor:)];  
		[[NSColorPanel sharedColorPanel]makeKeyAndOrderFront:nil];
		
	}
}

-(NSString *)defaultChildViewClassName{return nil;}

-(void)prepareToDisplayObjectWithController:(QuinceObjectController *)mc{
    
	PitchCurve * env = [mc content];
	double ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
    double duration = [[env valueForKey:@"duration"]doubleValue];
	long w = duration *  ppx;
	
	float widthNeeded = w;
	
	if([self frame].size.width < widthNeeded)
		[[[self layerController] mainController] resizeViewsForWidth:widthNeeded]; // bähh
	
    [self setContentController:mc];
	
    if(!env)return;
    if(![env pitchCurve]){
        NSLog(@"%@", [env dictionary]);
        [document presentAlertWithText:@"no pitchCurve found! nothing to display"];
        return;
    }
    else if(![env valueForKey:@"samplesPerWindow"]){
        [document presentAlertWithText:@"PitchCurveContainer: ERROR: no samplesPerWindow parameter!"];
        return;
    }
    
    [self createViewsForQuinceObjectController:mc];
    [document displayProgress:NO];
}


-(void)createViewsForQuinceObjectController:(QuinceObjectController *)mc{
    
    
	[self createWindows];
//	if(fillPaths) [fillPaths removeAllObjects];
//	else fillPaths = [[NSMutableArray alloc]init];
	if(strokePaths)	[strokePaths removeAllObjects];
	else strokePaths = [[NSMutableArray alloc]init];
	
	int N=0, framesPerPath = 350;

	double frameDuration = [[self valueForKey:@"frameDuration"]doubleValue];
    
	double framesPerWindow = [[self valueForKey:@"framesPerWindow"]doubleValue];
	
	double x=0,y=0, time;
	NSPoint startPoint = NSMakePoint(x, y);
	NSPoint point;
    [document setProgressTask:@"creating view..."];
    [document displayProgress:YES];
    
	for(long i = 0;i<[windows count];i+= N){
        [document setProgress:(100.0/[windows count])*i];
        
		//NSBezierPath * p = [[NSBezierPath alloc]init];
		NSBezierPath * q = [[NSBezierPath alloc]init];
		//[p moveToPoint:startPoint];

		[q moveToPoint:NSMakePoint(x, y)];
		
		N = [windows count] > i + framesPerPath ? framesPerPath : [windows count]-i;
		
		for(int a = 0;a<N;a++){
			y = [[self convertPitchToY:[windows objectAtIndex:i+a]]doubleValue];

			int fpwi = framesPerWindow+0.5;
			time = frameDuration * fpwi * (i+a);
			x = [[self convertTimeToX:[NSNumber numberWithDouble:time]]doubleValue];

			point = NSMakePoint(x, y);
			//[p lineToPoint:point];
			[q lineToPoint:NSMakePoint(x, y)];

		}
		
		startPoint = NSMakePoint(x, 0);
		//[p lineToPoint:startPoint];
		//[p closePath];
		[q setLineWidth:1];
        
		//[fillPaths addObject:p];
		[strokePaths addObject:q];
		//[p release];
		[q release];
		
	} 
    [document displayProgress:NO];
}



-(void)createWindows{
    
    [document setProgressTask:@"EnvelopeContainer: creating envelope windows..."];
    [document setProgress:0];
    [document displayProgress:YES];
    
	if(windows){
		[windows removeAllObjects];
	}
	else
		windows = [[NSMutableArray alloc]init];
	
	Envelope * envelope = [[self contentController] content];
	NSArray * audio = [envelope envelope];
	int N;
	double candidate, ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	float deltaX = kDeltaX, max = 0;
	
	double windowDur = 1.0 / ppx * deltaX;
	double frameDur = [envelope windowDuration];
	double framesPerWindow = windowDur / frameDur;
	
	if(framesPerWindow < 1.0){
		framesPerWindow = 1.0;
		windowDur = frameDur;
	}

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


-(void)scaleByX:(float)x andY:(float)y{
	
	NSAffineTransform * transform = [NSAffineTransform transform];
	[transform scaleXBy:x yBy:y];
	
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
    
//	NSArray * pathsToFill = [self pathsFromArray:fillPaths inRect:rect];
//    
	if(![[self contentController] valueForKey:@"color"]){
		[[NSColor colorWithDeviceRed:0.66 green:.07 blue:.04 alpha:1]set];
	}
	else {
		[(NSColor*) [[self contentController] valueForKey:@"color"]set];
	}
//    
//	for(NSBezierPath * p in pathsToFill){
//		[p fill];
//		[p stroke];
//	}
    
	
	
	NSArray * pathsToStroke = [self pathsFromArray:strokePaths inRect:rect];
	
	[pathsToStroke makeObjectsPerformSelector:@selector(stroke)];
}		

-(NSArray *)pathsFromArray: (NSArray *)paths inRect:(NSRect)rect{
    
	NSMutableArray * u = [[NSMutableArray alloc]init];
	for(NSBezierPath * p in paths){
		if(NSIntersectsRect([p bounds], rect))
            [u addObject:p];
	}
	return [u autorelease];
}

-(NSArray *)types{
	return [NSArray arrayWithObject:[NSString stringWithString:@"PitchCurve"]];
}

-(BOOL)allowsPlayback{return NO;}

-(NSNumber *)convertYToPitch:(NSNumber *)y {
	
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
    double os = [[self valueForKey:@"minYValue"]doubleValue];
	float p = ([y doubleValue]/ppy)+os;
	return [NSNumber numberWithFloat: p] ;
}

-(NSNumber *)convertPitchToY:(NSNumber *)f{
	
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
    double os = [[self valueForKey:@"minYValue"]doubleValue];
	double y = ([f doubleValue]-os)*ppy;
	return [NSNumber numberWithFloat: y];
}

-(NSString *)parameterOnY{
	return [NSString stringWithString:@"pitchF"];
}

-(NSString *)keyForLocationOnYAxis{
    return [NSString stringWithString:@"pitchF"];
}

-(double)minimumYValue{return 16;}

-(double)maximumYValue{return 129;}

-(BOOL)canCreateNewEvents{return NO;}

@end
