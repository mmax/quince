//
//  AutomationChild.m
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

#import "AutomationChild.h"


@implementation AutomationChild

-(BOOL)allowsHorizontalResize{return NO;}
-(BOOL)allowsVerticalResize{return NO;}

-(int)minimumWidth{return 5;}
-(int)minimumHeight{return 5;}
-(int)maximumHeight{return 5;}
-(int)maximumWidth{return 5;}

-(BOOL)canBeDirectlyCreatedByUser{return YES;}

-(AutomationChild *)init{

	if((self = [super init])){
	
		[self setValue:[NSColor colorWithDeviceRed:0 green:.7 blue:1 alpha:1] forKey:@"selectionColor"];
		[self setValue:[NSColor colorWithDeviceRed:1 green:.6 blue:0 alpha:1]forKey:@"interiorColor"];
	}
	return self;
} 


-(void)		draw{
	
	[[NSGraphicsContext currentContext]setShouldAntialias:NO];
	[NSBezierPath setDefaultLineWidth:0];
	[self rect];
	NSRect r = [self bounds];
	
	
	if([self selected]){
		//NSLog(@"MintItem: class: %@ : selected: %@", [self className], [NSNumber numberWithBool:[self selected]]);
		[(NSColor*)[self valueForKey:@"selectionColor"] set];
	}
	else{
		//NSLog(@"MintItem: class: %@ : selected: %@", [self className], [NSNumber numberWithBool:[self selected]]);
		[(NSColor*)[self valueForKey:@"interiorColor"] set];
	}
	[NSBezierPath fillRect:r];
	
	/* NSRect r = [self rect];
	//NSLog(@"AutomationChild:draw: rect: %@", [NSValue valueWithRect:r]);		
	if([self selected])
		[[self valueForKey:@"selectionColor"] set];
	else
		[[self valueForKey:@"interiorColor"] set];
	[NSBezierPath fillRect:r];
	//[NSBezierPath strokeRect:r]; */
} 

 -(void)setValue:(id)value forKey:(NSString *)key{

	[super setValue:value forKey:key];
	[(AutomationContainer *)enclosingView createPaths];//VERY inefficient!
	[enclosingView setNeedsDisplay:YES];
	

}

-(void)resetCursorRects{
// do nothing
}


-(NSArray *)positionGuides{
    
    return [NSArray arrayWithObjects:@"LEFT", @"BOTTOM", nil];
}
 
@end
