//
//  ChildView.m
//  quince
//
//  Created by max on 4/14/10.
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


#import "ChildView.h"
#import "ContainerView.h"
#import "QuinceObject.h"
#import "QuinceObjectController.h"

@implementation ChildView


-(ChildView *)init{
	if((self = [super initWithFrame:NSMakeRect(0, 0, kDefaultWidth, kDefaultHeight)])){// init NSView with dummy rect
		
		controller = nil;
		//[self setWantsLayer:YES];

		dict = [[NSMutableDictionary alloc]init];
		[self setValue:[NSValue valueWithSize:NSMakeSize(kDefaultWidth, kDefaultHeight)] forKey:@"size"];
		[self setValue:[NSValue valueWithPoint:NSMakePoint(0, 0)] forKey:@"location"];
		[self setValue:[NSColor colorWithDeviceRed:0 green:.5 blue:1 alpha:1] forKey:@"selectionColor"];
		[self setValue:[NSColor colorWithDeviceRed:0.5 green:.5 blue:1 alpha:1] forKey:@"mutedSelectionColor"];
		[self setValue:[NSColor colorWithDeviceRed:0.5 green:.5 blue:0.5 alpha:1] forKey:@"mutedColor"];
		[self setValue:[NSColor blackColor] forKey:@"frameColor"];
		[self setValue:[NSColor whiteColor] forKey:@"interiorColor"];
		 
		resizeXCursorRect = NSZeroRect;
		resizeXCursor = [NSCursor resizeLeftRightCursor];
	}
	return self;
}

-(void)dealloc{
	
	[dict release];
	//[controller release];
	[super dealloc];
	
}

#pragma mark setters&getters

 -(void)setLocation:(NSPoint)point{				
	 [self setFrameOrigin:point];
	 [self communicateLocation];
} 

-(NSPoint)location{
	return [self frame].origin;
}

 -(void)setFrameColor:(NSColor *)c{ 
	[self setValue:c forKey:@"frameColor"]; 
}

-(NSColor *)frameColor{ 
	return [self valueForKey:@"frameColor"]; 
}

-(void)	setInteriorColor:(NSColor *)c{ 
	[self setValue:c forKey:@"interiorColor"];
}

-(NSColor *)interiorColor{ 
	return [self valueForKey:@"interiorColor"]; 
}

-(NSColor *)selectionColor{
	return [self valueForKey:@"selectionColor"];
}

-(void)	setHeight:(float)h withUpdate:(BOOL)b{
	
	if([self height] == h || (h<[self minimumHeight]))
		return;
	
	NSRect f = [self frame];
	NSRect nf = NSMakeRect(f.origin.x, f.origin.y, f.size.width, h);
	[self setFrame:nf];
	if(b)
		[self communicateSize];
}

-(void)	setWidth:(float)w withUpdate:(BOOL)b{ 
	
	if([self width] == w || (w<[self minimumWidth]))
		return;
	
	[self setFrameSize:NSMakeSize(w, [self frame].size.height)];
	if(b)
		[self communicateSize];
}

-(float)height{ 
	return [self frame].size.height;
}

-(float)width{ 
	return [self frame].size.width;
}

-(NSSize)size{ 
	return [self frame].size;
}

-(float)foldedItemHeight{
	return kDefaultHeight+4;
}

-(void)setSelectionColor:(NSColor *)color{
	[self setValue:color forKey:@"selectionColor"];
}

-(void)select{
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
	[self setNeedsDisplay:YES];
}

-(void)deselect{
	[self setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
	[self setNeedsDisplay:YES];
}

-(BOOL)selected{
	return [[self valueForKey:@"selected"]boolValue];
}

-(BOOL)muted{
	return [[self valueForKey:@"muted"]boolValue];
}

-(NSString *)description{
	
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	[dictionary setValue:[NSValue valueWithRect:[self rect]] forKey:@"rect"];
	return [NSString stringWithFormat:@"%@", dictionary];
}

-(NSRect) resizeXCursorRect{
	return resizeXCursorRect;
}
//////////////////////////////////////////

#pragma mark drawing, moving etc.

-(void)drawRect:(NSRect)rect{ // dirty wrapper
	[self draw];
}

-(void)	draw{

	[[NSGraphicsContext currentContext]setShouldAntialias:NO];
	[NSBezierPath setDefaultLineWidth:1];
	
	[self rect];
	NSRect b = [self bounds];
	NSRect r = NSMakeRect(b.origin.x+1, b.origin.y+1, b.size.width-2, b.size.height-2);
	
	//[[NSColor colorWithDeviceWhite:1 alpha:1]set];
	[[self interiorColor]set];
	[NSBezierPath fillRect:r];
	if([self selected] && ![self muted])	[[self valueForKey:@"selectionColor"] set];
	else if([self muted] && ![self selected]) [[self valueForKey:@"mutedColor"] set];
	else if([self selected] && [self muted])  [[self valueForKey:@"mutedSelectionColor"] set];
	else [[self valueForKey:@"frameColor"] set];
	
	[NSBezierPath strokeRect:r];
		
	if([[controller valueForKeyPath:@"selection.isFolded"]boolValue]==YES){
	
		int fontSize=[self foldedItemHeight]-3;
		NSFont *font = [NSFont systemFontOfSize:fontSize];
		NSRange tRange;
		NSPoint point;
		NSMutableAttributedString * s = [[NSMutableAttributedString alloc]initWithString:
										 [NSString stringWithFormat:@"%d", [[controller valueForKeyPath:@"selection.subObjects"]count]]];
		tRange = NSMakeRange(0, [s length]);	
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor redColor]range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint(r.origin.x+1, r.origin.y);
		[s drawAtPoint:point];
		[s release];
	}
}

-(void)		moveX:(float)x{	

	float newX = [self location].x+x, y = [self location].y;
	[self setLocation:NSMakePoint(newX, y)];
}

-(void)		moveY:(float)y{
	
	float newY = [self location].y+y, x= [self location].x;
	[self setLocation:NSMakePoint(x, newY)];
}

-(void)resize:(NSValue *)deltaValue{
	
	if([[controller valueForKeyPath:@"selection.isFolded"]boolValue]==YES) 
		return;
	
	NSSize deltaSize = [deltaValue sizeValue];
	float deltaX = deltaSize.width, deltaY = deltaSize.height;
	
	if([self allowsHorizontalResize] && [enclosingView allowsHorizontalResize])
		[self setWidth:[self width]+deltaX withUpdate:NO];
	
	if([self allowsVerticalResize] && [enclosingView allowsVerticalResize])
		[self setHeight:[self height]+deltaY withUpdate:NO];

	[self communicateSize];
}


-(NSRect)	rect{ 
	
	NSRect f = [self frame];
	
	if([[controller valueForKeyPath:@"selection.isFolded"]boolValue]==YES)
		[self setHeight:[self foldedItemHeight] withUpdate:NO];
	
	if([self width]<[self minimumWidth]){
		
		float x = f.origin.x, y = f.origin.y, w=[self minimumWidth], h=f.size.height;
		[self setFrame:NSMakeRect(x, y, w, h)];
		// don't use setWidth: because it would communicate the change to the controller, we just want to draw with different width
	}
	if([self height]<[self minimumHeight]){
		[self setFrameSize:NSMakeSize(f.size.width, [self minimumHeight])];
		// same thing for height...
	}
	
	if ([self width] > [self maximumWidth])
		[self setFrameSize:NSMakeSize([self maximumWidth], f.size.height)];
	if ([self height] > [self maximumHeight])
		[self setFrameSize:NSMakeSize(f.size.width,[self maximumHeight])];

	return [self frame];
}

-(void)resetCursorRects{
	resizeXCursorRect = NSMakeRect([self frame].size.width-3, 0, 3, [self bounds].size.height);
	[self addCursorRect:resizeXCursorRect cursor:resizeXCursor];
	
}
-(NSRect) redrawRect{// need a slightly bigger rect for redrawing

	return [self frame];
	NSRect f = [self frame];
	float x = f.origin.x-2, y = f.origin.y-2, w=f.size.width+4, h=f.size.height+4;
	return NSMakeRect(x,y,w,h);
}

-(NSPoint)center{
	
	NSRect r = [self frame];
	NSPoint center = NSMakePoint(NSMidX(r), NSMidY(r));
	return center;
}

-(void)scaleByFactorsInSize:(NSValue*)val{

	NSSize s = [val sizeValue];
	float x = s.width, y = s.height;
	[self scaleX:x];
	[self scaleY:y];	
}

-(void)scaleX:(float)x{
	
	if(x==1)
		return;
	
	NSPoint origin = NSMakePoint([self location].x*x, [self location].y); // 
	[self setFrameOrigin:origin];
	
	if ([self width] == [self minimumWidth] || [self width] == [self maximumWidth]){
		[[controller content]willChangeValueForKey:[enclosingView keyForSizeOnXAxis]];
		[[controller content]didChangeValueForKey:[enclosingView keyForSizeOnXAxis]];
	}
	else{
		if([self allowsHorizontalResize]){
			float newW = [self width]*x;
			[self setWidth:newW withUpdate:NO];	// this is for display only, so do not update now
		}
	}
}

-(void)scaleY:(float)y{
	if(y==1)
		return;
	
	NSPoint origin = NSMakePoint([self location].x, [self location].y*y); // 
	[self setFrameOrigin:origin];		
	
	if ([self height] == [self minimumHeight] || [self height] == [self maximumHeight]){
		[[controller content]willChangeValueForKey:[enclosingView keyForSizeOnYAxis]];
		[[controller content]didChangeValueForKey:[enclosingView keyForSizeOnYAxis]];
	}
	else {
		if([self allowsVerticalResize]){	
			float newH = [self height]*y;
			[self setHeight:newH withUpdate:NO];
		}
	}
}

-(void)setEnclosingView:(ContainerView *)view{
	enclosingView = view;
}

-(ContainerView *)enclosingView{
	return enclosingView;
}

#pragma mark KVC

-(id)valueForKey:(NSString *)key{
	if([key isEqualToString:@"locationX"])// needed for sorting childViews
		return [NSNumber numberWithFloat:[self location].x];
	return [dict valueForKey:key];
}


-(void)setValue:(id)value forKey:(NSString *)key{
	
	if([key isEqualToString:[enclosingView keyForLocationOnXAxis]]){
		float x = [[enclosingView xForParameterValue:value]floatValue] + [[enclosingView xDeltaForParameterValue:[controller valueForKeyPath:[NSString stringWithFormat:@"selection.%@Offset", key]]]floatValue];
		float y = [self frame].origin.y;
		NSPoint origin=NSMakePoint(x, y);
		[self setFrameOrigin:origin];
	}
	else if([key isEqualToString:[enclosingView keyForLocationOnYAxis]]){
		float x = [self frame].origin.x; 
		float y = [[enclosingView yForParameterValue:value]floatValue] + [[enclosingView yDeltaForParameterValue:[controller valueForKeyPath:[NSString stringWithFormat:@"selection.%@Offset", key]]]floatValue];
		NSPoint origin=NSMakePoint(x, y);
		[self setFrameOrigin:origin];
	}
	else if([key isEqualToString:[enclosingView keyForSizeOnXAxis]]){
		
		[self setWidth:[[enclosingView xForParameterValue:value]floatValue] withUpdate:YES];
		[self rect];
	}
	else if([key isEqualToString:[enclosingView keyForSizeOnYAxis]]){
		[self setHeight:[[enclosingView yForParameterValue:value]floatValue] withUpdate:YES];
	}
	else{
		[dict setValue:value forKey:key];
		return;
	}
	[self setNeedsDisplay:YES];
	[enclosingView setNeedsDisplayInRect:[self redrawRect]];
	
	//NSLog(@"%@: setValueForKey: %@", [self className], key);
	
}

-(void)communicateLocation{
	

	NSString * keyX = [enclosingView keyForLocationOnXAxis];
	// get offsetX in pixels
	double offsetXLocation = [[enclosingView xDeltaForParameterValue:[controller valueForKeyPath:[NSString stringWithFormat:@"selection.%@Offset", keyX]]]doubleValue];
	//convert x value to parameter-on-x-axis
	NSNumber * x = [enclosingView parameterValueForX:[NSNumber numberWithFloat:[self location].x - offsetXLocation]];
	//then setValue in model, which in turn will cause this object's setValue:forKey: method to be called with the appropiate value and key.
	[[[self infoForBinding:keyX] valueForKey:@"NSObservedObject"] setValue:x forKeyPath:[[self infoForBinding:keyX] valueForKey:@"NSObservedKeyPath"]];
	

	NSString * keyY = [enclosingView keyForLocationOnYAxis];
	// get offsetX in pixels
	double offsetYLocation = [[enclosingView yDeltaForParameterValue:[controller valueForKeyPath:[NSString stringWithFormat:@"selection.%@Offset", keyY]]]doubleValue];
	//convert y value to parameter-on-y-axis
	NSNumber * y = [enclosingView parameterValueForY:[NSNumber numberWithFloat:[self location].y - offsetYLocation]];
	//then setValue in model, which in turn will cause this object's setValue:forKey: method to be called with the appropiate value and key.
	[[[self infoForBinding:keyY] valueForKey:@"NSObservedObject"] setValue:y forKeyPath:[[self infoForBinding:keyY] valueForKey:@"NSObservedKeyPath"]];
}

-(void)communicateSize{
	//convert x value to parameter-on-x-axis
	NSNumber * x = [enclosingView parameterValueForX:[NSNumber numberWithFloat:[self width]]];
	NSString * keyX = [enclosingView keyForSizeOnXAxis];
	//double w = [[enclosingView convertTimeToX:x]doubleValue];

	
	//then setValue in model, which in turn will cause this object's setValue:forKey: method to be called with the appropiate value and key.
	[[[self infoForBinding:keyX] valueForKey:@"NSObservedObject"] setValue:x forKeyPath:[[self infoForBinding:keyX] valueForKey:@"NSObservedKeyPath"]];

	
	//convert y value to parameter-on-y-axis
	NSNumber * y = [enclosingView parameterValueForY:[NSNumber numberWithFloat:[self height]]];
	NSString * keyY = [enclosingView keyForSizeOnYAxis];

	//then setValue in model, which in turn will cause this object's setValue:forKey: method to be called with the appropiate value and key.
	[[[self infoForBinding:keyY] valueForKey:@"NSObservedObject"] setValue:y forKeyPath:[[self infoForBinding:keyY] valueForKey:@"NSObservedKeyPath"]];
}

#pragma mark constants
-(int)minimumHeight{
	return kMinimumHeight;
}

-(int)minimumWidth{
	return kMinimumWidth;
}

-(int)maximumHeight{
	return kMaximumHeight;
}

-(int)maximumWidth{
	return kMaximumWidth;
}

-(BOOL)isOpaque{return YES;} // NSView method, drawing faster with opaque views

-(BOOL)allowsHorizontalResize{return YES;}
-(BOOL)allowsVerticalResize{return NO;}

-(BOOL)canBeDirectlyCreatedByUser{	
	return YES;
}

#pragma mark controller
-(void)setController:(QuinceObjectController *)mc{
	
	controller = mc;
	[self bindToController];
}

-(QuinceObjectController *)controller{
	return controller;
}

-(void)bindToController{
	
	NSString * xLocationKey = [enclosingView keyForLocationOnXAxis];
	NSString * xSizeKey = [enclosingView keyForSizeOnXAxis];
	NSString * yLocationKey = [enclosingView keyForLocationOnYAxis];
	
	[self bind:xLocationKey toObject:controller withKeyPath:[NSString stringWithFormat:@"selection.%@", xLocationKey] options:nil];	
	[self bind:xSizeKey toObject:controller withKeyPath:[NSString stringWithFormat:@"selection.%@", xSizeKey] options:nil];	
	[self bind:yLocationKey toObject:controller withKeyPath:[NSString stringWithFormat:@"selection.%@", yLocationKey] options:nil];	
	[self bind:@"interiorColor" toObject:controller withKeyPath:[NSString stringWithFormat:@"color"] options:nil];
	//[self bind:@"startOffset" toObject:controller withKeyPath:[NSString stringWithFormat:@"selection.startOffset"] options:nil];
	[self bind:@"muted" toObject: controller withKeyPath:@"selection.muted" options:nil];
}

-(void)setVisible:(NSNumber *)v{

	if([v boolValue])
		[self setHidden:NO];
	else 
		[self setHidden:YES];
}

/* -(void)mute{
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"muted"];
}

-(void)unmute{
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"muted"];
}
 */
@end
