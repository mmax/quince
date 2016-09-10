//
//  AutomationContainer.m
//  quince
//
//  Created by max on 3/15/10.
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

#import "AutomationContainer.h"


@implementation AutomationContainer

 /* -(AutomationContainer *)initWithFrame:(NSRect)frame{
    if(self = [super initWithFrame:frame]){
	    [self setValue:[NSNumber numberWithFloat:(frame.size.height-kDefaultYAxisHeadRoom)/90.0] forKey:@"pixelsPerUnitY"];
	    paths = [[NSMutableArray alloc]init];
    
    }
    return self;
 }
  */

 -(id)initWithFrame:(NSRect)frame{	
	if ((self = [super initWithFrame:frame])) {
		paths = [[NSMutableArray alloc]init];
	}
	return self;
} 

-(void)dealloc{

	[paths release];
	[super dealloc];
}

-(NSString *)defaultChildViewClassName{return @"AutomationChild";}

-(NSArray *)types{
	return [NSArray arrayWithObject:@"QuinceObject"];
}

-(NSString *)defaultObjectClassName{return @"QuinceObject";}

-(BOOL)allowsVerticalResize{return NO;}

 -(void)duplicateSelection{
	//do nothing
}

-(IBAction)deleteBackward:(id)sender{

	[super deleteBackward:sender];
	[self createPaths];
}

-(void)prepareToDisplayObjectWithController:(QuinceObjectController *)mc{
	[super prepareToDisplayObjectWithController:mc];
	[self createPaths];
}

-(void)createPaths{
	[paths removeAllObjects];
	[self sortChildViewsLeft2Right];
	//NSLog(@"creating paths for %d items...\n%@", [items count], items);
	if([childViews count]<1)return;

	NSBezierPath * path;
	ChildView * item = [childViews objectAtIndex:0];
	long i;
	float x=0;
	float y=[item center].y;
	
	
	path = [[NSBezierPath alloc]init];
	[path moveToPoint:NSMakePoint(x,y)];
	x = [item center].x;
	[path lineToPoint:NSMakePoint(x, y)];
	[paths addObject:path];
	[path release];
	//NSLog(@"adding path:%@", path);

	for(i=1;i<[childViews count];i++){
		item = [childViews objectAtIndex:i];
		path = [[NSBezierPath alloc]init];
		[path moveToPoint:NSMakePoint(x,y)];
		x = [item center].x;
		y = [item center].y;
		[path lineToPoint:NSMakePoint(x, y)];
		//NSLog(@"item.center.x: %f,item.center.y: %f, path: %@, itemRect:%@", x, y, path, [NSValue valueWithRect:[item rect]]);
		[paths addObject:path];
		[path release];
	//	NSLog(@"adding path:%@", path);
	}
	path = [[NSBezierPath alloc]init];
	[path moveToPoint:NSMakePoint(x,y)];
	x = [self bounds].size.width;
	[path lineToPoint:NSMakePoint(x, y)];
	[paths addObject:path];
	[path release];
//	NSLog(@"adding path:%@", path);

	//NSLog(@"%d paths created", [paths count]);
}

-(NSArray *)pathsInRect:(NSRect)r{

	NSMutableArray * subPaths = [[NSMutableArray alloc]init];
	NSBezierPath * p;
	for(p in paths){
		//NSLog(@"checking pathRect: %@ with rect: %@", [NSValue valueWithRect:[p bounds]], [NSValue valueWithRect:r]);
		if (NSIntersectsRect(r,[self slightlyBiggerRect:[p bounds]]))
			[subPaths addObject:p];
	}
	//NSLog(@"subPaths has %d members", [subPaths count]);
	return [subPaths autorelease];
}

-(NSRect)slightlyBiggerRect:(NSRect)r{
	return NSMakeRect(r.origin.x-1, r.origin.y-1, r.size.width+2, r.size.height+2);
}
 

-(BOOL)allowsHorizontalResize{return NO;}

 -(void)drawRect:(NSRect)rect{
	
	if(![[self valueForKey:@"visible"]boolValue])return;
	[[NSGraphicsContext currentContext]setShouldAntialias:YES];	

	[[NSColor blackColor]set];
	NSBezierPath * p;
	NSArray * subPaths = [self pathsInRect:rect];
	for(p in subPaths){
		[p setLineWidth:0];
		[p stroke];
	}
	[super drawRect:rect];
}
 
 -(void)scaleByX:(float)diffX andY:(float)diffY{
	[super scaleByX:diffX andY:diffY];
	[self createPaths];
	[self setNeedsDisplay:YES];
}


/* -(void)doubleClickInEmptySpace:(NSPoint)location{
	[super doubleClickInEmptySpace:location];
	[self createPaths];	// ginge vielleicht effizienter
	[self setNeedsDisplay:YES];
	
} */

 
-(ChildView *)createChildViewForQuinceObjectController:(QuinceObjectController *)mc{

	ChildView * i = [super createChildViewForQuinceObjectController:mc];
	[self createPaths];
	[self setNeedsDisplay:YES];
	return i;
}

-(void)updatePathForItem:(ChildView *)item{}

-(void)setFrameSize:(NSSize)newSize{

	[super setFrameSize:newSize];
	[self createPaths];
}

-(void)foldSelection{
	// do nothing
}

-(BOOL)allowsPlayback{return NO;}

@end
