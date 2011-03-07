//
//  TimeGridContainer.m
//  quince
//
//  Created by max on 4/4/10.
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

#import "TimeGridContainer.h"


@implementation TimeGridContainer

-(TimeGridContainer *)init{

	if(self = [super init]){
		path = [[NSBezierPath alloc]init];
		regions = [[NSMutableArray alloc]init];
		paths = [[NSMutableArray alloc]init];
	}
	return self;
}

-(void)dealloc{

	[path release];
	[paths release];
	[regions release];
	[super dealloc];
}

-(void)drawRect:(NSRect)rect{

	if(![[self valueForKey:@"visible"]boolValue])
		return;
	
	[[NSGraphicsContext currentContext]setShouldAntialias:NO];
	
//	[[NSColor darkGrayColor]set];
	
	/* for(int i=0;i<[regions count];i++){
			if(i%2==0)
				[[NSColor colorWithDeviceRed:0 green:.1 blue:.5 alpha:0.4]set];
			else
				[[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0.3]set];

			[[regions objectAtIndex:i]fill];
			
		}
	 */	
	NSArray * r = [[self regionPathsInRect:rect]retain];

	for(NSBezierPath * p in r){
		int lw = [p lineWidth];
		if(lw%2==0)
			[[NSColor colorWithDeviceRed:0 green:.1 blue:.5 alpha:0.4]set];
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
	[[mc content]sortChronologically];
	NSArray * subs = [model valueForKey:@"subObjects"];
	[document setProgressTask:[NSString stringWithFormat:@"%@: creating display...", [self className]]];
	[document displayProgress:YES];
	float y = [self frame].size.height;
	[path release];
	[regions release];
	path = [[NSBezierPath alloc]init];
	regions = [[NSMutableArray alloc]init];
	int i=0,count = [subs count];

	// lines ...
	/* for(QuinceObject * quince in subs){
			NSPoint location = NSMakePoint([[self convertTimeToX:[quince valueForKey:@"start"]]floatValue], 0 );
			[path moveToPoint:location];
			[path lineToPoint:NSMakePoint(location.x, y)];
			[document setProgress:i++/count*100.0];
		}
	 */

	//lines
	
	if(!paths)
		paths = [[NSMutableArray alloc]init];
	
	[paths removeAllObjects];
	
	for(QuinceObject * quince in subs){
		NSPoint location = NSMakePoint([[self convertTimeToX:[quince valueForKey:@"start"]]floatValue], 0 );
		NSBezierPath * p = [NSBezierPath bezierPath];
		[p moveToPoint:location];
		[p lineToPoint:NSMakePoint(location.x, y)];
		[p setLineWidth:1];
		//if(!p)NSLog(@"RRRRRRRRRRRRRRR");
		[paths addObject:p];
		//NSLog(@"added new path. count: %d", [paths count]);
		[document setProgress:i++/count*100.0];
	}
	
	
	// regions....
	
	float startX, endX = 0, a, b, c;
	QuinceObject * quince;

	for(int i = 0;i<[subs count];i++){
		startX = endX;
		
		if ([subs count]>(i+1)) {
			quince = [subs objectAtIndex:i];
			a = [[self convertTimeToX:[quince valueForKey:@"start"]]floatValue];
			quince = [subs objectAtIndex:i+1];
			b = [[self convertTimeToX:[quince valueForKey:@"start"]]floatValue];
			
			c = (b-a)*.5 + a;
			//NSLog(@"a: %f, b: %f, c: %f", a, b, c);
		}
		else{
			quince = [subs objectAtIndex:i];
			c = [[self convertTimeToX:[quince valueForKey:@"start"]]floatValue];
		}
		endX = c;
		NSBezierPath * p = [NSBezierPath bezierPathWithRect:NSMakeRect(startX, 0, endX-startX, [self frame].size.height)];
		[p setLineWidth:i%2];
		[regions addObject:p];
	}
	
	
	[document displayProgress:NO];
}

-(NSArray *)linePathsInRect:(NSRect)r{
	//NSLog(@"paths count: %d", [paths count]);
	NSMutableArray * a = [[NSMutableArray alloc]init];
	for(NSBezierPath * p in paths){
		NSRect b = [p bounds];
		b.size.width = 2;
		//NSLog(@"%@", [NSValue valueWithRect:b]);
		if(NSIntersectsRect(r,b))
		   [a addObject:p];
	}
	return [a autorelease];
}


-(NSArray *)regionPathsInRect:(NSRect)r{
	//NSLog(@"paths count: %d", [paths count]);
	NSMutableArray * a = [[NSMutableArray alloc]init];
	for(NSBezierPath * p in regions){
		if(NSIntersectsRect(r,[p bounds]))
			[a addObject:p];
	}
	return [a autorelease];
}


-(void)scaleByX:(float)diffX andY:(float)diffY{
	[super scaleByX:diffX andY:diffY];
	NSAffineTransform * t = [NSAffineTransform transform];
	[t scaleXBy:diffX yBy:diffY];
	//[path transformUsingAffineTransform:t];
	for(NSBezierPath * p in paths)
		[p transformUsingAffineTransform:t];
	
	for(NSBezierPath * p in regions)
		[p transformUsingAffineTransform:t];
}

@end
