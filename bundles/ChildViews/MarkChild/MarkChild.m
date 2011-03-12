//
//  MarkChild.m
//  quince
//
//  Created by max on 8/31/10.
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

#import "MarkChild.h"


@implementation MarkChild


-(MarkChild*)init{
	
	if(self = [super init]){
		
		[self setValue:[NSColor colorWithDeviceRed:0 green:.5 blue:1 alpha:1] forKey:@"selectionColor"];
		[self setValue:[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1]forKey:@"interiorColor"];
		[self setValue:[NSColor colorWithDeviceRed:.91 green:.71 blue:.05 alpha:1] forKey:@"frameColor"];
	}
	return self;
} 


-(void)		draw{
	
	[[NSGraphicsContext currentContext]setShouldAntialias:NO];
	[NSBezierPath setDefaultLineWidth:0];
	[self rect];
	NSRect r = [self bounds];
	
	//r.origin.x -= r.size.width*0.5;
	//r.origin.y -= r.size.height*0.5;
	
	if([self selected]){
		//NSLog(@"MintItem: class: %@ : selected: %@", [self className], [NSNumber numberWithBool:[self selected]]);
		[[self valueForKey:@"selectionColor"] set];
	}
	else{
		//NSLog(@"MintItem: class: %@ : selected: %@", [self className], [NSNumber numberWithBool:[self selected]]);
		[[self valueForKey:@"frameColor"]set];
	}

	NSBezierPath * p = [[[NSBezierPath alloc]init]autorelease];
	/* [p moveToPoint:NSMakePoint(r.origin.x+r.size.width*0.5, r.origin.y)];
		[p lineToPoint:NSMakePoint(r.origin.x+r.size.width*0.5, r.origin.y+r.size.height)];
		[p moveToPoint:NSMakePoint(r.origin.x, r.origin.y+r.size.height*0.5)];
		[p lineToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y+r.size.height*0.5)]; */
	
	[p moveToPoint:NSMakePoint(r.origin.x+r.size.width-1, r.origin.y+1)];
	[p lineToPoint:NSMakePoint(r.origin.x+1, r.origin.y+1)];
	[p lineToPoint:NSMakePoint(r.origin.x+1, r.origin.y+r.size.height)];
	[p lineToPoint:NSMakePoint(r.origin.x+r.size.width, r.origin.y+1)];
	[p stroke];
	[p fill];
	
	//[NSBezierPath fillRect:r];
	
	/* NSRect r = [self rect];
	 //NSLog(@"AutomationChild:draw: rect: %@", [NSValue valueWithRect:r]);		
	 if([self selected])
	 [[self valueForKey:@"selectionColor"] set];
	 else
	 [[self valueForKey:@"interiorColor"] set];
	 [NSBezierPath fillRect:r];
	 //[NSBezierPath strokeRect:r]; */
} 



-(BOOL)allowsHorizontalResize{return NO;}
-(BOOL)allowsVerticalResize{return NO;}

-(int)minimumWidth{return 7;}
-(int)minimumHeight{return 7;}
-(int)maximumHeight{return 7;}
-(int)maximumWidth{return 7;}

-(BOOL)canBeDirectlyCreatedByUser{return YES;}


-(void)resetCursorRects{
	//resizeXCursorRect = NSMakeRect([self frame].size.width-3, 0, 3, [self bounds].size.height);
	//[self addCursorRect:resizeXCursorRect cursor:resizeXCursor];
	
}

@end
