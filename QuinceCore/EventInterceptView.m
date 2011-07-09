//
//  EventInterceptView.m
//  quince
//
//  Created by max on 4/10/10.
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

#import "EventInterceptView.h"
#import "StripController.h"
#import <QuinceApi/QuinceDocument.h>

@implementation EventInterceptView

@synthesize stripController;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        cursorX = 0;
        guides = YES;
        dictionary = [[NSMutableDictionary alloc]init];
		[self setValue:[[[NSMutableArray alloc]init]autorelease] forKey:@"guides"];
    }
    return self;
}

-(void)dealloc{
    [dictionary removeAllObjects];
    [dictionary release];
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {

	[[NSGraphicsContext currentContext]setShouldAntialias:NO];
	if(active){
	
		[[NSColor colorWithDeviceRed:0 green:0.5 blue:1 alpha:0.7]set];
		[NSBezierPath strokeRect:NSMakeRect([self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width-1, [self bounds].size.height-1)];//[self bounds]];
	}
	/* else {
			[[NSColor colorWithDeviceRed:1 green:1 blue:0 alpha:0.5]set];
			[NSBezierPath strokeRect:NSMakeRect([self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width-1, [self bounds].size.height-1)];
		} */

	[[NSColor blackColor]set];
	[NSBezierPath fillRect:NSMakeRect(cursorX, 0, 1, [self bounds].size.height)];
	
	//if(volumeGuides)
	//	[self drawVolumeGuidesInRect:dirtyRect];
    if(guides)
        [self drawGuidesInRect:dirtyRect];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
// -----------------------------------
// Handle Events 
// -----------------------------------

-(void)mouseDown:(NSEvent *)event{
	[[stripController controller]setActiveStripController:stripController];
	[[stripController activeView] mouseDown:event];
}


-(void)mouseDragged:(NSEvent *)event{
	[[stripController activeView] mouseDragged:event];
}

-(void)mouseUp:(NSEvent *)event{
	[[stripController activeView] mouseUp:event];
}

- (void)keyDown:(NSEvent *)event {
	
	[[stripController activeView] interpretKeyEvents:[NSArray arrayWithObject:event]]; 
}

-(IBAction)moveUp:(id)sender{
	[[stripController activeView] moveUp:sender];
}

-(IBAction)moveDown:(id)sender{
	[[stripController activeView]moveDown:sender];
}

-(IBAction)moveLeft:(id)sender{
	[[stripController activeView]moveLeft:sender];
}

-(IBAction)moveRight:(id)sender{
	[[stripController activeView]moveRight:sender];
}

-(IBAction)insertNewline:(id)sender{
	[[stripController activeView]insertNewline:sender];
}

-(void) insertText:(NSString *)string{
	[[stripController activeView]insertText:string];
}

-(IBAction)deleteBackward:(id)sender {
	[[stripController activeView]deleteBackward:sender];
}


-(void) setActive:(BOOL)b{

	active = b;
	[self setNeedsDisplay:YES];
}

-(void)drawCursorForX:(double)x{
	float prevX = cursorX;
	//if(maxabs_float(x-prevX)<1.0)return;
	cursorX = x;
	NSRect a = NSMakeRect(prevX-1, 0, 3, [self frame].size.height);
	NSRect b = NSMakeRect(x, 0, 3, [self frame].size.height);
	[self setNeedsDisplayInRect:NSUnionRect(a, b)];
}


-(void)computeVolumeGuides{
	//NSLog(@"computeVolumeGuides...");
	float y, alpha;
	int fontSize=8,  volumeRange = [[stripController volumeRange]integerValue];
	NSFont *font = [NSFont systemFontOfSize:fontSize];
	NSRange tRange;
	NSPoint point;
	NSBezierPath * zero;
	[[self valueForKey:@"guides"] removeAllObjects];
	
	for(int dB = 0;maxabs_float(dB)<volumeRange;dB-=6){
		NSMutableDictionary * guide = [[NSMutableDictionary alloc]init];
		ContainerView * view = [(LayerController * )[[stripController layerControllers] lastObject]view];
		y = [[view convertVolumeToY:[NSNumber numberWithInt:dB]]floatValue];
		alpha = (0.4/volumeRange)*(volumeRange-maxabs_float(dB))+0.1;
		NSColor * color = [NSColor colorWithDeviceWhite:1 alpha:alpha];
		[guide setValue:color forKey:@"color"];
		
		zero = [[[NSBezierPath alloc]init]autorelease];
		[zero moveToPoint:NSMakePoint(0,y)];
		[zero lineToPoint:NSMakePoint([self bounds].size.width, y)];
		[zero setLineWidth:0];
		[guide setValue:zero forKey:@"path"];
		
		NSMutableAttributedString * s = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%d dB", dB]]autorelease];

		tRange = NSMakeRange(0, [s length]);	
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint([self bounds].origin.x+1,y+1);
		//point = NSMakePoint(x+1,y+1);
		[guide setValue:[NSValue valueWithPoint:point]forKey:@"point"];
		[guide setValue:s forKey:@"string"];
		[[self valueForKey:@"guides"] addObject:guide];
	}
}


-(void)computeFrequencyGuides{
    
   // NSLog(@"computeFreqGuides...");
    float y, alpha;
	int fontSize=8,  frequencyRange = 15000;//[[stripController volumeRange]integerValue];
	NSFont *font = [NSFont systemFontOfSize:fontSize];
	NSRange tRange;
	NSPoint point;
	NSBezierPath * zero;
	[[self valueForKey:@"guides"] removeAllObjects];
	
	for(float f = 2;f<frequencyRange;f*=1.259921049894872){
		NSMutableDictionary * guide = [[NSMutableDictionary alloc]init];
		ContainerView * view = [(LayerController * )[[stripController layerControllers] lastObject]view];
		y = [[view yForParameterValue:[NSNumber numberWithInt:f]]floatValue];
        //NSLog(@"f: %f, y: %f", f, y);
		alpha = 0.5;//(0.4/frequencyRange)*(frequencyRange-maxabs_float(f))+0.1;
		NSColor * color = [NSColor colorWithDeviceWhite:1 alpha:alpha];
		[guide setValue:color forKey:@"color" ];
		
		zero = [[[NSBezierPath alloc]init]autorelease];
		[zero moveToPoint:NSMakePoint(0,y)];
		[zero lineToPoint:NSMakePoint([self bounds].size.width, y)];
		[zero setLineWidth:0];
		[guide setValue:zero forKey:@"path"];
		
		NSMutableAttributedString * s = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%.1f %@", f, [NSString stringWithFormat:@"Hz"]]]autorelease];
        // NSLog(@"intercept:error_now?");
		tRange = NSMakeRange(0, [s length]);	
        //  NSLog(@"intercept:error_no!");
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint([self bounds].origin.x+1,y+1);
		//point = NSMakePoint(x+1,y+1);
		[guide setValue:[NSValue valueWithPoint:point]forKey:@"point"];
		[guide setValue:s forKey:@"string"];
		[[self valueForKey:@"guides"] addObject:guide];
	}

}

-(void)computePitchGuides{
   
    float y, alpha;
	int fontSize=8;//,  frequencyRange = 15000;//[[stripController volumeRange]integerValue];
	NSFont *font = [NSFont systemFontOfSize:fontSize];
	NSRange tRange;
	NSPoint point;
	NSBezierPath * zero;
	[[self valueForKey:@"guides"] removeAllObjects];
	
	for(int p = 24;p<130;p+=12){
		NSMutableDictionary * guide = [[NSMutableDictionary alloc]init];
		ContainerView * view = [(LayerController * )[[stripController layerControllers] lastObject]view];
		y = [[view yForParameterValue:[NSNumber numberWithInt:p]]floatValue];
        //NSLog(@"f: %f, y: %f", f, y);
		alpha = 0.5;//(0.4/frequencyRange)*(frequencyRange-maxabs_float(f))+0.1;
		NSColor * color = [NSColor colorWithDeviceWhite:1 alpha:alpha];
		[guide setValue:color forKey:@"color" ];
		
		zero = [[[NSBezierPath alloc]init]autorelease];
		[zero moveToPoint:NSMakePoint(0,y)];
		[zero lineToPoint:NSMakePoint([self bounds].size.width, y)];
		[zero setLineWidth:0];
		[guide setValue:zero forKey:@"path"];
		
		NSMutableAttributedString * s = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%d", p]]autorelease];
        // NSLog(@"intercept:error_now?");
		tRange = NSMakeRange(0, [s length]);	
        //  NSLog(@"intercept:error_no!");
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint([self bounds].origin.x+1,y+1);
		//point = NSMakePoint(x+1,y+1);
		[guide setValue:[NSValue valueWithPoint:point]forKey:@"point"];
		[guide setValue:s forKey:@"string"];
		[[self valueForKey:@"guides"] addObject:guide];
	}


}

-(void)drawVolumeGuides{
	NSLog(@"drawVolumeGuides...");
	/* for(NSDictionary * d in volumeGuides){
			
			[[d valueForKey:@"color"]set];
			[[d valueForKey:@"path"]stroke];
			[(NSMutableAttributedString *)[d valueForKey:@"string"]drawAtPoint:[[d valueForKey:@"point"]pointValue]];
		} */
}

-(void)drawGuidesInRect:(NSRect) r{

    NSString * yP = [stripController parameterOnYAxis];
    
    if([yP isEqualToString:@"volume"])
        [self drawVolumeGuidesInRect:r];
    else if ([yP isEqualToString:@"frequency"])
        [self drawFrequencyGuidesInRect:r];
    else if ([yP isEqualToString:@"pitch"])
        [self drawPitchGuidesInRect:r];


}

-(void)drawFrequencyGuidesInRect:(NSRect) r{
    
    for(NSDictionary * d in [self valueForKey:@"guides"]){
        
		[[d valueForKey:@"color"]set];
		[[d valueForKey:@"path"]stroke];
		NSMutableAttributedString * s = [d valueForKey:@"string"];
		NSRect frame = [s boundingRectWithSize:[s size] options:NSStringDrawingUsesFontLeading];
		if(NSIntersectsRect(frame,r))
            [s drawAtPoint:[[d valueForKey:@"point"]pointValue]];
    }
}


-(void)drawPitchGuidesInRect:(NSRect) r{
    for(NSDictionary * d in [self valueForKey:@"guides"]){
        
		[[d valueForKey:@"color"]set];
		[[d valueForKey:@"path"]stroke];
		NSMutableAttributedString * s = [d valueForKey:@"string"];
		NSRect frame = [s boundingRectWithSize:[s size] options:NSStringDrawingUsesFontLeading];
		if(NSIntersectsRect(frame,r))
            [s drawAtPoint:[[d valueForKey:@"point"]pointValue]];
    }
}

-(void)drawVolumeGuidesInRect:(NSRect) r{
	//NSLog(@"drawVolumeGuidesInRect...");
	for(NSDictionary * d in [self valueForKey:@"guides"]){
	 
		[[d valueForKey:@"color"]set];
		[[d valueForKey:@"path"]stroke];
		NSMutableAttributedString * s = [d valueForKey:@"string"];
		NSRect frame = [s boundingRectWithSize:[s size] options:NSStringDrawingUsesFontLeading];
		if(NSIntersectsRect(frame,r))
		   [s drawAtPoint:[[d valueForKey:@"point"]pointValue]];
	 }
}

-(void)setFrameSize:(NSSize)newSize{
	[super setFrameSize:newSize];
    
	if(newSize.width > [self frame].size.width)
		[self computeGuides];
	
}

-(void)computeGuides{
    //NSLog(@"compute guides...");

    NSString * yP = [stripController parameterOnYAxis];
    
    if([yP isEqualToString:@"volume"])
        [self computeVolumeGuides];
    else if ([yP isEqualToString:@"frequency"])
        [self computeFrequencyGuides];
    else if ([yP isEqualToString:@"pitch"])
        [self computePitchGuides];
    
    [self setNeedsDisplay:YES];

}

-(void)setFrame:(NSRect)frameRect{
	[super setFrame:frameRect];
	[self computeGuides];
    
	/* if(volumeGuides){
			NSAffineTransform * trans = [NSAffineTransform transform];
			[trans scaleXBy:diffX yBy:1];
			for(NSDictionary * d in volumeGuides){
				
				NSBezierPath * p = [d valueForKey:@"path"];
				[p transformUsingAffineTransform:trans];
			}
		}
	 */
}


#pragma mark KVC

-(void)setValue:(id)aValue forKey:(NSString *)aKey{
    
	
	[self willChangeValueForKey:aKey];
	[self willChangeValueForKey:@"dictionary"];
	[dictionary setValue:aValue forKey:aKey];
	
	[self didChangeValueForKey:aKey];
	[self didChangeValueForKey:@"dictionary"];

}

-(id)valueForKey:(NSString *)key{
    
	return [dictionary valueForKey:key];
}

-(id)valueForKeyPath:(NSString *)keyPath{
	NSArray * keys = [keyPath componentsSeparatedByString:@"."];
	id val = self;
	for(NSString * key in keys)
		val = [val valueForKey:key];
	return val;
} 

-(void)removeObjectForKey:(NSString *)key{
	[self willChangeValueForKey:key];
	[dictionary removeObjectForKey:key];
	[self didChangeValueForKey:key];
}


-(NSMutableDictionary *)dictionary{
	return dictionary;
}




@end
