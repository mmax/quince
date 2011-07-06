//
//  StripController.h
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

#import <Cocoa/Cocoa.h>

#import "StripLayerControlsArrayController.h"

#import <QuinceApi/ContainerView.h>

@class StripLayerControlsArrayController, MainController, EventInterceptView, ChildView, QuinceDocument;


@protocol SubviewTableViewControllerDataSourceProtocol 

- (NSView *) tableView:(NSTableView *) tableView viewForRow:(int) row;

@end


@interface StripController : NSViewController < SubviewTableViewControllerDataSourceProtocol >{

	IBOutlet NSTableView * subviewTableView;
	IBOutlet NSTableColumn *layerColumn;
	IBOutlet NSButton * removeRowButton;
	StripLayerControlsArrayController * tableViewController;
	EventInterceptView * interceptView;

    NSMutableArray * layerControllers;
    NSMutableArray * viewClassNames;	


	MainController * controller;
    QuinceDocument * document;
	
	BOOL volumeGuides;
}

@property (assign) MainController * controller;
@property (assign) QuinceDocument * document;

-(NSMutableArray *)layerControllers;
-(IBAction) addRow:(id) sender;
-(IBAction) removeRow:(id)sender;
-(int) numberOfRowsInTableView:(NSTableView *) tableView;
-(id) tableView:(NSTableView *) tableView objectValueForTableColumn:(NSTableColumn *) tableColumn row:(int) row;
- (NSView *) tableView:(NSTableView *) tableView viewForRow:(int) row;
-(ContainerView *)newContainerViewOfClassNamed:(NSString *)name;
-(void)replaceView:(ContainerView *)oldView withView:(ContainerView *)newView;
-(ContainerView *)replaceView:(ContainerView *)oldView withNewContainerViewOfClassNamed:(NSString *)name;
-(void)addView:(ContainerView *)newView;
-(void)addLayer;
-(LayerController *)activeLayerController;
-(ContainerView *)activeView;
-(void)resize:(NSValue *)size;
-(QuinceObject *)newObjectOfClassNamed:(NSString *)name;
-(ChildView *)newChildViewOfClassNamed:(NSString *)name;
-(void)redrawAllViewsInRect:(NSRect)r;
-(void)addObjectToObjectPool:(QuinceObject *)quince;
-(QuinceDocument *)document;
-(QuinceObjectController *)getSingleSelectedObjectController;
-(void)setFrame:(NSRect)frame;
-(NSRect)frame;
-(void)createLayersFromArray:(NSArray *)layers;
-(void)clear;
-(NSView *)interceptView;
-(void)activate;
-(void)deactivate;
-(NSMutableArray *)topLevelPlaybackList;
-(void)drawCursorForX:(double)x;
-(void)moveStripToNewY:(float)y;
-(void)relocate;
-(void)setVolumeRange:(int)db;
-(NSNumber *)volumeRange;
-(void)updateVolumeGuideFlag;
-(NSArray *)xml_layers;
-(NSString *)parameterOnYAxis;
-(int)layerCount;
@end


