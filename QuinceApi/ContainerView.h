//
//  ContainerView.h
//  quince
//
//  Created by max on 2/19/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@class QuinceDocument, ChildView, QuinceObject, StripController, LayerController, QuinceObjectController;

#define kDefaultYAxisHeadRoom 20
#define kDefaultVolumeRange 40

@interface ContainerView : NSView {

	
	BOOL dragging;
	BOOL selDragging;
	BOOL resizeDragging;
	BOOL liveResize;
	BOOL findShiftDragDirection;
	BOOL shiftDragDirectionX;
	
	NSPoint lastDragLocation;
	NSPoint	selectionRectOrigin;
	NSRect selRect;
	NSMutableArray *childViews;
	
	NSMutableArray * selection;
	NSMutableDictionary * dict;
	
	NSNumber * yAxisHeadRoom;
	QuinceDocument * document;
	
	
	//TEST
	
	LayerController * layerController;
	QuinceObjectController * contentController;
}

@property (assign) LayerController * layerController;
@property (assign) QuinceObjectController * contentController;

-(id)valueForKey:(NSString *)key;
-(void)setValue:(id)value forKey:(NSString *)key;
 
-(id)initWithFrame:(NSRect)frame;	
-(void)drawRect:(NSRect)rect;
//-(void)computeVolumeGuides;
//-(void)drawVolumeGuides;
-(void)drawSelRect;

-(void)mouseDown:(NSEvent *)event;
-(void)mouseDragged:(NSEvent *)event;
-(void)mouseUp:(NSEvent *)event;	

-(IBAction)moveUp:(id)sender;			// default: nothing
-(IBAction)moveDown:(id)sender;			// default: nothing
-(IBAction)moveLeft:(id)sender;			// default: nothing
-(IBAction)moveRight:(id)sender;		// default: nothing
-(IBAction)insertNewline:(id)sender;	// default: nothing
-(void) insertText:(NSString *)string;
-(IBAction)deleteBackward:(id)sender;
-(IBAction)insertTab:(id)sender;
-(void)doubleClickInEmptySpace:(NSPoint)location;
-(void)createObjectWhilePlaying;

-(NSString *)parameterOnX;				// default: time
-(NSString *)parameterOnY;				// default: volume
-(BOOL)allowsVerticalDrag;				// default: YES
-(BOOL)allowsHorizontalDrag;			// default: YES
-(BOOL)showGuides;						// default: YES
-(BOOL)allowsNewSubObjectsToRepresentAudioFiles;//default:NO
-(ChildView *)childViewForPoint:(NSPoint)point;
-(void)moveSelectionByX:(float)x andY:(float)y;

NSRect RectFromPoints(NSPoint point1, NSPoint point2);

-(NSColor *)backgroundColor;

-(NSArray *)types;						// default: QuinceObject
-(NSString *)defaultChildViewClassName;		// default: 
-(NSString *)defaultObjectClassName;// default: QuinceObject

-(NSPoint)convertPoint:(NSPoint)clickLocation toChildView:(ChildView*)childView;	
-(void)prepareToDisplayObjectWithController:(QuinceObjectController *)mc;
-(void)clear;
-(ChildView *)createChildViewForQuinceObjectController:(QuinceObjectController *)mc;
-(ChildView *)childViewWithController:(QuinceObjectController *)mc;
-(void)createViewsForQuinceObjectController:(QuinceObjectController *)mc;
-(NSArray *) childViewsInRect:(NSRect) rect;
-(NSMutableDictionary *)dictionary;
-(void)selectChildView:(ChildView *)childView;
-(void)deselectChild:(ChildView* )child;
-(void)deselectAllChildViews;
-(void)selectChildViews:(NSArray *)someChildViews;
-(void)selectAllChildViews;
-(NSMutableArray *)childViews;
-(void)resizeSelectedChildViewsByX:(float) x	andY:(float)y;
-(NSRect) unionRectForSelection;
-(BOOL)allowsHorizontalResize;			//default : YES
-(BOOL)allowsVerticalResize;			//default : NO
-(BOOL)allowsPlayback;					//default : YES
-(void)duplicateSelection;
-(void)foldSelection;
-(ChildView *) createChildViewForFoldedController:(QuinceObjectController*)foldedController andBeginAnimationForChildViews:(NSArray *)foldedChildViews;
-(void)unfoldSelection;
-(void)recolorChildren;
-(void)toggleMuteSelection;
-(NSArray *)selection;
-(NSRect)unionRectForArrayOfChildViews:(NSArray *)views;
-(NSArray *) createChildViewsForUnfoldedControllers:(NSArray *)unfoldedSubControllers andBeginAnimationForChildView:(ChildView *) child;
-(void)removeChildViews:(NSArray *)obsoleteChildViews;
-(void)removeChildViewForQuinceObjectController:(QuinceObjectController *)mc;
-(void)setDocument :(QuinceDocument *)doc;
-(void)sortChildViewsLeft2Right;
-(void)scaleByX:(float)diffX andY:(float)diffY;
-(void)updateViewsForCurrentSize; // override this to provide different display resolutions depending on current zoom
-(void)updateDict;
-(void)setPixelsPerUnitX:(NSNumber *)newPpx;
-(void)setVolumeRange:(NSNumber *)volumeRange;
-(NSNumber *)convertTimeToX:(NSNumber *)time;
-(BOOL)typeCheckModel:(QuinceObject *)model;
-(void)presentAlertWithText:(NSString *)message;

-(NSString *)keyForLocationOnXAxis;				// default: start
-(NSString *)keyForLocationOnYAxis;				// default: volume
-(NSString *)keyForSizeOnXAxis;					// default: duration
-(NSString *)keyForSizeOnYAxis;					// default: nil

-(NSNumber *)convertXToTime:(NSNumber *)x;
-(NSNumber *)convertTimeToX:(NSNumber *)time;
-(NSNumber *)convertYToVolume:(NSNumber *)y;
-(NSNumber *)convertVolumeToY:(NSNumber *)dB;
-(NSNumber *)convertVolumeToYDelta:(NSNumber *)dB;

-(NSNumber *)parameterValueForX:(NSNumber *)x;
-(NSNumber *)parameterValueForY:(NSNumber *)y;
-(NSNumber *)xForParameterValue:(NSNumber *)p;
-(NSNumber *)yForParameterValue:(NSNumber *)p;
-(NSNumber *)xDeltaForParameterValue:(NSNumber *)p;
-(NSNumber *)yDeltaForParameterValue:(NSNumber *)p;
float maxabs_float(float x);

-(void)reload;
@end
