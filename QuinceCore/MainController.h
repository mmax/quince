//
//  MainController.h
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

#import <Cocoa/Cocoa.h>

#import "StripController.h"

@class QuinceDocument, QuinceObject, ChildView, MainScrollerDocumentView, StripController;

#define kDefaultStripHeight 188
#define kDefaultStripControlWidth 151
#define kHorizontalStripOffset 0
#define kVerticalStripOffset 2
#define kDefaultPixelsPerUnitX 20
#define kMinimumContentWidth 0.001

@interface MainController : NSObject {


	IBOutlet QuinceDocument * doc;
	IBOutlet MainScrollerDocumentView * mainScrollerDocumentView;
	IBOutlet NSView * stripControlDocumentView;
	IBOutlet NSScrollView * mainScrollView;
	IBOutlet NSScrollView * stripControlScrollView;
	IBOutlet NSTextField * volumeRangeTextField;
	
	NSMutableArray * strips;
	NSMutableDictionary * dictionary;
	NSMutableArray * stripControllScrollViews;
	int count;
	NSNumber * pixelsPerUnitX;
	NSArray * quinceViewClasses;

	NSMutableArray * stripControllers;
	StripController * activeStripController;
	float zoomSliderValue;
	float cursorTime;
}

-(MainController *)init;
-(void)getReady; //called from QuinceDocument -> windowControllerDidLoadNib...
-(QuinceDocument *)document;
-(void)scrollStripControlScroll:(NSNotification *)notification;
-(void)updateHorizontalRuler;
-(StripController *)createStrip;
-(void)removeActiveStrip;
-(void)removeStripWithStripController:(StripController *)sc;
-(void)clear;
-(void)setContainerViewClasses:(NSArray *)classes;
-(NSArray *)containerViewClassNames;
-(NSArray *)containerViewClasses;
-(void)redrawAllViewsOfStripWithView:(ContainerView *)aView inRect:(NSRect)r;
-(IBAction)changeHorizontalZoomWithSlider:(id)sender;
-(IBAction)changeVolumeRangeWithSlider:(id)sender;
-(void)changeHorizontalZoom:(float)y fromPoint:(NSPoint)scrollPoint;
-(void)setPPX:(float) ppx fromPoint:(NSPoint)scrollPoint;
-(void)updateViewsForCurrentSize;
-(ChildView *)newChildViewOfClassNamed:(NSString *)name;
-(QuinceObject *)newObjectOfClassNamed:(NSString *)name;
//-(void)createViewEntriesInDictionary;
//-(NSDictionary *)dictionary;
-(void)removeObjectForKey:(NSString *)key;
-(void)addObjectToObjectPool:(QuinceObject *)quince;
//-(void)resizeViewsForWidth:(float)width;
-(void)resize:(NSSize)size;
-(NSRect)frameForStripWithStripControl:(StripController *)sc;
-(MainScrollerDocumentView *)contentView;
-(void)resizeViewsForWidth:(float)width;
-(void)createViewsFromDictionary:(NSDictionary *)d;
-(void)rearrangeStripControls;
-(float)yForStripWithIndex:(int)index;
-(void)rearrangeStrips;
-(NSRect) unionRectForAllStrips;
-(void)setActiveStripController:(StripController *)sc;
-(ContainerView *)activeView;
-(NSMutableArray *)topLevelPlaybackList;
-(void)drawCursorForTime:(double)time;
-(void)setCursorToPoint:(NSPoint)clickLocation;
-(void)createViewEntriesInDictionary:(NSMutableDictionary *)dict;
-(NSDictionary *)xmlDictionary;
-(void)hideViews:(BOOL)b;
-(void)adjustSizes;
-(NSArray *)stripControllers;
@end
