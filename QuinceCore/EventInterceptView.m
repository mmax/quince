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
		[NSBezierPath strokeRect:NSMakeRect([self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width-1, [self bounds].size.height-1)];
	}

	[[NSColor blackColor]set];
	[NSBezierPath fillRect:NSMakeRect(cursorX, 0, 1, [self bounds].size.height)];
	
    if([[stripController valueForKey:@"drawGuides"]boolValue]){
        if(![[self valueForKey:@"parameter"]isEqualToString:[stripController parameterOnYAxis]])
            [self computeGuides];
        [self drawGuidesInRect:dirtyRect];
    }


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
	cursorX = x;
	NSRect a = NSMakeRect(prevX-1, 0, 3, [self frame].size.height);
	NSRect b = NSMakeRect(x, 0, 3, [self frame].size.height);
	[self setNeedsDisplayInRect:NSUnionRect(a, b)];
}


-(void)computeVolumeGuides{

	float y, alpha;
	int fontSize=8;
	NSFont *font = [NSFont systemFontOfSize:fontSize];
	NSRange tRange;
	NSPoint point;
	NSBezierPath * zero;
	[[self valueForKey:@"guides"] removeAllObjects];
	
	for(int dB = 0;maxabs_float(dB)<90;dB-=6){
		NSMutableDictionary * guide = [[NSMutableDictionary alloc]init];
		ContainerView * view = [(LayerController * )[[stripController layerControllers] lastObject]view];
		y = [[view convertVolumeToY:[NSNumber numberWithInt:dB]]floatValue];
		alpha = (90-maxabs_float(dB))*.003+0.1;
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
		[guide setValue:[NSValue valueWithPoint:point]forKey:@"point"];
		[guide setValue:s forKey:@"string"];
		[[self valueForKey:@"guides"] addObject:guide];
	}
}


-(void)computeFrequencyGuides{
    
   
    float y, alpha;
	int fontSize=8,  frequencyRange = 15020;
	NSFont *font = [NSFont systemFontOfSize:fontSize];
	NSRange tRange;
	NSPoint point;
	NSBezierPath * zero;
	[[self valueForKey:@"guides"] removeAllObjects];
	
	for(float f = 220;f<frequencyRange;f*=2){
		NSMutableDictionary * guide = [[NSMutableDictionary alloc]init];
		ContainerView * view = [(LayerController * )[[stripController layerControllers] lastObject]view];
		y = [[view yForParameterValue:[NSNumber numberWithInt:f]]floatValue];
		alpha = 0.5;
		NSColor * color = [NSColor colorWithDeviceWhite:1 alpha:alpha];
		[guide setValue:color forKey:@"color" ];
		
		zero = [[[NSBezierPath alloc]init]autorelease];
		[zero moveToPoint:NSMakePoint(0,y)];
		[zero lineToPoint:NSMakePoint([self bounds].size.width, y)];
		[zero setLineWidth:0];
		[guide setValue:zero forKey:@"path"];
		
		NSMutableAttributedString * s = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%.1f %@", f, [NSString stringWithFormat:@"Hz"]]]autorelease];
		tRange = NSMakeRange(0, [s length]);	
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint([self bounds].origin.x+1,y+1);
		[guide setValue:[NSValue valueWithPoint:point]forKey:@"point"];
		[guide setValue:s forKey:@"string"];
		[[self valueForKey:@"guides"] addObject:guide];
	}
}

-(void)computePitchGuides{
   
    float y, alpha;
	int fontSize=8;
	NSFont *font = [NSFont systemFontOfSize:fontSize];
	NSRange tRange;
	NSPoint point;
	NSBezierPath * zero;
	[[self valueForKey:@"guides"] removeAllObjects];
	
	for(int p = 24;p<130;p+=12){
		NSMutableDictionary * guide = [[NSMutableDictionary alloc]init];
		ContainerView * view = [(LayerController * )[[stripController layerControllers] lastObject]view];
		y = [[view yForParameterValue:[NSNumber numberWithInt:p]]floatValue];
		alpha = 0.5;
		NSColor * color = [NSColor colorWithDeviceWhite:1 alpha:alpha];
		[guide setValue:color forKey:@"color" ];
		zero = [[[NSBezierPath alloc]init]autorelease];
		[zero moveToPoint:NSMakePoint(0,y)];
		[zero lineToPoint:NSMakePoint([self bounds].size.width, y)];
		[zero setLineWidth:0];
		[guide setValue:zero forKey:@"path"];
		
		NSMutableAttributedString * s = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%d", p]]autorelease];
		tRange = NSMakeRange(0, [s length]);	
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint([self bounds].origin.x+1,y+1);

		[guide setValue:[NSValue valueWithPoint:point]forKey:@"point"];
		[guide setValue:s forKey:@"string"];
		[[self valueForKey:@"guides"] addObject:guide];
	}
}

-(void)computeCentGuides{
    float y, alpha;
	int fontSize=8;
	NSFont *font = [NSFont systemFontOfSize:fontSize];
	NSRange tRange;
	NSPoint point;
	NSBezierPath * zero;
    NSString * sign = @"";
    
	[[self valueForKey:@"guides"] removeAllObjects];
	
	for(int p = -40;p<=40;p+=10){
		NSMutableDictionary * guide = [[NSMutableDictionary alloc]init];
		ContainerView * view = [(LayerController * )[[stripController layerControllers] lastObject]view];
		y = [[view yForParameterValue:[NSNumber numberWithInt:p]]floatValue];
		alpha = 0.5;
		NSColor * color = [NSColor colorWithDeviceWhite:1 alpha:alpha];
		[guide setValue:color forKey:@"color" ];
		zero = [[[NSBezierPath alloc]init]autorelease];
		[zero moveToPoint:NSMakePoint(0,y)];
		[zero lineToPoint:NSMakePoint([self bounds].size.width, y)];
		[zero setLineWidth:0];
		[guide setValue:zero forKey:@"path"];
		if(p>0)
            sign =@"+";
        if(p==0)
           sign = @"± ";
		NSMutableAttributedString * s = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%d c", sign, p]]autorelease];

		tRange = NSMakeRange(0, [s length]);	

		[s addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint([self bounds].origin.x+1,y+1);

		[guide setValue:[NSValue valueWithPoint:point]forKey:@"point"];
		[guide setValue:s forKey:@"string"];
		[[self valueForKey:@"guides"] addObject:guide];
	}
}

-(void)drawGuidesInRect:(NSRect) r{

    if(!active)return;
    for(NSDictionary * d in [self valueForKey:@"guides"]){
     	[[NSGraphicsContext currentContext]setShouldAntialias:NO];   
		[(NSColor*)[d valueForKey:@"color"]set];
		[[d valueForKey:@"path"]stroke];
        NSRect vr = [[[stripController document]mainScrollView]documentVisibleRect];
        float x = vr.origin.x;
        NSTextField * t = [d valueForKey:@"textField"];
        NSRect r = [t frame];
        r.origin.x = x;
        [t setFrame:r];
    }
}


-(void)setFrameSize:(NSSize)newSize{
	[super setFrameSize:newSize];
    
	if(newSize.width > [self frame].size.width)
		[self computeGuides];
	
}

-(void)computeGuides{

    if(![[stripController valueForKey:@"drawGuides"]boolValue])return;
    [self removeGuideTextFields];
        
    [[self valueForKey:@"guides"]removeAllObjects];

    NSString * yP = [stripController parameterOnYAxis];
    
    if([yP isEqualToString:@"volume"])
        [self computeVolumeGuides];
    else if ([yP isEqualToString:@"frequency"])
        [self computeFrequencyGuides];
    else if ([yP isEqualToString:@"pitch"] || [yP isEqualToString:@"pitchF"])
        [self computePitchGuides];
    else if ([yP isEqualToString:@"cent"])
        [self computeCentGuides];
    
    [self setValue:yP forKey:@"parameter"];
    [self setNeedsDisplay:YES];
    
    for(NSMutableDictionary * d in [self valueForKey:@"guides"]){
        if([d valueForKey:@"textField"]){
            [[d valueForKey:@"textField"]removeFromSuperview];
            [d removeObjectForKey:@"textField"];
        }
        NSTextField * t = [[[NSTextField alloc]init]autorelease];
        NSMutableAttributedString * s = [d valueForKey:@"string"];
        NSSize size = [s size];
		NSRect frame = [s boundingRectWithSize:size options:NSStringDrawingUsesFontLeading];
        frame.origin = [[d valueForKey:@"point"]pointValue];
        frame.origin.y -=2;
        frame.size.width+=30;
        [t setFrame: frame];
        [t setBounds:frame];
        [t setStringValue:[s mutableString]];
        [t setDrawsBackground:NO];
        [t setBordered:NO];
        [t setTextColor:[NSColor colorWithDeviceRed:.8 green:.8 blue:.8 alpha:1]];
        NSFont *font = [NSFont systemFontOfSize:6];
        [t setFont:font];
        [t setEditable:NO];
        [d setValue:t forKey:@"textField"];
        [self addSubview:t];
    }
    
}

-(void)setFrame:(NSRect)frameRect{
	[super setFrame:frameRect];
	[self computeGuides];
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


-(void)prepareGuides{
    
    if(![[stripController valueForKey:@"drawGuides"]boolValue])
        [self removeGuideTextFields];
    else
        [self computeGuides];
}
-(void)removeGuideTextFields{

    for(NSMutableDictionary * d in [self valueForKey:@"guides"]){
        
        if([d valueForKey:@"textField"]){
            
            [[d valueForKey:@"textField"]removeFromSuperview];
            [d removeObjectForKey:@"textField"];
        }
    }
}

@end
