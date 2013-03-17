//
//  StripController.m
//  quince
//
//  Created by max on 4/9/10.
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

#import "StripController.h"
#import "EventInterceptView.h"
#import <QuinceApi/ChildView.h>
#import <QuinceApi/QuinceObject.h>
#import <QuinceApi/QuinceDocument.h>
#import "MainController.h"

@implementation StripController

@synthesize controller;
@synthesize document;


-(StripController *)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	
	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])){
        dictionary = [[NSMutableDictionary alloc]init];
        [self setValue:[NSNumber numberWithBool:NO
                        ] forKey:@"drawGuides"];
		[self loadView];
		layerControllers = [[NSMutableArray alloc] init];
        //[guidesButton bind:@"value" toObject:self withKeyPath:@"drawGuides" options:nil];
        //[self bind:@"drawGuides" toObject:guidesButton withKeyPath:@"value" options:nil];
	}
	return self;
}

- (void) dealloc{

	[self clear];
	[tableViewController release]; // is retained in awakeFromNib
    [layerControllers release];
	 if(interceptView)
			[interceptView release];
	//[dictionary release];
    [super dealloc];
}

- (NSMutableArray *) layerControllers{
    if (layerControllers == nil)
        layerControllers = [[NSMutableArray alloc] init];
    
    return layerControllers;
}

- (void) validateButtons{
    [removeRowButton setEnabled: ([subviewTableView numberOfSelectedRows] > 0)];
}

- (void) awakeFromNib{

    tableViewController = [[StripLayerControlsArrayController controllerWithViewColumn: layerColumn] retain];
    [tableViewController setDelegate: self];
    //[guidesButton bind:@"value" toObject:self withKeyPath:@"drawGuides" options:nil];
    [self validateButtons];
}



- (IBAction) addRow:(id) sender{
	[[[controller document]undoManager]registerUndoWithTarget:self selector:@selector(createLayersFromArray:) object:[self xml_layers]];
	[[[controller document]undoManager]setActionName:@"Add Layer"];
	/* if(interceptView){
			
			//[interceptView removeFromSuperview];
			if(interceptView) [interceptView release];
		}
		 */
	
	if(!interceptView){
		interceptView = [[EventInterceptView alloc]initWithFrame:[controller frameForStripWithStripControl:self]];
		[interceptView setStripController:self];
		[[controller contentView]addSubview:interceptView];
        [interceptView computeGuides];
	}
	
	LayerController * slc = [LayerController controller];
	[slc setViewClassNames:[controller containerViewClassNames]];
	[slc setStripController:self];
	[slc setMainController:controller];
    [slc setDocument:document];
		
	[[self layerControllers] addObject: slc];
    [slc loadAnyCompatibleView];

    [tableViewController reloadTableView];
	[subviewTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[layerControllers count]-1] byExtendingSelection:NO];
	
	//[self updateVolumeGuideFlag];
	
	
	return;
}

/*-(void)updateVolumeGuideFlag{
	for(LayerController * lc in layerControllers){
		volumeGuides = NO;
		if([[[lc view] parameterOnY]isEqualToString:@"volume"] && [[lc view] showGuides]){
			volumeGuides = YES;
			[interceptView computeVolumeGuides];
			break;
		}
	}
}*/

 - (IBAction) removeRow:(id) sender{
	 [[[controller document]undoManager]registerUndoWithTarget:self selector:@selector(createLayersFromArray:) object:[self xml_layers]];
	 [[[controller document]undoManager]setActionName:@"Remove Layer"];
	 
	NSIndexSet *selectedRows = [subviewTableView selectedRowIndexes];
	unsigned int index = [selectedRows lastIndex];
	[[[layerControllers objectAtIndex:index]valueForKey:@"view"]removeFromSuperview];
	[[self layerControllers] removeObjectAtIndex: index];
	[tableViewController reloadTableView];
	[self validateButtons];
// 	[self updateVolumeGuideFlag];
} 

- (NSView *) tableView:(NSTableView *) tableView viewForRow:(int) row{
    return [[[self layerControllers] objectAtIndex: row] tableViewSubview];
}

- (void) tableViewSelectionDidChange:(NSNotification *) notification{
    [self validateButtons];
}

- (int) numberOfRowsInTableView:(NSTableView *) tableView{
    return [[self layerControllers] count];
}

- (id) tableView:(NSTableView *) tableView objectValueForTableColumn:(NSTableColumn *) tableColumn row:(int) row{
    id obj = nil;    
    return obj;
}

-(ContainerView *)newContainerViewOfClassNamed:(NSString *)name{
	int viewIndex = [[controller containerViewClassNames] indexOfObject:name];
	ContainerView * newView = [[[[controller containerViewClasses] objectAtIndex:viewIndex]alloc]initWithFrame:[controller frameForStripWithStripControl:self]];
	return [newView autorelease];
}

-(void)replaceView:(ContainerView *)oldView withView:(ContainerView *)newView{
	NSView * sv = [oldView superview];
	NSArray * subviews = [sv subviews];
	int count = [subviews count];
	
	if(count<2)
		[sv addSubview:newView];
	else {
		NSView * relativeView;
		int index = [subviews indexOfObject:oldView];
		if(index > 0){
			relativeView = [subviews objectAtIndex:index-1];
			[sv addSubview:newView positioned:NSWindowAbove relativeTo:relativeView];
		}
		else{
			relativeView = [subviews objectAtIndex:1];
			[sv addSubview:newView positioned:NSWindowBelow relativeTo:relativeView];
		}
	}
	[oldView removeFromSuperview];
}

-(ContainerView *)replaceView:(ContainerView *)oldView withNewContainerViewOfClassNamed:(NSString *)name{

	ContainerView * newView = [self newContainerViewOfClassNamed:name];
	[self replaceView:oldView withView:newView];
	return newView;
}

-(void)addView:(ContainerView *)newView{

	NSView * cv = (NSView *)[controller contentView];
	//NSArray * subviews = [cv subviews];

	
	[cv addSubview:newView positioned:NSWindowBelow relativeTo:interceptView];		// this line was inserted replacing the following if-else
																					// it fixed a bug where some user events where not received by the view in the selected layer
	
	/* 
		if([subviews count])
			[cv addSubview:newView positioned:NSWindowBelow relativeTo:[subviews objectAtIndex:count-1]];
		else 
			[cv addSubview:newView positioned:NSWindowBelow relativeTo:interceptView];////[cv addSubview:newView];	 */
	
	
	
}

-(LayerController *)addLayer{
	[self addRow:nil];
    return [layerControllers lastObject];
}

-(ContainerView *)activeView{
	
	LayerController * active = [self activeLayerController];
	if(active)
		return [active view];
	return nil;
}

-(LayerController *)activeLayerController{
	if([layerControllers count])
		return [layerControllers objectAtIndex: [subviewTableView selectedRow]];
	return nil;
}

-(void)resize:(NSValue *)size{
	
	[self setFrame:[controller frameForStripWithStripControl:self]];

}

-(QuinceObject *)newObjectOfClassNamed:(NSString *)name{
	return [controller newObjectOfClassNamed:name];
}

-(ChildView *)newChildViewOfClassNamed:(NSString *)name{
	return [controller newChildViewOfClassNamed:name];
}

-(void)redrawAllViewsInRect:(NSRect)r{

	for(LayerController * slc in layerControllers){
	
		ContainerView * view = [slc view];
		[view setNeedsDisplayInRect:r];
	}
}

-(void)addObjectToObjectPool:(QuinceObject *)quince{

	[controller addObjectToObjectPool:quince];
}

/*-(QuinceDocument *)document{
	return [controller document];
}*/

-(QuinceObjectController *)getSingleSelectedObjectController{

	return [[self document] getSingleSelectedObjectController];
}

-(void)setFrame:(NSRect)frame{

	[interceptView setFrame:frame];
	[layerControllers makeObjectsPerformSelector:@selector(setFrame:) withObject:[NSValue valueWithRect:frame]];
}

-(void)updateViewsForCurrentSize{
	[layerControllers makeObjectsPerformSelector:@selector(updateViewForCurrentSize)];
}

-(NSRect)frame{
	return [interceptView frame];
}

-(void)createLayersFromArray:(NSArray *)layers{
	[[[controller document]undoManager]registerUndoWithTarget:self selector:@selector(createLayersFromArray:) object:[self xml_layers]];
	[[[controller document]undoManager]setActionName:@"Rebuild Layers"];

	[self clear];
    BOOL propertiesSet = NO;
   // [self setStripPropertiesWithLayerDictionary:[layers lastObject]];
    
	for(NSDictionary * layer in layers){	
		[self addLayer];
		LayerController * lc = [layerControllers lastObject];
		QuinceObjectController * contentController = [[controller document] controllerForObjectWithID:[layer valueForKey:@"content"]];
		[lc setViewWithName:[layer valueForKey:@"containerViewClass"]];
        if(!propertiesSet){
            [self setStripPropertiesWithLayerDictionary:layer];
            propertiesSet = YES;
        }
		[lc loadObjectWithController:contentController];
	}
//	[self updateVolumeGuideFlag];
}

-(void)setStripPropertiesWithLayerDictionary:(NSDictionary *)d{
    NSDictionary * sProperties = [d valueForKey:@"stripProperties"];
    if(!sProperties) {
        NSLog(@"[StripController setStripPropertiesWithLayerDictionary:]: no stripProperties entry found in LayerDictionary");   
        return;
    }
   // NSLog(@"setting properties");
    [self setValue:[sProperties valueForKey:@"minYValue"] forKey:@"minYValue"];
    [self setValue:[sProperties valueForKey:@"maxYValue"] forKey:@"maxYValue"];    
    [self setValue:[sProperties valueForKey:@"drawGuides"] forKey:@"drawGuides"];
}


-(void)clear{
    //[guidesButton unbind:@"value"];
	for(LayerController * lc in layerControllers)
		[[lc valueForKey:@"view" ] removeFromSuperview];

	[layerControllers removeAllObjects];
	[tableViewController reloadTableView];
	[self validateButtons];
//	[self updateVolumeGuideFlag];
}

-(NSView *)interceptView{
	return interceptView;
}

-(void)activate{
	[interceptView setActive:YES];
}

-(void)deactivate{
	[interceptView setActive:NO];
}

-(NSMutableArray *)topLevelPlaybackList{
	NSMutableArray * tlp = [[NSMutableArray alloc]init];
	for(LayerController * lc in layerControllers){
		if([[lc view]contentController] && [[lc view]allowsPlayback] )
			   [tlp addObject:[[controller document] controllerForCopyOfQuinceObjectController:[[lc view]contentController] inPool:NO]];
	}
	return [tlp autorelease];
}

-(void)drawCursorForX:(double)x{
	[interceptView drawCursorForX:x];
}

-(void)moveStripToNewY:(float)y{

	//NSLog(@"StripController:moveToNewY:%f", y);
	for(LayerController * lc in layerControllers){
		[lc moveLayerToNewY:y];
	}
	NSRect r = [interceptView frame];
	r.origin.y = y;
	[interceptView setFrame:r];
}

-(void)relocate{

	[self setFrame:[controller frameForStripWithStripControl:self]];
}

/*-(void)setVolumeRange:(int)db{
	[interceptView computeVolumeGuides];
}*/

-(NSNumber *)volumeRange{
	return [controller valueForKey:@"volumeRange"];
}

-(NSArray *)xml_layers{
	 NSMutableArray * layerArray = [[NSMutableArray alloc]init];
		
	 for(LayerController * lc in layerControllers)	
		 [layerArray addObject:[lc dictionary]];
	
	return [layerArray autorelease];
}

-(NSDictionary *)stripProperties{

    NSMutableDictionary * d = [[NSMutableDictionary alloc]init];
    [d setValue:[self valueForKey:@"minYValue"] forKey:@"minYValue"];
    [d setValue:[self valueForKey:@"maxYValue"] forKey:@"maxYValue"];
    [d setValue:[self valueForKey:@"drawGuides"] forKey:@"drawGuides"];
    return [d autorelease];
}

-(NSString *)parameterOnYAxis{

    if(![layerControllers count])
        return nil;
    return [[layerControllers objectAtIndex:0]parameterOnYAxis];
}

-(int)layerCount{

    return [layerControllers count];
}

-(BOOL)shouldShowPositionGuides{

    return [[document valueForKey:@"showPositionGuides"]boolValue];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark KVC

-(id)valueForKey:(NSString *)key{
    //	NSLog(@"Doc: key: %@", key);
	return [dictionary valueForKey:key];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(id)valueForKeyPath:(NSString *)keyPath{
    
	
	NSArray * keys = [keyPath componentsSeparatedByString:@"."];
	id val = dictionary;
    
	for(NSString * key in keys){	
		val = [val valueForKey:key];
	}
	return val;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setValue:(id)aValue forKey:(NSString *)aKey{
	
	[self willChangeValueForKey:aKey];
	[dictionary setValue:aValue forKey:aKey];
	[self didChangeValueForKey:aKey];
    
    if([aKey isEqualToString:@"drawGuides"]){
        [interceptView prepareGuides];
        [interceptView setNeedsDisplay:YES];
    }

    if([aKey isEqualToString:@"minYValue"] || [aKey isEqualToString:@"maxYValue"]){
        //
        //NSLog(@"StripController:new ppuy -> redraw!");
        //[layerControllers makeObjectsPerformSelector:@selector(redrawView)];
        [self resetPPUY];
    }
    
    if([aKey isEqualToString:@"pixelsPerUnitY"])
        [layerControllers makeObjectsPerformSelector:@selector(reload)];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)resetPPUY{
   //NSLog(@"resetPPUY");
    double min = [[self valueForKey:@"minYValue"]doubleValue];
    double max = [[self valueForKey:@"maxYValue"]doubleValue];
    double ppuy = ([[[layerControllers lastObject] view]frame].size.height-kDefaultYAxisHeadRoom)/fabs(max-min);
    [self setValue:[NSNumber numberWithDouble:ppuy] forKey:@"pixelsPerUnitY"];
    [interceptView computeGuides];
    
}
@end
