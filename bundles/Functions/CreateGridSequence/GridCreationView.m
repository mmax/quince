//
//  GridCreationView.m
//  quince
//
//  Created by max on 11/23/06.
//  Copyright 2006 Maximilian Marcoll. All rights reserved.
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


#import "GridCreationView.h"

@implementation GridCreationView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
		locks = [[NSMutableArray alloc]init];
		measureColors = [[NSMutableArray alloc]init];
		measures = [[NSMutableArray alloc]init];	
		colors = [[NSMutableArray alloc]init];

	}
    return self;
}

-(void)dealloc{
	[locks release];
	[measureColors release];
	[measures release];
	[colors release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {
	
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[[NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.3 alpha:1]set];//[[NSColor lightGrayColor]set];
	
	[NSBezierPath fillRect:rect];
	
	int i;
	for(i=0;i<[locks count];i++) {
		
		[(NSColor*)[colors objectAtIndex:i] set];
		[[locks objectAtIndex:i] fill];
		[[NSColor blackColor]set];
		[[locks objectAtIndex:i] stroke];
	}
}

-(void)makeColors:(int)x{
	
	[colors removeAllObjects];
	x=11;
	for(int i=0;i<[locks count];i++)
		[colors addObject:[NSColor colorWithDeviceHue:(1.0/8)*i saturation:1 brightness:.85 alpha:0.7]];
}

-(void) addMeasure:(int)measure {
	
	int offset = 10;
	float width = 5;
	float x = [self bounds].size.width-(offset *2)-width;
	float deltaX = x/measure;
	float y = [self bounds].size.height-(offset *2);
	float height = y / 8 * (8-[measures count]);
	y = offset;
	int i;
	NSRect rect;
	NSBezierPath * path = [[NSBezierPath alloc]init];
	
	for(NSNumber * n in measures){
		if([n intValue] == measure)
			return;
	}
	
	for(i=0;i<=measure;i++) {
		rect = NSMakeRect(i*deltaX+offset, offset, width, height);
		[path appendBezierPathWithRect:rect];
	}
	
	for(i=0;i<[measures count];i++) {
		if([[measures objectAtIndex:i] intValue] > measure)  //???!?!?!?!
			break;
	}
	
	[measures insertObject:[NSNumber numberWithInt:measure] atIndex:i];
	[locks insertObject:path atIndex:i];
	[path release];
	[self makeColors:[measures count]];
	[self setNeedsDisplay: YES];
}

-(void) removeMeasure:(int)measure {
	
	int i;
	for(i=0;i<[measures count];i++) {
		if([[measures objectAtIndex:i] intValue] == measure) {
			[locks removeObjectAtIndex:i];
			[measures removeObjectAtIndex:i];						
			break;
		}
	}
	[self makeColors:[measures count]];
	[self setNeedsDisplay:YES];
}

-(BOOL)containsMeasure:(int)i{

	NSNumber * m = [NSNumber numberWithInt:i];
	
	for(NSNumber * n in measures){
	
		if([n isEqualToNumber:m])
			return YES;
	
	}
	return NO;
}
-(NSMutableArray *) measures { return measures; }
-(NSMutableArray *) colors { return colors; }
@end