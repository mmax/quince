//
//  LayerController.h
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

@class StripController, ContainerView, QuinceObject, ChildView, QuinceObjectController, MainController;

@interface LayerController : NSObject {
	
		
	IBOutlet NSView *subview; //for tableView
	IBOutlet NSArrayController * viewArrayController;
	IBOutlet NSPopUpButton * viewMenu;
	NSMutableDictionary * dict;
	BOOL visible;
	
	StripController * stripController;
	MainController * mainController;
}

@property (assign) StripController * stripController;
@property (assign) MainController * mainController;
// Convenience factory method
+ (id) controller;

- (NSView *) tableViewSubview;
-(IBAction)toggleVisible:(id)sender;
-(void)loadAnyCompatibleView;
-(IBAction)changeView:(id)sender;
-(BOOL)isCompatibleViewClass:(NSString *)name;
-(NSString *)anyCompatibleViewClassName;
-(void)setViewWithName:(NSString *)name;
-(IBAction)load:(id)sender;
-(id)valueForKey:(NSString *)key;
-(void)setValue:(id)value forKey:(NSString *)key;
-(id)valueForKeyPath:(NSString *)keyPath;
-(void)setViewClassNames:(NSArray *)classNames;
-(ContainerView *)view;
-(QuinceObject *)newQuinceObjectOfClassNamed:(NSString *)name;
-(ChildView *)newChildViewOfClassNamed:(NSString *)name;
-(BOOL)loadObjectWithController:(QuinceObjectController *)mc;
-(StripController *)stripController;
-(void)addObjectToObjectPool:(QuinceObject *)quince;
-(QuinceObjectController *)controllerForNewObjectOfClassNamed:(NSString *)name inPool:(BOOL)addToPool;
-(QuinceObjectController *)controllerForCopyOfQuinceObjectController:(QuinceObjectController *)mc inPool:(BOOL)addToPool;
-(void)newContentObject;
-(void)setFrame:(NSValue *)frameVal;
-(NSDictionary *)dictionary;
-(void)clear;
-(void)updateViewForCurrentSize;
-(void)moveLayerToNewY:(float)y;
-(NSString *)parameterOnYAxis;
@end
