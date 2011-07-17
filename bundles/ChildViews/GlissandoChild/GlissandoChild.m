//
//  GlissandoChild.m
//  quince
//
//  Created by max on 7/15/11.
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

#import <QuinceApi/QuinceObjectController.h>
#import "GlissandoChild.h"


@implementation GlissandoChild

-(void)setController:(QuinceObjectController *)mc andBindWithKeysForLocationOnX:(NSString *)lx sizeOnX:(NSString *)sx locationOnY:(NSString *)ly{
   [self bind:[enclosingView keyForSizeOnYAxis] toObject:mc withKeyPath:[NSString stringWithFormat:@"selection.%@", [enclosingView keyForSizeOnYAxis]] options:nil];	
    [super setController:mc andBindWithKeysForLocationOnX:lx sizeOnX:sx locationOnY:ly];

    [self unbind:@"interiorColor"];
    [self setInteriorColor:[NSColor colorWithDeviceRed:0.1 green:.3 blue:0.3 alpha:0.4]];
    [self resetCursorRects];
   //[self bind:@"pitchRange" toObject:controller withKeyPath:[NSString stringWithFormat:@"selection.endFreq"] options:nil];	
}


-(void)resetCursorRects{
	resizeXCursorRect = NSMakeRect([self frame].size.width-4, (int)([self frame].size.height*0.5)-2, 4, 4);
	[self addCursorRect:resizeXCursorRect cursor:resizeXCursor];
	
    resizeYCursorRect = NSMakeRect((int)([self frame].size.width*0.5)-2, [self frame].size.height-4, 4, 4);
    [self addCursorRect:resizeYCursorRect cursor:resizeYCursor];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)draw{
    [super draw];
    [[NSGraphicsContext currentContext]setShouldAntialias:YES];
    BOOL dir = [[[[self controller]content]valueForKey:@"glissandoDirection"]boolValue];
    NSBezierPath * p = [NSBezierPath bezierPath];

    if(dir){
        [p moveToPoint:NSMakePoint([self bounds].origin.x+2, [self bounds].origin.y+2)];
        [p lineToPoint:NSMakePoint([self bounds].origin.x+[self bounds].size.width-1, [self bounds].origin.y+[self bounds].size.height-2)];
    }
    else{
        [p moveToPoint:NSMakePoint([self bounds].origin.x+2, [self bounds].origin.y+[self bounds].size.height-2)];
        [p lineToPoint:NSMakePoint([self bounds].origin.x+[self bounds].size.width-1, [self bounds].origin.y+2)];
    }
    
//    NSRect r = [self resizeXCursorRect];
   // [[self interiorColor]set];
    [p setLineWidth:0];
    [[NSColor redColor]set];
    [p stroke];
    
    [[NSColor orangeColor]set];
	[NSBezierPath fillRect:[self resizeXCursorRect]];
    [NSBezierPath fillRect:[self resizeYCursorRect]];
    
}


-(BOOL)allowsVerticalResize{return YES;}

-(void)commandClick{
    [[self controller] switchGlissandoDirection];
}




@end