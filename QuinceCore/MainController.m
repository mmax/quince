//
//  MainController.m
//  quince
//
//  Created by max on 2/21/10.
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

#import "MainController.h"
#import <QuinceApi/ContainerView.h>
#import "MainScrollerDocumentView.h"
#import <QuinceApi/QuinceDocument.h>

@implementation MainController

-(MainController *)init{

	if((self = [super init])){	
		stripControllScrollViews = [[NSMutableArray alloc]init];
		count = 0;
		quinceViewClasses = [[NSArray alloc]init];
		dictionary = [[NSMutableDictionary alloc]init];
		[self setValue:[NSNumber numberWithInt:kDefaultPixelsPerUnitX] forKey:@"pixelsPerUnitX"];
		stripControllers = [[NSMutableArray alloc]init];
		activeStripController = nil;
		zoomSliderValue = 0;
		//[self setValue:[NSNumber numberWithInt:40]forKey:@"volumeRange"];
		cursorTime = 0;
	}
	return self;
}

-(void)dealloc{
	[stripControllScrollViews release];
	[quinceViewClasses release];
	[dictionary release];
	[stripControllers release];
	[super dealloc];
}

-(void)getReady{
	
	[mainScrollView setHasHorizontalRuler:YES];
	[mainScrollView setRulersVisible:YES];
	[self updateHorizontalRuler];
	
	//manage syncronization
	[mainScrollerDocumentView setPostsBoundsChangedNotifications:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(scrollStripControlScroll:)
												 name:NSViewBoundsDidChangeNotification
											   object:[mainScrollView contentView]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(adjustSizes )
												 name:NSViewFrameDidChangeNotification
											   object:[mainScrollView contentView]];
//	[mainScrollerDocumentView setFrameSize:NSMakeSize([mainScrollerDocumentView frame].size.width, kDefaultStripHeight * [stripControllers count]+1)];
}

-(QuinceDocument *)document{
	return doc;
}

 -(void)scrollStripControlScroll:(NSNotification *)notification{
	NSView * changedContentView=[notification object];
	NSClipView * stripControlScrollContent = [stripControlScrollView contentView];

     if([[stripControlScrollContent documentView]bounds].size.height <= [stripControlScrollContent documentVisibleRect].size.height){
         return;
     }

     
     
	// get the origin of the NSClipView of the scroll view that
	// we're watching
	NSPoint changedBoundsOrigin = [changedContentView bounds].origin;
	
	// get our current origin
	 NSPoint curOffset = [stripControlScrollContent bounds].origin;//[stripControlDocumentView bounds].origin;
	NSPoint newOffset = curOffset;
	
	// scrolling is synchronized in the vertical plane
	// so only modify the y component of the offset
	newOffset.y = changedBoundsOrigin.y;

   [stripControlScrollContent scrollToPoint:newOffset];
}


-(void)updateHorizontalRuler{
	
	NSRulerView *horizRuler;
    horizRuler = [mainScrollView horizontalRulerView];
    if (!horizRuler) return;
	
	[horizRuler setClientView:mainScrollerDocumentView];//[scrollView documentView]];
	
	[NSRulerView registerUnitWithName:@"Seconds" abbreviation:@"s"  
		 unitToPointsConversionFactor:[[self valueForKey:@"pixelsPerUnitX"] intValue]//200//(int)pixelsPerSecond
						  stepUpCycle:[NSArray arrayWithObjects: 
									   [NSNumber numberWithFloat:2.0], [NSNumber numberWithFloat:5.0],nil]  
						stepDownCycle:[NSArray arrayWithObjects:[NSNumber numberWithFloat: 0.5],
									   [NSNumber numberWithFloat:0.25],nil]];
	
	[[mainScrollView horizontalRulerView] setMeasurementUnits:@"Seconds"];  
	
}


-(StripController *)createStrip{

	float height = (kVerticalStripOffset + kDefaultStripHeight)*count + kDefaultStripHeight;
	float width = kDefaultStripControlWidth;
	NSSize  newControlScrollViewSize = NSMakeSize(width, height); // 

	// set the scroll view's document view's size
	if([stripControlDocumentView frame].size.height < height){
		[stripControlDocumentView setFrameSize:newControlScrollViewSize];
	
	// the scroll view itsself will be resized by the layout set in InterfacBuilder
	// it's bound to the window size and shouldn't change with it's content
		
		// change the size of the main scroll view accordingly
		
		width = [mainScrollerDocumentView frame].size.width; // won't change
		NSSize newScrollerSize = NSMakeSize(width, height);
		[mainScrollerDocumentView setFrameSize:newScrollerSize];
	}

	// create the frame for the new view
	float x = 0;
	float y = [self yForStripWithIndex:count];//[self yForStripWithIndex:count];//[stripControlDocumentView frame].size.height-(kVerticalStripOffset + kDefaultStripHeight)*(count+1);
	width = kDefaultStripControlWidth;
	NSRect stripControlRect = NSMakeRect(x, y, width, kDefaultStripHeight);
	
	// create content inside that frame

	StripController * stripController = 	[[StripController alloc]initWithNibName:@"StripControl" bundle:nil];
	[stripController setController:self];
    [stripController setDocument:doc];
	NSView * stripControlView = [stripController view];
	[stripControlView setFrame:stripControlRect];
	 
	// connect the content
	[stripControllers addObject:stripController];
	[stripControlDocumentView addSubview:stripControlView];
	

	// we do have a new strip, so increment the count NOW
	count++;
	
	// draw separator lines inside the main scroller 
	[mainScrollerDocumentView drawSeparatorsForStripsWithHeight:kDefaultStripHeight andOffset:kVerticalStripOffset];
	

	// for some reason we have to reset the stripController's frames manually
	/* for(int i=0;i<[stripControllers count];i++){
			StripController * sc = [stripControllers objectAtIndex:i];
			stripControlView = [sc view];
			float y = [stripControlDocumentView frame].size.height-(kVerticalStripOffset + kDefaultStripHeight)*(i+1)+kVerticalStripOffset;
			stripControlRect = NSMakeRect(x, y, width, kDefaultStripHeight);
			[stripControlView setFrame:stripControlRect];
		} */
	[self rearrangeStripControls];
	
	// and reorder the strips's frames
	for(StripController * sc in stripControllers)
		[sc setFrame:[self frameForStripWithStripControl:sc]];

	if([stripControllers count] == 1)
		[self setActiveStripController:[stripControllers lastObject]];
	
	/*for(StripController * sc in stripControllers)
		[sc setVolumeRange:[[self valueForKey:@"volumeRange"]intValue] ];
     */

	[[doc undoManager]registerUndoWithTarget:self selector:@selector(removeStripWithStripController:) object:stripController];
	[[doc undoManager]setActionName:@"New Strip"];
	
    [self setValue:[self valueForKey:@"pixelsPerUnitX"]forKey:@"pixelsPerUnitX"];
    
	return [stripController autorelease];
}

-(void)removeActiveStrip{

	[self removeStripWithStripController:activeStripController];
}

-(void)removeStripWithStripController:(StripController *)sc{

	[[doc undoManager]registerUndoWithTarget:self selector:@selector(createViewsFromDictionary:) object:[self xmlDictionary]];
	[[doc undoManager]setActionName:@"Delete Strip"];

	[sc clear];
	[[sc interceptView]removeFromSuperview];
	[[sc view]removeFromSuperview];
	activeStripController = nil;
//    NSLog(@"now?");
	[stripControllers removeObject:sc];
//    NSLog(@"or now?");
	if([stripControllers count])
		[self setActiveStripController:[stripControllers objectAtIndex:0]];	
	
	count--;
	
	float y = [[[mainScrollerDocumentView enclosingScrollView]contentView]bounds].size.height;
	NSSize unionSize = [self unionRectForAllStrips].size;
	float minY = unionSize.height;
	float x = [[[mainScrollerDocumentView enclosingScrollView]contentView]bounds].size.width;
	float minX = unionSize.width;
	
	if(minY>y){
		NSLog(@"min>y");
		//[self resize:[self unionRectForAllStrips].size];
		y = minY;
	}
	/* else{
		NSLog(@"bounds...");
		[self resize:[[[mainScrollerDocumentView enclosingScrollView]contentView]bounds].size];
	}
	 */
	
	if(minX>x)
		x = minX;
	[self resize:NSMakeSize(x, y)];
	[self rearrangeStripControls];
	[self rearrangeStrips];
	
}


-(void)clear{

	for(StripController * sc in stripControllers)
		[self removeStripWithStripController:sc];

}

-(void)rearrangeStrips{
	
	/* NSView * stripControlView;
		StripController * sc;
		
		for(int i=0;i<[stripControllers count];i++){
			sc = [stripControllers objectAtIndex:i];
			stripControlView = [sc view];
			//float y = [stripControlDocumentView frame].size.height-(kVerticalStripOffset + kDefaultStripHeight)*(i+1)+kVerticalStripOffset;
			float y = [mainScrollerDocumentView frame].size.height-(kVerticalStripOffset + kDefaultStripHeight)*(i+1)+kVerticalStripOffset;
			[sc moveStripToNewY:y];
	//		stripControlRect = NSMakeRect(0, y, kDefaultStripControlWidth, kDefaultStripHeight);
	//		[stripControlView setFrame:stripControlRect];
		} */
	
	[stripControllers makeObjectsPerformSelector:@selector(relocate)];
	
}

-(void)rearrangeStripControls{
    
    
	NSView * stripControlView;
	NSRect stripControlRect;
	StripController * sc;
	float y;
	float scrollerOffset = 0;
    if(![[mainScrollView horizontalScroller]isHidden]){
        scrollerOffset = [[mainScrollView horizontalScroller]bounds].size.height;
    }
    
	for(int i=0;i<[stripControllers count];i++){
		sc = [stripControllers objectAtIndex:i];
		stripControlView = [sc view];
		y = [self yForStripWithIndex:i];//+scrollerOffset;
        
		stripControlRect = NSMakeRect(0, y, kDefaultStripControlWidth, kDefaultStripHeight);
		[stripControlView setFrame:stripControlRect];
	}
	[stripControlDocumentView setNeedsDisplay:YES]; // WHY DO I HAVE TO DO THIS?!?!
}


-(float)yForStripWithIndex:(int)index{

    return [mainScrollerDocumentView frame].size.height-(kVerticalStripOffset + kDefaultStripHeight)*(index+1)+kVerticalStripOffset;
}


-(void)setContainerViewClasses:(NSArray *)classes{
	[quinceViewClasses release];
	quinceViewClasses = [[NSArray arrayWithArray:classes]retain];
} 

-(NSArray *)containerViewClassNames{
	if(!doc){
		NSLog(@"mainController:containerViewClassNames:no doc!, returning empty array");
		return [[[NSMutableArray alloc]init] autorelease];
	}
	else{
		if(![[doc containerViewClassNames]count])NSLog(@"mainController: containerViewClassNames count == 0!!!");
		return [doc containerViewClassNames];
	}
}

-(NSArray *)containerViewClasses{
	return quinceViewClasses;
}


-(void)resizeViewsForWidth:(float)width{
	[self resize:NSMakeSize(width, 0)];
}

-(void)redrawAllViewsOfStripWithView:(ContainerView *) aView inRect:(NSRect)r{
	NSView * sv = [aView superview];
	NSEnumerator * e = [[sv subviews]objectEnumerator];
	NSView * v;
	while ((v = [e nextObject]))
		[v setNeedsDisplayInRect:r];
}



-(IBAction)changeHorizontalZoomWithSlider:(id)sender{

	float x = [sender floatValue];
	//float oldPpx =[[self valueForKey:@"pixelsPerUnitX"]floatValue]; 
	float ppx = x;//+oldPpx;
	/* float factor = 1;//ppx/oldPpx;
		float min = ([sender minValue]-x)*factor;
		float max = ([sender maxValue]-x)*factor;
		[sender setMinValue:min];
		[sender setMaxValue:max];
		[sender setIntegerValue:0];
		NSLog(@"x: %f", x); */
	[self setPPX:ppx fromPoint:[[mainScrollView contentView]documentVisibleRect].origin];
	//float d =  x-zoomSliderValue;
	//if(x>zoomSliderValue)
	//zoomSliderValue = x;

	//[self changeHorizontalZoom:d fromPoint:[[mainScrollView contentView]documentVisibleRect].origin];
	//NSLog(@"d: %f, point: %@", d, [NSValue valueWithPoint:[[mainScrollView contentView]documentVisibleRect].origin]);

}

-(IBAction)changeVolumeRangeWithSlider:(id)sender{
	/*int db = [sender intValue];
	NSString * fb = [NSString stringWithFormat:@"%d dB", db];
	[volumeRangeTextField setStringValue:fb];
	//NSNumber *newPPY = [NSNumber numberWithFloat:(kDefaultStripHeight-kDefaultYAxisHeadRoom)/kDefaultVolumeRange];
	[self willChangeValueForKey:@"volumeRange"];
	[self setValue:[NSNumber numberWithInt:db] forKey:@"volumeRange"];
	[self didChangeValueForKey:@"volumeRange"];
	
	for(StripController * sc in stripControllers){
		[sc setVolumeRange:db];
	}*/
}


-(void)changeHorizontalZoom:(float)y fromPoint:(NSPoint)scrollPoint{
	//NSLog(@"y:%f", y);
	float pix = [[self valueForKey:@"pixelsPerUnitX"]intValue];
	float newPpx = pix+y;
	//NSLog(@"ppx: %f", newPpx);
	[self setPPX:newPpx fromPoint:scrollPoint];
}

-(void)setPPX:(float) ppx fromPoint:(NSPoint)scrollPoint{
	float oldPpx = [[self valueForKey:@"pixelsPerUnitX"]intValue];
	float factor = (ppx)/oldPpx;
	float newWidth = [mainScrollerDocumentView frame].size.width * factor;
	if(newWidth < kMinimumContentWidth)
		return;	 
	//NSLog(@"newWidth: %f", newWidth);
	[self willChangeValueForKey:@"pixelsPerUnitX"];
	[self setValue:[NSNumber numberWithInt:ppx] forKey:@"pixelsPerUnitX"];
	[self didChangeValueForKey:@"pixelsPerUnitX"];
	[self resize:NSMakeSize(newWidth, [mainScrollerDocumentView frame].size.height)];
	NSPoint boundsOrigin = [[mainScrollView contentView]documentVisibleRect].origin;
	float deltaX = scrollPoint.x - boundsOrigin.x;
	float newX = scrollPoint.x*factor - deltaX;
	NSPoint newPoint = NSMakePoint(newX, boundsOrigin.y);	
	[[mainScrollView contentView] scrollPoint:newPoint];
	[self updateHorizontalRuler];
	[self drawCursorForTime:cursorTime];
}	

-(void)updateViewsForCurrentSize{
	[stripControllers makeObjectsPerformSelector:@selector(updateViewsForCurrentSize)];
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

-(void)setValue:(id)value forKey:(NSString *)key{
	[dictionary setValue:value forKey:key];
}
-(void)removeObjectForKey:(NSString *)key{
	[dictionary removeObjectForKey:key];
}

-(ChildView *)newChildViewOfClassNamed:(NSString *)name{
	return [doc newChildViewOfClassNamed:name];
}

-(QuinceObject *)newObjectOfClassNamed:(NSString *)name{
	return [doc newObjectOfClassNamed:name];
}

-(void)createViewEntriesInDictionary:(NSMutableDictionary *)dict{

	NSMutableArray * stripArray = [[NSMutableArray alloc]init];
	
	for(StripController * strip in stripControllers){
		
		/* NSMutableArray * layerArray = [[NSMutableArray alloc]init];
				NSArray * layers = [strip layerControllers];
				
				for(LayerController * lc in layers)	
					[layerArray addObject:[lc dictionary]];
		 */
		[stripArray addObject:[strip xml_layers]];//layerArray];
		//[layerArray release];
	}
	[dict setValue:stripArray forKey:@"strips"];
	[stripArray autorelease];
}

-(NSDictionary *)xmlDictionary{
	NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
	[self createViewEntriesInDictionary:dict];
	return [dict autorelease];
}


-(MainScrollerDocumentView *)contentView{
	return mainScrollerDocumentView;
}

-(void)resize:(NSSize)newSize{
	NSRect r = [self unionRectForAllStrips];
	NSSize minSize = NSMakeSize(kMinimumContentWidth, r.size.height);//r.size;
	NSSize size = newSize;
	
	/* if(newSize.height <= [mainScrollerDocumentView frame].size.height)
			size.height =minSize.height; //[mainScrollerDocumentView frame].size.height;
	 */	
	
	float y = [mainScrollerDocumentView frame].size.height;
	float min = minSize.height;
	
	 if (newSize.width < minSize.width)
			size.width = minSize.width;
	 
	/* if(size.width < r.size.width)
			 size.width = r.size.width; */
	
	if((newSize.height < minSize.height && newSize.height > 0) || min>y)
		size.height = minSize.height;
	if(!newSize.height)
		size.height = y;
	
	//else
	//	size.height = r.size.height;
	
	

	//NSLog(@"resize: %@", [NSValue valueWithSize:size]);
	[mainScrollerDocumentView setFrameSize:size];
	[mainScrollerDocumentView drawSeparatorsForStripsWithHeight:kDefaultStripHeight andOffset:kVerticalStripOffset];
	[stripControllers makeObjectsPerformSelector:@selector(resize:) withObject:[NSValue valueWithSize:size]];
	[stripControlDocumentView setFrameSize:NSMakeSize([stripControlDocumentView frame].size.width, size.height)];
	[self rearrangeStripControls];
	[self rearrangeStrips];
}

-(void)addObjectToObjectPool:(QuinceObject *)quince{
	[doc addObjectToObjectPool:quince];
}

-(NSRect)frameForStripWithStripControl:(StripController *)sc{

	float viewWidth = [mainScrollerDocumentView frame].size.width - kHorizontalStripOffset;
	int index = [stripControllers indexOfObject:sc];
	float y = [self yForStripWithIndex:index];//[mainScrollerDocumentView frame].size.height-(kVerticalStripOffset + kDefaultStripHeight)*(index+1)+kVerticalStripOffset;
	return NSMakeRect(0, y, viewWidth, kDefaultStripHeight);	
}


-(void)createViewsFromDictionary:(NSDictionary *)d{

	NSArray * stripArray = [d valueForKey:@"strips"];
	[self clear];
	for(NSArray * layers in stripArray){
		StripController * strip = [self createStrip];
		[strip createLayersFromArray:layers];
	}
	if([stripControllers count]){
		[self setActiveStripController:[stripControllers objectAtIndex:0]];	

	}
	
	for(StripController * sc in stripControllers){
		//[sc setVolumeRange:[[self valueForKey:@"volumeRange"]intValue]];
        [[sc interceptView]setFrame:[self frameForStripWithStripControl:sc]];//otherwise guides are not drawn properly
	}

}

-(NSRect) unionRectForAllStrips{

	NSRect r = NSZeroRect;
	NSRect s;
	for(StripController * sc in stripControllers){
		s = [self frameForStripWithStripControl:sc];
		r = NSUnionRect(r, s);
	}
	return r;
}

-(ContainerView *)activeView{
	return [activeStripController activeView];
}

-(void)setActiveStripController:(StripController *)sc{
	//if(sc == activeStripController)
	//	return;
	
	if(activeStripController)
		[activeStripController deactivate];
	activeStripController = sc;
	if(activeStripController)
		[activeStripController activate];	
}
	

-(NSMutableArray *)topLevelPlaybackList{

	NSMutableArray * tlp = [[NSMutableArray alloc]init];
	for(StripController * sc in stripControllers)	
		[tlp addObject:[sc topLevelPlaybackList]];//[[NSMutableArray alloc]init];
	return [tlp autorelease];
}

-(void)drawCursorForTime:(double)time{
	cursorTime = time;

	float min, max, y, x = time*[[self valueForKey:@"pixelsPerUnitX"] doubleValue];
	//NSPoint p = NSMakePoint(x+10, [[[doc mainScrollView]contentView] bounds].origin.y+10);
    min = [[[doc mainScrollView]contentView] bounds].origin.x;
    max = [[[doc mainScrollView]contentView] bounds].size.width;
    
	//if([doc isPlaying] && !NSPointInRect(p, [[[doc mainScrollView]contentView] frame])){

    if([doc isPlaying] && (/*x < min ||*/ x > min+max)){ // workaround
		//NSLog(@"MainController: drawCursorForTime: scrolling...p:%@ bounds:%@", 
		//			  [NSValue valueWithPoint:p],[NSValue valueWithRect:[[[doc mainScrollView]contentView] bounds]]);
                
        y = [[[doc mainScrollView]contentView] bounds].origin.y;
        [mainScrollerDocumentView scrollPoint:NSMakePoint(x, y)];
	}
	
	for(StripController * sc in stripControllers)
		[sc drawCursorForX:[[self valueForKey:@"pixelsPerUnitX"]floatValue]*time];
}


-(void)setCursorToPoint:(NSPoint)clickLocation{
	float time = clickLocation.x / [[self valueForKey:@"pixelsPerUnitX"]floatValue];
	[doc setPlaybackStartTime:[NSNumber numberWithFloat:time]];
	//[doc setCursorTime:[NSNumber numberWithFloat:time]];

}

-(void)hideViews:(BOOL)b{

	[mainScrollerDocumentView setHidden:b];
	[stripControlDocumentView setHidden:b]; 
}

-(void)adjustSizes{
	//NSLog(@"\nMainScrollerDocumentView: frame.size: %@\n [doc mainScrollView]contentView]bounds].size: %@", [NSValue valueWithSize:[mainScrollerDocumentView frame].size], [NSValue valueWithSize:[[[doc mainScrollView] contentView]bounds].size]);
	//if(![self valueForKey:@"oldSize"])[self setValue:[NSValue valueWithSize:[mainScrollerDocumentView frame].size] forKey:@"oldSize"];
	//NSSize newSize = [mainScrollerDocumentView frame].size;
	NSSize newSize = NSMakeSize([mainScrollerDocumentView frame].size.width, [[[doc mainScrollView] contentView]bounds].size.height);
	[self resize:newSize];
	
	//[self resize:[[[doc mainScrollView] contentView]bounds].size];
	[self rearrangeStrips];
	//NSLog(@"juhuu!");
}

-(NSArray *)stripControllers{return stripControllers;}
@end
