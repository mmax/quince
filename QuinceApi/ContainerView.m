//
//  MintView.m
//  quince
//
//  Created by max on 2/19/10.
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



#import "ContainerView.h"
#import "QuinceObject.h"
#import "ChildView.h"
#import "QuinceDocument.h"
#import "LayerController.h"
#import "QuinceObjectController.h"
#import "MainController.h"

NSString* const kContainerViewDefaultFoldString =  @"f";
NSString* const kContainerViewDefaultUnfoldString = @"F";
NSString* const kPlayKeyString = @" ";
NSString* const kMuteString = @"m";

@implementation ContainerView

@synthesize layerController, contentController;

#pragma mark basics

-(id)initWithFrame:(NSRect)frame{	
	if ((self = [super initWithFrame:frame])) {
		
		[[NSAnimationContext currentContext] setDuration:1.0];
		childViews = [[NSMutableArray alloc] init];
		selection = [[NSMutableArray alloc] init];
		dragging = NO;
		selDragging = NO;
		liveResize = NO;

		dict = [[NSMutableDictionary alloc]init];
		[self setValue:[NSNumber numberWithInt:kDefaultYAxisHeadRoom]forKey:@"yAxisHeadRoom"];
		[self setValue:[NSNumber numberWithBool:YES] forKey:@"visible"];
		[self setValue:[NSNumber numberWithBool:NO] forKey:@"active"];
		[self setValue:[NSNumber numberWithFloat:(frame.size.height-kDefaultYAxisHeadRoom)/kDefaultVolumeRange] forKey:@"pixelsPerUnitY"];

		//[self setWantsLayer:YES];
    }
    return self;
}	

-(void)dealloc{
	
	[self removeChildViews:childViews];
	[childViews release];
	[selection removeAllObjects];
	[selection release];
	[dict release];

	//[yAxisHeadRoom release];
	[contentController unregisterContainerView:self];
	
	[super dealloc];
}

-(BOOL)typeCheckModel:(QuinceObject *)model{
	
	return [model isOneOfTypesInArray:[self types]];
}


#pragma mark KVC

-(id)valueForKey:(NSString *)key{
	return [dict valueForKey:key];
}

 -(void)setValue:(id)value forKey:(NSString *)key{
	
	 if([key isEqualToString:@"pixelsPerUnitX"])
		 [self setPixelsPerUnitX:value];	
	 else if([key isEqualToString:@"volumeRange"])
		 [self setVolumeRange:value];
	 
	 [dict setValue:value forKey:key];
}

#pragma mark drawing

-(void)setAlphaValue:(CGFloat)viewAlpha{
	[super setAlphaValue:viewAlpha];
}

-(void)drawRect:(NSRect)rect{
	
	[[NSGraphicsContext currentContext]setShouldAntialias:NO];

	[[self backgroundColor]set];
	[NSBezierPath fillRect:rect];
	
	/* if([[self parameterOnY]isEqualToString:@"volume"] && [self showGuides])
		[self drawVolumeGuides];		 */
	
	if(selDragging)
		[self drawSelRect];
}		

/* float y, alpha;//, x = [[[document mainScrollView] contentView]documentVisibleRect].origin.x;
 int fontSize=8,  volumeRange = [[self valueForKey:@"volumeRange"]integerValue];
 NSFont *font = [NSFont systemFontOfSize:fontSize];
 NSRange tRange;
 NSPoint point;
 NSBezierPath * zero = [[NSBezierPath alloc]init];
 
 for(int dB = 0;maxabs_float(dB)<volumeRange;dB-=6){
 y = [[self convertVolumeToY:[NSNumber numberWithInt:dB]]floatValue];
 alpha = (0.4/volumeRange)*(volumeRange-maxabs_float(dB))+0.1;
 NSColor * color = [NSColor colorWithDeviceWhite:1 alpha:alpha];
 [zero removeAllPoints];
 [zero moveToPoint:NSMakePoint(0,y)];
 [zero lineToPoint:NSMakePoint([self bounds].size.width, y)];
 [zero setLineWidth:0];
 [color set];
 [zero stroke];
 NSMutableAttributedString * s = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%d", dB]];
 tRange = NSMakeRange(0, [s length]);	
 [s addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:tRange];
 [s addAttribute:NSFontAttributeName value:font range:tRange];
 point = NSMakePoint([self bounds].origin.x+1,y+1);
 //point = NSMakePoint(x+1,y+1);
 [s drawAtPoint:point];
 [s release];
 }
 [zero release];
 */
/* 
-(void)drawVolumeGuides{
		NSLog(@"drawVolumeGuides...");


	for(NSDictionary * d in volumeGuides){
	
		[[d valueForKey:@"color"]set];
		[[d valueForKey:@"path"]stroke];
		[(NSMutableAttributedString *)[d valueForKey:@"string"]drawAtPoint:[[d valueForKey:@"point"]pointValue]];
	}
}

-(void)computeVolumeGuides{

	float y, alpha;
	int fontSize=8,  volumeRange = [[self valueForKey:@"volumeRange"]integerValue];
	NSFont *font = [NSFont systemFontOfSize:fontSize];
	NSRange tRange;
	NSPoint point;
	NSBezierPath * zero;
	[volumeGuides removeAllObjects];
	
	for(int dB = 0;maxabs_float(dB)<volumeRange;dB-=6){
		NSMutableDictionary * guide = [[NSMutableDictionary alloc]init];
		
		y = [[self convertVolumeToY:[NSNumber numberWithInt:dB]]floatValue];
		alpha = (0.4/volumeRange)*(volumeRange-maxabs_float(dB))+0.1;
		NSColor * color = [NSColor colorWithDeviceWhite:1 alpha:alpha];
		[guide setValue:color forKey:@"color"];
		
		zero = [[[NSBezierPath alloc]init]autorelease];
		[zero moveToPoint:NSMakePoint(0,y)];
		[zero lineToPoint:NSMakePoint([self bounds].size.width, y)];
		[zero setLineWidth:0];
		[guide setValue:zero forKey:@"path"];
		
		NSMutableAttributedString * s = [[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%d", dB]]autorelease];
		tRange = NSMakeRange(0, [s length]);	
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint([self bounds].origin.x+1,y+1);
		//point = NSMakePoint(x+1,y+1);
		[guide setValue:[NSValue valueWithPoint:point]forKey:@"point"];
		[guide setValue:s forKey:@"string"];
		[volumeGuides addObject:guide];
	}
}

 */

-(void)drawSelRect{
	[[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0.8] set];
	[NSBezierPath fillRect:selRect];
}

#pragma mark event handling

/////////////////////////////////////////////////////////////////////////////////////////////////////
// -----------------------------------
// Handle Mouse Events 
// -----------------------------------

-(void)mouseDown:(NSEvent *)event{
	
	if(![[self valueForKey:@"visible"]boolValue])
		return;
	   
	NSPoint clickLocation;
    BOOL childHit=NO;
	ChildView * child;
	
	[[document undoManager]beginUndoGrouping];
	
	[[self window] makeFirstResponder:self]; //?
	clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	child = [self childViewForPoint:clickLocation];
	if(child) childHit = YES;
	
	if(childHit	&& !([event modifierFlags] & NSShiftKeyMask) // not shift-click, 
	   && !([event modifierFlags] & NSControlKeyMask) //not control-click, 
	   && ([event clickCount] == 1)					// single click,
	   && !([event modifierFlags] & NSAlternateKeyMask)) { // not alt-click
		
		if(NSPointInRect([self convertPoint:clickLocation toView:child], [child resizeXCursorRect])){
			resizeDragging = YES;
			lastDragLocation=clickLocation;
			

			
			if(![selection containsObject:child]) {
				[self deselectAllChildViews];
				[self selectChildView:child];	
			}
		}
		else{
		
			dragging = YES;
			selDragging = NO;
			resizeDragging= NO;	
			if(![selection containsObject:child]){
				[self deselectAllChildViews];			
				[self selectChildView:child];
				//[self setNeedsDisplayInRect:[child redrawRect]];
			}
			lastDragLocation=clickLocation;
		}
	}
	else if(childHit  && ([event modifierFlags] & NSShiftKeyMask)){ // shift_click
		dragging = YES;
		selDragging = NO;
		resizeDragging= NO;	
		if([selection containsObject:child]){
			[self deselectChild:child];
		}
		else
			[self selectChildView:child];
		lastDragLocation=clickLocation;
		
	}
	else if(!childHit  && ([event clickCount] == 1)	){		// begin selDrag....
		BOOL extending = (([event modifierFlags] & NSShiftKeyMask) ? YES : NO);
		selDragging = YES;
		resizeDragging= NO;
		lastDragLocation = clickLocation;
		selectionRectOrigin = clickLocation;
		if(!extending){
			[self deselectAllChildViews];			
		}
	}
	else if(!childHit  && ([event clickCount] == 2)){//double click in empty space		
		
		[self doubleClickInEmptySpace:clickLocation];
	}
	else if (childHit && [event modifierFlags] & NSControlKeyMask && [event clickCount] == 1) { // control-click in child 
	
		resizeDragging = YES;
		lastDragLocation=clickLocation;
		if(![selection containsObject:child]) {
			[self deselectAllChildViews];
			[self selectChildView:child];	
		}
		
	}
	else if (childHit && [event modifierFlags] & NSAlternateKeyMask && [event clickCount] == 1){ // option(alt)-click
	
		resizeDragging = NO;
		dragging = YES;
		lastDragLocation = clickLocation;
		
		if(![selection containsObject:child]) {
			
			[self deselectAllChildViews];
			[self selectChildView:child];
		}
		[self duplicateSelection];
	}
	else if(childHit && [event clickCount]==2){
		[self selectChildView:child];
		[document showInspector:nil];
	
	}
	
	[self setNeedsDisplay:YES];
}
	

-(void)mouseDragged:(NSEvent *)event{

	if(![[self valueForKey:@"visible"]boolValue])
		return;

	NSPoint newDragLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	float deltaX = newDragLocation.x-lastDragLocation.x;
	float deltaY = newDragLocation.y-lastDragLocation.y;
	if(dragging && [event modifierFlags] & NSShiftKeyMask) { // shift -drag?
		//BOOL x, y;
		//x=y=NO;
		
		if(findShiftDragDirection){
			if(maxabs_float(newDragLocation.x-lastDragLocation.x))
				shiftDragDirectionX = YES;
			else
				shiftDragDirectionX = NO;

			findShiftDragDirection = NO;		
		}

		if(shiftDragDirectionX)
			deltaY = 0;
		else 
			deltaX = 0;
	}

		
	if(dragging){

		if ([self allowsHorizontalDrag] && [self allowsVerticalDrag]) {
			//[self moveSelectionByX:deltaX andY:deltaY];
			[self moveSelectionByValuesInSize:[NSValue valueWithSize:NSMakeSize(deltaX, deltaY)]];
		}
		else if([self allowsHorizontalDrag])
			//[self moveSelectionByX:deltaX andY:0];
			[self moveSelectionByValuesInSize:[NSValue valueWithSize:NSMakeSize(deltaX, 0)]];
		else if([self allowsVerticalDrag])
			//[self moveSelectionByX:0 andY:deltaY];
			[self moveSelectionByValuesInSize:[NSValue valueWithSize:NSMakeSize(0, deltaY)]];
	}
	else if(selDragging){
		[self setNeedsDisplayInRect:selRect];
		selRect = RectFromPoints(selectionRectOrigin, newDragLocation);
		[self setNeedsDisplayInRect:selRect];
	}
	else if(resizeDragging){
		newDragLocation=[self convertPoint:[event locationInWindow]
								  fromView:nil];
		[self resizeSelectedChildViewsByValuesInSize:[NSValue valueWithSize:NSMakeSize(newDragLocation.x-lastDragLocation.x, newDragLocation.y-lastDragLocation.y)]];
//		[self resizeSelectedChildViewsByX:newDragLocation.x-lastDragLocation.x andY: newDragLocation.y-lastDragLocation.y];
	}
	lastDragLocation=newDragLocation;
}

-(void)mouseUp:(NSEvent *)event{
	findShiftDragDirection = YES;
	
	[[document undoManager]endUndoGrouping];
	
	if(![[self valueForKey:@"visible"]boolValue])
		return;

	if(dragging){
		dragging = NO;
	}

	if(selDragging){
		selDragging = NO;
		[self setNeedsDisplayInRect:selRect];

		[self selectChildViews:[self childViewsInRect:selRect]];
		[selection makeObjectsPerformSelector:@selector(select)];
		selRect = NSZeroRect;
		if([selection count]>0)
			[self setNeedsDisplayInRect:[self unionRectForSelection]];
	}	
}

- (void)keyDown:(NSEvent *)event {
	if([event keyCode] == 36){
		if([document isPlaying]){
			[self createObjectWhilePlaying];
		}
		else
			[document setPlaybackStartTime:[NSNumber numberWithInt:0]];
	}
	else
		[self interpretKeyEvents:[NSArray arrayWithObject:event]]; 
}

-(IBAction)moveUp:(id)sender{

	NSValue * v = [NSValue valueWithSize:NSMakeSize(0, 1)];
	[self moveSelectionByValuesInSize:v];
//	[self moveSelectionByX:0 andY:1];
}

-(IBAction)moveDown:(id)sender{
	NSValue * v = [NSValue valueWithSize:NSMakeSize(0, -1)];
	[self moveSelectionByValuesInSize:v];
//	[self moveSelectionByX:0 andY:-1];
}

-(IBAction)moveLeft:(id)sender{
	NSValue * v = [NSValue valueWithSize:NSMakeSize(-1, 0)];
	[self moveSelectionByValuesInSize:v];
//	[self moveSelectionByX:-1 andY:0];
}

-(IBAction)moveRight:(id)sender{
	NSValue * v = [NSValue valueWithSize:NSMakeSize(1, 0)];
	[self moveSelectionByValuesInSize:v];
//	[self moveSelectionByX:1 andY:0];
}

-(IBAction)insertNewline:(id)sender{
}

-(void) insertText:(NSString *)string{

	if(![[self valueForKey:@"visible"]boolValue])
		return;

	if ([string isEqualToString:kContainerViewDefaultFoldString]) {
		[self foldSelection];
	}
	else if([string isEqualToString:kContainerViewDefaultUnfoldString]) {
		[self unfoldSelection];
	}
	else if([string isEqualToString:kPlayKeyString]){
		[document play];
	}
	else if([string isEqualToString:kMuteString]){
		[self toggleMuteSelection];
	}

}

-(IBAction)deleteBackward:(id)sender {
	
	if(![[self valueForKey:@"visible"]boolValue])
		return;

	ChildView * child;

	for (child in selection)
		[contentController removeObjectWithController:[child controller] inView:self];//[contentController removeSubObjectWithController:[child controller] withUpdate:NO];
	
	[contentController update];
	[self removeChildViews:selection];
	[selection removeAllObjects];
	[self setNeedsDisplay:YES];
}

-(IBAction)insertTab:(id)sender {

	if(![selection count]) 
		return;
	
	QuinceObjectController * current = [[selection lastObject]controller];
	QuinceObjectController * next = [contentController controllerOfNextSubObjectAfterController:current];
	
	if([next isEqualTo:current] || !next)
		return;
	
	[self deselectAllChildViews];
	[self selectChildView:[self childViewWithController:next]]; 
}

-(IBAction)insertBacktab:(id)sender{

	if(![selection count]) 
		return;
	
	QuinceObjectController * current = [[selection objectAtIndex:0]controller];
	QuinceObjectController *previous = [contentController controllerOfPreviousSubObjectBeforeController:current];
	
	if([previous isEqualTo:current] || !previous)
		return;
	
	[self deselectAllChildViews];
	[self selectChildView:[self childViewWithController:previous]];
}

-(void)selectAll:(id)sender{
	
	[self selectAllChildViews];
	[self setNeedsDisplay:YES];
}

-(void)doubleClickInEmptySpace:(NSPoint)location{
	
	[self deselectAllChildViews];
	if(!contentController)// we don't have a contentController, so ask the layer to create an empty content Object for us	
		[layerController newContentObject];

	[contentController createNewObjectForPoint:location inView:self]; 
}

-(void)createObjectWhilePlaying{

	double time = [[document cursorTime]doubleValue];
	if(time>=[[document playbackObjectCreationLatency]doubleValue])
		time-=[[document playbackObjectCreationLatency]doubleValue];

	float x = [[self convertTimeToX:[NSNumber numberWithDouble:time]]floatValue];
	
	float y = 10;
	NSPoint p = NSMakePoint(x, y);
	[self doubleClickInEmptySpace:p];//creates new object
	
}

#pragma mark settings

-(NSString *)parameterOnX{
	return [NSString stringWithString:@"time"];
}

-(NSString *)parameterOnY{
	return [NSString stringWithString:@"volume"];
}

-(BOOL)allowsVerticalDrag{
	return YES;
}

-(BOOL)allowsHorizontalDrag{
	return YES;
}

-(BOOL)allowsHorizontalResize{return YES;}
-(BOOL)allowsVerticalResize{return NO;}
-(BOOL)showGuides{return YES;}
-(BOOL)allowsNewSubObjectsToRepresentAudioFiles{return NO;}
-(BOOL)allowsPlayback{return YES;}
#pragma mark properties

-(NSColor *)backgroundColor{
	return [NSColor colorWithDeviceRed:0.8 green:0.8 blue:1 alpha:0];
}

-(NSArray *)types{
	return [NSArray arrayWithObject:[NSString stringWithString:@"QuinceObject"]];
}

-(NSString *)defaultChildViewClassName{
	return @"SequenceChild";
}

-(NSString *)defaultObjectClassName{return @"QuinceObject";}

-(NSMutableDictionary *)dictionary{
	[self updateDict];
	return dict;
}

-(void)setPixelsPerUnitX:(NSNumber *)newPpx{
	
//	float width = [self frame].size.width;
	float ppx = [[self valueForKey:@"pixelsPerUnitX"]floatValue];
	if(!ppx)return;
	float factor = (float)[newPpx floatValue] / ppx;
	//[self setFrameSize:NSMakeSize(width*factor, [self bounds].size.height)];	
	// RESIZING IS HANDLED ELSEWHERE
	//[childViews makeObjectsPerformSelector:@selector(update)];
	[self scaleByX:factor andY:1];
	[self setNeedsDisplay:YES];
}

-(void)setVolumeRange:(NSNumber *)volumeRange{
	if(![[self parameterOnY]isEqualToString:@"volume"])
		return;
	
	float ppy = [[self valueForKey:@"pixelsPerUnitY"]floatValue];
	
	float newPpy = ([self frame].size.height-kDefaultYAxisHeadRoom) /[volumeRange floatValue];
	//NSLog(@"volumeRange: %@, oldPpy: %f, newPpy: %f", volumeRange, ppy, newPpy);
	if(!ppy)return;
	//float factor = (float)newPpy / ppy;

	//[self scaleByX:1.0 andY:factor];
	[self setValue:[NSNumber numberWithFloat:newPpy] forKey:@"pixelsPerUnitY"];
	[dict setValue:volumeRange forKey:@"volumeRange"];
	[[self contentController]repositionViewsForKey:@"volume"];
	//[self computeVolumeGuides];
	[self setNeedsDisplay:YES];
	
}

-(void)setDocument:(QuinceDocument *)doc{
	document = doc;
}

-(void)updateDict{
	[self setValue:[contentController valueForKeyPath:@"selection.id"] forKey:@"contentID"];
}

-(NSArray *)selection{
	return selection;
}

#pragma mark child management

-(ChildView *)childViewForPoint:(NSPoint)point{
	
	ChildView * child;
	NSEnumerator * e = [childViews objectEnumerator];
	while ((child = [e nextObject])) {
		if(NSPointInRect(point, [child frame]))
			return child;
	}
	return nil;	
}

-(void)moveSelectionByValuesInSize:(NSValue *)sizeValue{


	NSSize delta = [sizeValue sizeValue];
	NSSize deltaMinus = NSMakeSize(-1*delta.width, -1*delta.height);
	[[document undoManager]registerUndoWithTarget:self selector:@selector(moveSelectionByValuesInSize:) object:[NSValue valueWithSize:deltaMinus]];
	[[document undoManager]setActionName:@"move"];
	
	[self moveSelectionByX:delta.width andY:delta.height];
}

-(void)moveSelectionByX:(float)x andY:(float)y{
	
	//NSRect before = [self unionRectForSelection];
	ChildView * child;
	for(child in selection){
		[child moveX:x];
		[child moveY:y];
	}
	[contentController update];
	
	//NSRect after = [self unionRectForSelection]; 
	//[self setNeedsDisplayInRect:NSUnionRect(before, after)];
} 

NSRect RectFromPoints(NSPoint point1, NSPoint point2) {
	
	return NSMakeRect(
					  ((point1.x <= point2.x) ? point1.x : point2.x),
					  ((point1.y <= point2.y) ? point1.y : point2.y),
					  ((point1.x <= point2.x) ? point2.x - point1.x : point1.x - point2.x),
					  ((point1.y <= point2.y) ? point2.y - point1.y : point1.y - point2.y));
}


-(NSPoint) convertPoint:(NSPoint)clickLocation toChildView:(ChildView *)child{
	
	NSPoint childLocation = [child location];
	return NSMakePoint(clickLocation.x-childLocation.x, clickLocation.y-childLocation.y);
}

-(void)reload{
	QuinceObjectController * qc = [self contentController];
	[self prepareToDisplayObjectWithController:qc];
}

-(void)prepareToDisplayObjectWithController:(QuinceObjectController *)mc{
		[self clear];
	float widthNeeded = [[mc valueForKeyPath:@"selection.duration"]floatValue]*[[self valueForKey:@"pixelsPerUnitX"]floatValue];
	if([self frame].size.width < widthNeeded)
		[[layerController mainController] resizeViewsForWidth:widthNeeded]; // bähh
	[self setContentController:mc];
	
	[self createViewsForQuinceObjectController:mc];
}

/*-(void)createViewsForQuinceObjectController:(QuinceObjectController *)mc{

	NSArray * subControllers = [mc controllersForSubObjects];
	//[document setIndeterminateProgressTask:[NSString stringWithFormat:@"%@: creating display...", [self className]]];
	//[document displayProgress:YES];
	for(QuinceObjectController * mc in subControllers)
		[self createChildViewForQuinceObjectController:mc];
	//[document displayProgress:NO];	
}*/

-(void)createViewsForQuinceObjectController:(QuinceObjectController *)mc{
    
	NSArray * subControllers = [mc controllersForSubObjects];
	QuinceObjectController * c;
    float progress, max = [subControllers count];
    //int iMax = max;
    [document setProgressTask:[NSString stringWithFormat:@"%@: creating display...", [self className]]];
	[document displayProgress:YES];
    NSString * lx = [self keyForLocationOnXAxis];
    NSString * sx = [self keyForSizeOnXAxis];
    NSString * ly = [self keyForLocationOnYAxis];
    
    
	for(int i=0; i<max;i++){//QuinceObjectController * mc in subControllers){
        //[document setProgressTask:[NSString stringWithFormat:@"%@: creating display...%d/%d", [self className], i, iMax]];
        c = [subControllers objectAtIndex:i];
		//[self createChildViewForQuinceObjectController:c];
        [self createChildViewForQuinceObjectController:c andBindWithKeysForLocationOnX:lx sizeOnX:sx locationOnY:ly];
        progress = 100.0 * ((i+1)/(max));
        [document setProgress:progress];
    }
	[document displayProgress:NO];	
}

-(void)clear{

	[self deselectAllChildViews];
	[self removeChildViews:childViews];
	[self setContentController:nil];
	[self setNeedsDisplay:YES];
}

-(ChildView *)createChildViewForQuinceObjectController:(QuinceObjectController *)mc{
	ChildView * childView = [layerController newChildViewOfClassNamed:[self defaultChildViewClassName]];
	[childView setEnclosingView:self];
	//[childView setController:mc];
    
	[mc registerChildView:childView];
	//[childView setInteriorColor:[mc color]];
	[childViews addObject:childView];
	[self addSubview:childView];
	return childView;	
}

-(ChildView *)createChildViewForQuinceObjectController:(QuinceObjectController *)mc andBindWithKeysForLocationOnX:(NSString *)lx sizeOnX:(NSString *)sx locationOnY:(NSString *)ly{
    
	ChildView * childView = [layerController newChildViewOfClassNamed:[self defaultChildViewClassName]];
	[childView setEnclosingView:self];
	[childView setController:mc andBindWithKeysForLocationOnX:lx sizeOnX:sx locationOnY:ly];
    
	[mc registerChildView:childView];
	//[childView setInteriorColor:[mc color]];
	[childViews addObject:childView];
	[self addSubview:childView];
	return childView;	
}

//-(void)setController:(QuinceObjectController *)mc andBindWithKeysForLocationOnX:(NSString *)lx sizeOnX:(NSString *)sx locationOnY:(NSString *)ly

-(ChildView *)childViewWithController:(QuinceObjectController *)mc{

	for(ChildView * mcv in childViews){
	
		if([[mcv controller]isEqualTo:mc]){
			return mcv;
		}
	}
	NSLog(@"MintContainerView: childViewWithController: no child view found for controller! controller content: %@", [mc content]);
	return nil;
}

-(NSArray *) childViewsInRect:(NSRect) rect {
	
	NSMutableArray * results = [[NSMutableArray alloc] init];
	ChildView * child;
	NSEnumerator * e = [childViews objectEnumerator];
	while((child = [e nextObject])) {
		if(NSIntersectsRect([child frame], rect))
			[results addObject:child];
	}
	return [results autorelease];
}
		
-(void)selectChildView:(ChildView *)child{


	if(!child){
	
		NSLog(@"MintContainerView: selectChildView: no child!");
		return;
	}
	
	[child select];

	if([child selected])	{	// maybe the child doesn't allow to be selected
		if(![selection containsObject:child])// make sure we don't get duplicates 
			[selection addObject:child];
		

		[document setValue:[child controller] forKey:@"selectedObject"];
	}	

}

-(void)deselectChild:(ChildView* )child{

	[child deselect];
	[selection removeObject:child];
}

-(void)deselectAllChildViews{
	[selection makeObjectsPerformSelector:@selector(deselect)];
	[selection removeAllObjects];		 
}

-(void)selectChildViews:(NSArray *)someViews{
	for(ChildView * child in someViews){
		[self selectChildView:child];
	}
}
		 
-(void)selectAllChildViews{
	[self deselectAllChildViews];// make sure we don't have any duplicates in the selection
	[self selectChildViews:[NSArray arrayWithArray: childViews]];
}

-(void)resizeSelectedChildViewsByValuesInSize:(NSValue *)sizeValue{
	
	NSSize delta = [sizeValue sizeValue];
	NSSize deltaMinus = NSMakeSize(-1*delta.width, -1*delta.height);
	[[document undoManager]registerUndoWithTarget:self selector:@selector(resizeSelectedChildViewsByValuesInSize:) object:[NSValue valueWithSize:deltaMinus]];
	[[document undoManager]setActionName:@"resize"];
	
	[self resizeSelectedChildViewsByX:delta.width andY:delta.height];// moveSelectionByX:delta.width andY:delta.height];
}

-(void)resizeSelectedChildViewsByX:(float) x	andY:(float)y{
	[selection makeObjectsPerformSelector:@selector(resize:)withObject:[NSValue valueWithSize:NSMakeSize(x, y)]];
	[contentController update];
	//[self setNeedsDisplay:YES];
}

-(NSRect) unionRectForSelection {
	return [self unionRectForArrayOfChildViews:selection];
}

-(NSRect)unionRectForArrayOfChildViews:(NSArray *)views{
	NSRect rect = NSZeroRect;
	ChildView * child;
	for(child in views)
		rect = NSUnionRect([child redrawRect], rect);
	return rect;	
}

-(void) duplicateSelection{

	ChildView * childView;
	QuinceObjectController * mc;
	NSMutableArray * copies = [NSMutableArray array];

	for(childView in selection){
		mc = [[self layerController] controllerForCopyOfQuinceObjectController:[childView controller] inPool:NO];
		childView = [self createChildViewForQuinceObjectController:mc];
		[copies addObject:childView];
		[contentController addSubObjectWithController:mc withUpdate:NO];
		[contentController addSubNodesForFoldedController:mc];
	}
	[contentController update];
	[self deselectAllChildViews];
	
	for(childView in copies)
		[self selectChildView:childView];
	
	[document willChangeValueForKey:@"objectNodes"];
	[document didChangeValueForKey:@"objectNodes"];
}

-(void)foldSelection{
	//if(![self animator])NSLog(@"MintView: no animator");
	if([selection count]<2 || !contentController)return;
	NSArray * childs = [NSArray arrayWithArray:selection];
	[self deselectAllChildViews];
	[contentController foldChildViews:childs inView:self];
}


-(ChildView *) createChildViewForFoldedController:(QuinceObjectController*)foldedController andBeginAnimationForChildViews:(NSArray *)foldedChildViews{
	
	ChildView * folded = [self createChildViewForQuinceObjectController:foldedController]; // create child for new folded object
	[self deselectAllChildViews];
	[self selectChildView:folded];
	//[folded setAlphaValue:0];		// but don't show it
	
	[folded setHidden:YES];
	
	//[folded setWantsLayer:YES];
	NSPoint p = [folded location];
	
	//[NSAnimationContext beginGrouping];
	
	//[[dummy animator]setAlphaValue:0];
//	[[dummy animator]setFrame:[folded frame]];
	
	[[NSAnimationContext currentContext] setDuration:0.6];
	for(ChildView * child in foldedChildViews){
		//[[child animator]setFrameOrigin:NSMakePoint([child frame].origin.x, p.y)];			// now animate folded childViews
		//[[child animator]setAlphaValue:0];

		[child setFrameOrigin:NSMakePoint([child frame].origin.x, p.y)];			// now animate folded childViews
		[child setAlphaValue:0];

	}
	//[[folded animator]setAlphaValue:1];
	//[NSAnimationContext endGrouping];
	
	[self performSelector:@selector(removeChildViews:) withObject:foldedChildViews afterDelay:0.6]; // then get rid of those obsolete child views
	[folded performSelector:@selector(setVisible:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
	
	return folded;
}

-(void)removeChildViews:(NSArray *) obsoleteViews{
	
	[obsoleteViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[childViews removeObjectsInArray:obsoleteViews];
}

-(void)removeChildViewForQuinceObjectController:(QuinceObjectController *)mc{
	
	
	ChildView * child = [self childViewWithController:mc];
	if(child){
		[self removeChildViews:[NSArray arrayWithObject:child]];
		[mc unregisterChildView:child];
	}
	
	/* for(ChildView * child in childViews){
			if([[child controller]isEqualTo:mc]){
				
				[self removeChildViews:[NSArray arrayWithObject:child]];
				[mc disconnectChildView:child];
			}
			
			//NSLog(@"MintContainerView: removeChildViewForQuinceObjectController:loopEND");
			break;
		} */
	
	//NSLog(@"MintContainerView: removeChildViewForQuinceObjectController: DONE");
}

-(void)unfoldSelection{

	if(![selection count])return;
	
	NSArray * childs = [NSArray arrayWithArray:selection];
	[self deselectAllChildViews];
	[contentController unfoldChildViews:childs inView:self];
}


-(NSArray *) createChildViewsForUnfoldedControllers:(NSArray *)unfoldedSubControllers andBeginAnimationForChildView:(ChildView *) superChild{

	NSMutableArray * newChildViews = [[NSMutableArray alloc]init];
	[self deselectAllChildViews];

	for(QuinceObjectController * mc in unfoldedSubControllers){
		ChildView * child = [self createChildViewForQuinceObjectController:mc];
		//[child setAlphaValue:0];
		[newChildViews addObject:child];
		[self selectChildView:child];
	}


	/* [NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:0.6];
	 */
	for(ChildView * child in newChildViews){
		//[[child animator]setAlphaValue:1.0];
		[child  setAlphaValue:1.0];
	}
	//[[superChild animator]setAlphaValue:0];
	[superChild setAlphaValue:0];
	
	
	//[NSAnimationContext endGrouping];
	[self performSelector:@selector(removeChildViews:) withObject:[NSArray arrayWithObject:superChild] afterDelay:0.6];
	
	return [newChildViews autorelease];
}

-(NSMutableArray *)childViews{return childViews;}

-(void)sortChildViewsLeft2Right{
	
	NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:@"locationX" ascending:YES];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	
	[childViews sortUsingDescriptors:descriptors];
	[sd release];
}

-(void)recolorChildren{
	NSLog(@"MintContainerView: recolor children...");
	for(ChildView * c in childViews){
	
		[c setNeedsDisplay:YES];
	}

	
}

-(void)toggleMuteSelection{

	if(![selection count]) return;
	for(ChildView * mcv in selection){
		[[mcv controller]toggleMute];
	}
	[self setNeedsDisplayInRect:[self unionRectForSelection]];
}

#pragma mark resize

-(void)scaleByX:(float)diffX andY:(float)diffY{

	[childViews makeObjectsPerformSelector:@selector(scaleByFactorsInSize:) withObject:[NSValue valueWithSize:NSMakeSize(diffX, diffY)]];
}


-(void)viewWillStartLiveResize{

	liveResize=YES;
}

-(void)viewDidEndLiveResize{

	liveResize=NO;
	[self setNeedsDisplay:YES];
}

-(void)updateViewsForCurrentSize{
}


#pragma mark keys and converters 

-(NSString *)keyForLocationOnXAxis{return @"start";}
-(NSString *)keyForLocationOnYAxis{return @"volume";}
-(NSString *)keyForSizeOnXAxis{return @"duration";}
-(NSString *)keyForSizeOnYAxis{return @"nothingToDisplay";}

-(NSNumber *)convertXToTime:(NSNumber *)x{
	
	double ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	double time = [x doubleValue]/ppx;
	return [NSNumber numberWithDouble:time];
}

-(NSNumber *)convertTimeToX:(NSNumber *)time{
	
	double ppx = [[self valueForKey:@"pixelsPerUnitX"]doubleValue];
	double x = [time doubleValue]*ppx;
	return [NSNumber numberWithDouble: x];
}

-(NSNumber *)convertYToVolume:(NSNumber *)y {
	
	float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
	float dB = 0 - ((sizeY - [y doubleValue]) / ppy);
	return [NSNumber numberWithDouble: dB] ;
	
}

-(NSNumber *)convertVolumeToY:(NSNumber *)dB{
	
	float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
	double y = sizeY + [dB doubleValue]*ppy;
	return [NSNumber numberWithDouble: y];
}

-(NSNumber *)convertVolumeToYDelta:(NSNumber *)dB{
	return [NSNumber numberWithFloat: [dB doubleValue]*[[self valueForKey:@"pixelsPerUnitY"]doubleValue]];	
}


-(NSNumber *)parameterValueForX:(NSNumber *)x{
	return [self convertXToTime:x];
}

-(NSNumber *)parameterValueForY:(NSNumber *)y{
	return [self convertYToVolume:y];
}

-(NSNumber *)xForParameterValue:(NSNumber *)p{
	return [self convertTimeToX:p];
}

-(NSNumber *)yForParameterValue:(NSNumber *)p{
	return [self convertVolumeToY:p];
}

-(NSNumber *)xDeltaForParameterValue:(NSNumber *)p{
	return [self convertTimeToX:p];
}

-(NSNumber *)yDeltaForParameterValue:(NSNumber *)p{
	return [self convertVolumeToYDelta:p];
}

float maxabs_float(float x){
	return x<0?x*(-1):x;
}

#pragma mark user feedback

-(void)presentAlertWithText:(NSString *)message{
	NSAlert * alert = [NSAlert alertWithMessageText:message defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@""];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert layout];
	[alert runModal];
}

@end

