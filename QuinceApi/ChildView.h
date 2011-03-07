//
//  ChildView.h
//  QuinceApi
//
//  Created by max on 4/14/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kDefaultHeight 6
#define kDefaultWidth 6

#define kMinimumWidth 6
#define kMinimumHeight 6

#define kMaximumWidth	999999999
#define kMaximumHeight 1000

@class ContainerView, QuinceObject, QuinceObjectController;

@interface ChildView : NSView {
	QuinceObjectController * controller;
	ContainerView *	enclosingView;
	NSMutableDictionary * dict;
	NSRect resizeXCursorRect;
	NSCursor * resizeXCursor;
}

-(NSRect)	rect;
-(NSRect) redrawRect;
-(void)		setLocation:(NSPoint)point;
-(NSPoint)	location;
-(void)	setFrameColor:(NSColor *)c;
-(NSColor *)frameColor;
-(void)		setInteriorColor:(NSColor *)c;
-(NSColor *)interiorColor;
-(NSColor *)selectionColor;
-(void)setSelectionColor:(NSColor *)color;
-(void)		setHeight:(float)h withUpdate:(BOOL)b;
-(void)		setWidth:(float)w withUpdate:(BOOL)b;
-(float)	height;
-(float)	width;
-(NSSize)	size;
-(float)	foldedItemHeight;
-(NSRect) resizeXCursorRect;
-(void)		draw;
-(void)		moveX:(float)x;
-(void)		moveY:(float)y;

-(void)	setEnclosingView:(ContainerView *)view;
-(ContainerView *)enclosingView;

-(id)valueForKey:(NSString *)key;						
-(void)setValue:(id)value forKey:(NSString *)key;	
-(void)communicateLocation;
-(void)communicateSize;

-(void)select;
-(void)deselect;
-(BOOL)selected;

-(void)resize:(NSValue *)deltaValue;
-(void)scaleByFactorsInSize:(NSValue*)val;
-(void)scaleX:(float)x;
-(void)scaleY:(float)y;
-(BOOL)allowsHorizontalResize;		//default : YES
-(BOOL)allowsVerticalResize;			//default : YES
-(int)minimumWidth;
-(int)minimumHeight;
-(int)maximumHeight;
-(int)maximumWidth;
-(NSString *)description;
-(BOOL)canBeDirectlyCreatedByUser;
-(NSPoint)center;
-(void)setController:(QuinceObjectController *)mc;
-(QuinceObjectController *)controller;
-(void)bindToController;
-(void)setVisible:(NSNumber *)v;
@end


