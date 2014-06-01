//
//  MainScrollerDocumentView.m
//  quince
//
//  Created by max on 3/12/10.
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

#import "MainScrollerDocumentView.h"
#import "MainController.h"

@implementation MainScrollerDocumentView

-(MainScrollerDocumentView *)initWithFrame:(NSRect)frameRect{

	if((self = [super initWithFrame:frameRect])){
		separators = [[NSMutableArray alloc]init];
		stripHeight = 0;
		stripOffset = 0;
		[self setWantsLayer:NO];
	}
	return self;
}

-(void)dealloc{
	[separators release];
	[super dealloc];
}

-(void) rulerView:(NSRulerView *)aRuler handleMouseDown:(NSEvent * )event {
	
	BOOL loop = YES;
    float zoom;//, deltaXD, deltaXS;
    NSPoint clickLocation;
    NSPoint scrollPoint;
	NSScrollView * scrollView;
    clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	
	NSPoint newDragLocation;
	NSPoint localLastDragLocation;
	localLastDragLocation=clickLocation;
	scrollView = [self enclosingScrollView];
	scrollPoint = [self convertPoint:clickLocation toView:scrollView];
	//deltaXD = scrollPoint.x;
	//deltaXS = clickLocation.x;
	BOOL drag = NO;
	
	while (loop) {
		NSEvent *localEvent;
	    localEvent= [[self window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];
	    clickLocation = [self convertPoint:[localEvent locationInWindow] fromView:nil]; // clickLocation relative to this view's coordinates
	    
	    switch ([localEvent type]) {
			case NSLeftMouseDragged:
				[[NSCursor closedHandCursor] push];
				newDragLocation = [self convertPoint:[localEvent locationInWindow] fromView:nil];
				zoom = localLastDragLocation.y-newDragLocation.y;
				[mainController changeHorizontalZoom:zoom fromPoint:clickLocation];
				localLastDragLocation=newDragLocation;
				drag = YES;
				break;
				
			case NSLeftMouseUp:
				//NSLog(@"mouseUp: %d", [event clickCount]);
				loop = NO;
				[[NSCursor arrowCursor] push];

				if(!drag && [event clickCount] ==2) [[mainController document]play];
                if(!drag)[mainController setCursorToPoint:clickLocation];
                else    [mainController updateViewsForCurrentSize];
				
				break;
			default:
				// Ignore any other kind of event. 
				break;
	    }
	}
    return;
}


-(void)drawRect:(NSRect)rect{

	//[[NSColor colorWithDeviceRed:.8 green:.8 blue:.81 alpha:1]set];
   [[NSColor colorWithDeviceRed:.2 green:.2 blue:.22 alpha:1]set];

	[NSBezierPath fillRect:[self bounds]];	
	if(stripHeight)[self drawSeparatorsForStripsWithHeight:stripHeight andOffset:stripOffset];
	[[NSColor colorWithDeviceRed:.4 green:.4 blue:.4 alpha:1]set];
	[separators makeObjectsPerformSelector:@selector(fill)];
	[[NSColor blackColor]set];
	
}

-(void)setMainController:(MainController *)sc{

	mainController = sc;
}


-(void)drawSeparatorsForStripsWithHeight:(float)height andOffset:(float)os{

	/* stripHeight = height;
		stripOffset = os;
		int strips = [self frame].size.height / height -1;
		float width = [self frame].size.width;
		[separators removeAllObjects];
		while (strips){
			NSRect r = NSMakeRect(0, height*strips+os*(strips-1), width, os);
			[separators addObject:[NSBezierPath bezierPathWithRect:r]];
			strips--;
		} */
	
	
	//////
	[separators removeAllObjects];
	
	float h = [self frame].size.height - height-os;
	while(h>0){
		NSRect r = NSMakeRect(0, h, [self frame].size.width, os);
		[separators addObject:[NSBezierPath bezierPathWithRect:r]];
		h-=height+os;
	}
}

-(void)viewDidEndLiveResize {
//	NSSize newSize;//, oldSize;
	/* oldSize = [[mainController valueForKey:@"oldSize"]sizeValue];//
	if (oldSize.width > [[[self enclosingScrollView]contentView]bounds].size.width )
		newSize.width = oldSize.width;
	else
		newSize.width = [[[self enclosingScrollView]contentView]bounds].size.width;

	if(oldSize.height > [[[self enclosingScrollView]contentView]bounds].size.height)
		newSize.height = oldSize.height;
	else
		newSize.height =[[[self enclosingScrollView]contentView]bounds].size.height; 

	 */
	//NSLog(@"MainScrollerDocumentView: didEndLiveResize");
	//newSize = [[[self enclosingScrollView]contentView]bounds].size;//[[self superview] bounds].size;
	//[mainController resize:newSize];
	//[mainController removeObjectForKey:@"oldSize"];
	//[mainController hideViews:NO];
	if([self bounds].size.width<[[[self enclosingScrollView]contentView]bounds].size.width){
		//NSLog(@"MainScrollerDocumentView: TADA");
		NSSize newSize = [self bounds].size;
		newSize.width = [[[self enclosingScrollView]contentView]bounds].size.width;
		[mainController resize:newSize];
	}
}

-(void)viewWillStartLiveResize{
	//[mainController hideViews:YES];

}

@end
