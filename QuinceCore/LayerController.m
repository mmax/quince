//
//  LayerController.m
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

#import "LayerController.h"
#import "StripController.h"
#import <QuinceApi/QuinceDocument.h>

@implementation LayerController

@synthesize stripController, mainController;

+ (id) controller{
    return [[[self alloc] init] autorelease];
}

- (id) init{
    if ((self = [super init]) != nil){
		dict = [[NSMutableDictionary alloc]init];
		[self setValue:[NSDate date] forKey:@"date"];
		[self setValue:nil forKey:@"content"];
		[self setValue:nil forKey:@"view"];
		
        if (![NSBundle loadNibNamed: @"LayerControlsView" owner: self]){
            [self release];
            //self = nil;
			NSLog(@"LayerController:init: ;o(");
        }
	}
    return self;
}

- (void) dealloc{
    [subview release];
    [dict release];
    [super dealloc];
}

- (NSView *) tableViewSubview{
    return subview;
}


-(IBAction) toggleVisible:(id)sender{
	BOOL hidden  = [sender state] == NSOnState ? NO : YES;
	ContainerView * view = [self view];
	[view setHidden:hidden];
}

-(IBAction)changeView:(id)sender{
	
	NSString * name = [viewMenu titleOfSelectedItem];
	[self setViewWithName:name];
}

-(void)setViewWithName:(NSString *)name{
	
	ContainerView * newView, *oldView = [self valueForKey:@"view"];
	QuinceObjectController * mc = [self valueForKey:@"content"];
    QuinceDocument * doc = [stripController document];
    
    NSString * yPar = [stripController parameterOnYAxis];
    if ([stripController layerCount] == 1)
        yPar = nil;

    newView = [stripController newContainerViewOfClassNamed:name]; // temp, for checking
    NSString * viewYPar =    [newView parameterOnY];

    if (yPar != nil  && ![ viewYPar isEqualToString:yPar] ) {
        [doc presentAlertWithText:[NSString stringWithFormat:@"incompatible view: this strip needs parameter '%@' on the y-axis. the chosen view has '%@'", yPar, viewYPar]];
        return;
    }
	
	if(oldView != nil)
		newView = [stripController replaceView:oldView withNewContainerViewOfClassNamed:name];
	else {
		newView = [stripController newContainerViewOfClassNamed:name];
		[stripController addView:newView];
	}
	[newView setLayerController:self];
	[newView setDocument:[stripController document]];
	[newView bind:@"pixelsPerUnitX" toObject:[stripController controller] withKeyPath:@"pixelsPerUnitX" options:nil];
	[newView bind:@"volumeRange" toObject:[stripController controller] withKeyPath:@"volumeRange" options:nil];
	
	[self setValue:newView forKey:@"view"];
	if(mc){
		if(![self loadObjectWithController:mc]){
			NSLog(@"LayerController: changeView: loading failed!");
			[self setValue:nil forKey:@"content"];
		}
	}	
	
	if (![[viewMenu titleOfSelectedItem] isEqualToString:name])// if this method was called programatically,
		[viewMenu selectItem:[viewMenu itemWithTitle:name]];  // make sure the current view's name is displayed in the popup...
}

-(BOOL)loadObjectWithController:(QuinceObjectController *)mc{
	if(!mc)return NO;
	[[[mainController document] undoManager] registerUndoWithTarget:self selector:@selector(loadObjectWithController:) object:[[self view] contentController]];
	[[[mainController document] undoManager] setActionName:@"load"];

	ContainerView * view = [self view];
	QuinceObject * quince = [mc content];
	[view clear];
	if([view typeCheckModel:quince]){
		
		QuinceObjectController * previousContent = [view contentController];
		
		if(previousContent)
			[previousContent unregisterContainerView:view];
		[mc registerContainerView:view];
		[mc prepareForDisplayInView:view];
		
		
		[self willChangeValueForKey:@"content"];
		[self setValue:mc forKey:@"content"];
		[self didChangeValueForKey:@"content"];
		//NSLog(@"%@: loadObjectWithControler: content: ", [self className]);
		//[quince log];
		[view setValue:[[stripController controller]valueForKey:@"volumeRange"] forKey:@"volumeRange"];
		[view prepareToDisplayObjectWithController:mc];
		
		return YES;
	}
	else {
		[view presentAlertWithText:
		 [NSString stringWithFormat:@"Object %@ Incompatible with this View", [quince valueForKey:@"type"]]];	
		return NO;	
	}
}


-(IBAction)load:(id)sender{
	
	QuinceObjectController * mc = [stripController getSingleSelectedObjectController];
	[self loadObjectWithController:mc];
}

-(id)valueForKey:(NSString *)key{
	return [dict valueForKey:key];
}

-(id)valueForKeyPath:(NSString *)keyPath{

	NSArray * keys = [keyPath componentsSeparatedByString:@"."];
	id val = self;
	for(NSString * key in keys)
		val = [val valueForKey:key];
	return val;
}

-(void)setValue:(id)value forKey:(NSString *)key{

	[dict setValue:value forKey:key];
}

-(void)setViewClassNames:(NSArray *)classNames{
	
	for(NSString * n in classNames)
		[viewArrayController addObject:[NSString stringWithString:n]];	
}

-(ContainerView *)view{
	return [self valueForKey:@"view"];
}

-(QuinceObject *)newQuinceObjectOfClassNamed:(NSString *)name{
	return [stripController newObjectOfClassNamed:name];
}

-(ChildView *)newChildViewOfClassNamed:(NSString *)name{
	return [stripController newChildViewOfClassNamed:name];
}

-(StripController *)stripController{
	return stripController;
}

-(void)addObjectToObjectPool:(QuinceObject *)quince{
	[stripController addObjectToObjectPool:quince];
}

-(QuinceObjectController *)controllerForNewObjectOfClassNamed:(NSString *)name inPool:(BOOL)addToPool{
	QuinceDocument * doc = [[stripController controller]document];
	return [doc controllerForNewObjectOfClassNamed:name inPool:addToPool];
}
-(QuinceObjectController *)controllerForCopyOfQuinceObjectController:(QuinceObjectController *)mc inPool:(BOOL)addToPool{
	QuinceDocument * doc = [[stripController controller]document];
	return [doc controllerForCopyOfQuinceObjectController:mc inPool:addToPool];
}

-(void)newContentObject{
	ContainerView * view = [self view];
	QuinceObjectController * content = [self controllerForNewObjectOfClassNamed:[view defaultObjectClassName] inPool:YES];
	[self loadObjectWithController:content];
}

-(void)setFrame:(NSValue *)frameVal{

	NSRect frame = [frameVal rectValue];
	[(ContainerView *)[self valueForKey:@"view"]setFrame:frame];
}

-(void)updateViewForCurrentSize{
	ContainerView * view = [self valueForKey:@"view"];
	[view updateViewsForCurrentSize];
}

-(NSDictionary *)dictionary{
	
	NSMutableDictionary * d = [[NSMutableDictionary alloc]init];
	ContainerView * view = [self valueForKey:@"view"];
	
	[d setValue: [view className] forKey:@"containerViewClass"];
	[d setValue: [[view contentController]valueForKeyPath:@"selection.id"] forKey:@"content"] ;

	return d;
}

-(void)clear{

	ContainerView * view = [self view];
	[view clear];
	
	[self willChangeValueForKey:@"content"];
	//[self setValue:nil forKey:@"content"];
	[dict removeObjectForKey:@"content"];
	[self didChangeValueForKey:@"content"];
	
}


-(void)moveLayerToNewY:(float)y{
	
	//NSLog(@"LayerController:moveToNewY:%f", y);
	ContainerView * view = [self view];
	NSRect r = [view frame];
	r.origin.y = y;
	[view setFrame:r];
}

-(NSString *)parameterOnYAxis{
    ContainerView * view = [self valueForKey:@"view"];
    if(!view)return nil;
    return [view parameterOnY];
}
@end
