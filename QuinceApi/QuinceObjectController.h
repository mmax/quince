//
//  QuinceObjectController.h
//  quince
//
//  Created by max on 4/5/10.
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
#import <QuinceApi/QuinceObject.h>
#import <QuinceApi/ContainerView.h>
#import <QuinceApi/QuinceDocument.h>

@interface QuinceObjectController : NSObjectController{

	NSTreeNode * node;
	QuinceDocument * document;
	NSMutableSet * registeredContainerViews;
	NSMutableSet * registeredChildViews;
	NSColor * color;
	NSMutableDictionary * dictionary;
}

@property (retain) 	NSTreeNode * node;
@property (assign) 	QuinceDocument * document;
//@property (assign) 	ChildView * childView;

-(void)addSubObjectWithController:(QuinceObjectController *)mc withUpdate:(BOOL)b;
-(void)removeSubObjectWithController:(QuinceObjectController *)mc withUpdate:(BOOL)b;
-(void)removeSubObjects;
-(void)addSubNodeForQuinceObject:(QuinceObject *)quince;
-(void)addSubNodesForFoldedController:(QuinceObjectController *)mc;
-(NSArray *)controllersForSubObjects;
-(QuinceObjectController *)superController;
-(void)update;
-(QuinceObjectController* )foldControllers:(NSArray *)subControllers;
-(void)foldChildViews:(NSArray *)childViews inView:(ContainerView *)view;
-(void)unfoldChildView:(ChildView *)child inView:(ContainerView *)sourceView;
-(void) unfoldChildViews:(NSArray *)childViews inView:(ContainerView *)sourceView;
-(NSArray *)unfoldController:(QuinceObjectController *)mc;
-(void)createChildViewsForQuinceObjectController:(QuinceObjectController *)mc;
-(void)registerContainerView:(ContainerView *)view;
-(void)unregisterContainerView:(ContainerView *)view;
-(NSSet *)registeredContainerViews;
-(void)createNewObjectForPoint:(NSPoint)location inView:(ContainerView *)view;
-(void)removeObjectWithController:(QuinceObjectController *)mc inView:(ContainerView *)view;
-(void)addObjectWithController:(QuinceObjectController *)mc inView:(ContainerView *)view;
-(NSNumber *)offsetForKey:(NSString *)key;
-(BOOL)isDisplayed;
-(void)prepareForDisplayInView:(ContainerView *)view;
-(void)initContentWithXMLDictionary:(NSDictionary *)dictionary;
-(void)repositionViewsForKey:(NSString *)key;
/* -(void)setValue:(id)aValue forKey:(NSString *)aKey;
-(id)valueForKeyPath:(NSString *)keyPath;
-(id)valueForKey:(NSString *)key; */
-(void)changeColor:(id)something;
-(void)sortChronologically;
-(QuinceObjectController *)controllerOfNextSubObjectAfterController:(QuinceObjectController *)mc;
-(QuinceObjectController *)controllerOfPreviousSubObjectBeforeController:(QuinceObjectController *)mc;
-(QuinceObjectController *)copyOfController:(QuinceObjectController *)mc withSubObjects:(BOOL)subs addAsSubObject:(BOOL)b;
-(void)migrateSubObjects:(NSArray *)subs toController:(QuinceObjectController*)mc;
-(void) toggleMute;
-(void)unregisterChildView:(ChildView *)child;
-(void)registerChildView:(ChildView *)child;
-(id)changedParameter;
-(void)updateObjectInspector;
-(void)createFreqEntry;
-(void)createFreqBEntry;
-(void)switchGlissandoDirection;
@end
