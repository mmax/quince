//
//  PitchGridContainer.m
//  quince
//
//  Created by max on 7/9/11.
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

#import "PitchGridContainer.h"


@implementation PitchGridContainer


-(void)drawRect:(NSRect)rect{
    
	if(![[self valueForKey:@"visible"]boolValue])
		return;
	
	[[NSGraphicsContext currentContext]setShouldAntialias:NO];

	NSArray * r = [[self regionPathsInRect:rect]retain];
    
	for(NSBezierPath * p in r){
		int lw = [p lineWidth];
		if(lw%2==0)
			[[NSColor colorWithDeviceRed:0 green:.1 blue:.5 alpha:0.4]set];//
		else
			[[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0.3]set];
		
		[p fill];
	}
	
    
	[[NSColor colorWithDeviceRed:.6 green:0 blue:0 alpha:1]set];
	NSArray * a = [[self linePathsInRect:rect]retain];
	for(NSBezierPath * p in a)
		[p stroke];
	[a release];
}

-(void)createViewsForQuinceObjectController:(QuinceObjectController *)mc{

	QuinceObject * model = [mc content];
	[model sortByKey:@"frequency" ascending:YES];
    
	NSArray * subs = [model valueForKey:@"subObjects"];
	
   // [document setProgressTask:[NSString stringWithFormat:@"%@: processing objects...", [self className]]];
//	[document displayProgress:YES];
	
    float x = [self frame].size.width;
	
    if(regions)
        [regions release];
    
	regions = [[NSMutableArray alloc]init];
    
	int i=0,count = [subs count];
    
    
	//lines
	
	if(!paths)
		paths = [[NSMutableArray alloc]init];
	
	[paths removeAllObjects];
	
	for(QuinceObject * quince in subs){

        NSPoint location = NSMakePoint(0, [[self convertPitchToY:[quince valueForKey:@"pitchF"]]floatValue]);
		
		NSBezierPath * p = [NSBezierPath bezierPath];
		[p moveToPoint:location];
		[p lineToPoint:NSMakePoint(x, location.y)];
		[p setLineWidth:1];
		[paths addObject:p];
		[document setProgress:i++/count*100.0];
	}
	
	// regions....
	
	float startY, endY = 0, a, b, c;
	QuinceObject * quince;

	for(int i = 0;i<[subs count];i++){
		startY = endY;
		
		if ([subs count]>(i+1)) {
			quince = [subs objectAtIndex:i];
			a = [[self convertPitchToY:[quince valueForKey:@"pitchF"]]floatValue];
			quince = [subs objectAtIndex:i+1];
			b = [[self convertPitchToY:[quince valueForKey:@"pitchF"]]floatValue];
			
			c = (b-a)*.5 + a;
		}
		else
			c = [self frame].size.height;

		endY = c;
		NSBezierPath * p = [NSBezierPath bezierPathWithRect:NSMakeRect(0, startY, [self frame].size.width, endY-startY)];
		[p setLineWidth:i%2];
		[regions addObject:p];
	}
	
	
	//[document displayProgress:NO];
}


            
-(id)initWithFrame:(NSRect)frame{	
	if ((self = [super initWithFrame:frame])) 
        [self setValue:[NSNumber numberWithFloat:(frame.size.height-5)/115] forKey:@"pixelsPerUnitY"];
    regions = [[NSMutableArray alloc]init];
    paths = [[NSMutableArray alloc]init];    
    return self;
}

-(void)dealloc{
    
	[paths release];
	[regions release];
	[super dealloc];
}

-(void)scaleByX:(float)diffX andY:(float)diffY{
	[super scaleByX:diffX andY:diffY];
	NSAffineTransform * t = [NSAffineTransform transform];
	[t scaleXBy:diffX yBy:diffY];
	for(NSBezierPath * p in paths)
		[p transformUsingAffineTransform:t];
	
	for(NSBezierPath * p in regions)
		[p transformUsingAffineTransform:t];
}

-(BOOL)allowsPlayback{return NO;}
-(BOOL)allowsNewSubObjectsToRepresentAudioFiles{return YES;}


-(NSString *)parameterOnY{
	return [NSString stringWithString:@"pitchF"];
}

-(NSString *)keyForLocationOnYAxis{
    return [NSString stringWithString:@"pitchF"];
}

-(NSNumber *)parameterValueForY:(NSNumber *)y{
	return [self convertYToPitch:y];
}

-(NSNumber *)yForParameterValue:(NSNumber *)p{
	return [self convertPitchToY:p];
}

-(NSNumber *)convertYToPitch:(NSNumber *)y {
	
	//float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
    double os = [[self valueForKey:@"minYValue"]doubleValue];
	float p = ([y doubleValue]/ppy)+os;//[self minimumYValue] + ([y doubleValue] / ppy);//((sizeY - [y doubleValue]) / ppy);
	return [NSNumber numberWithFloat: p] ;
	
}

-(NSNumber *)convertPitchToY:(NSNumber *)f{
	
    //	float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
    double os = [[self valueForKey:@"minYValue"]doubleValue];
	double y = ([f doubleValue]-os)*ppy;//([f doubleValue]-[self minimumYValue])*ppy;// sizeY + 
	return [NSNumber numberWithFloat: y];
}
-(NSArray *)regionPathsInRect:(NSRect)r{
    
	NSMutableArray * a = [[NSMutableArray alloc]init];
	for(NSBezierPath * p in regions){
		if(NSIntersectsRect(r,[p bounds]))
			[a addObject:p];
	}
	return [a autorelease];
}

-(NSArray *)linePathsInRect:(NSRect)r{

	NSMutableArray * a = [[NSMutableArray alloc]init];
	for(NSBezierPath * p in paths){
		NSRect b = [p bounds];
		b.size.height = 2;
        
		if(NSIntersectsRect(r,b))
            [a addObject:p];
	}
	return [a autorelease];
}
          
-(void)setFrameSize:(NSSize)newSize{

    [super setFrameSize:newSize];
    [self createViewsForQuinceObjectController:[self contentController]];
}

-(double)minimumYValue{return 16;}

-(double)maximumYValue{return 129;}

-(BOOL)canCreateNewEvents{return NO;}

@end
