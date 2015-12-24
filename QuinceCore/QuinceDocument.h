//
//  QuinceDocument.h
//  quince
//
//  Created by max on 2/15/10.
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

#import <QuinceApi/ContainerView.h>
#import <QuinceApi/AudioFile.h>
#import <QuinceApi/Function.h>
#import <QuinceApi/QuinceObjectController.h>
#import "LayerController.h"
#import "MainController.h"
//#import <QuinceApi/FunctionLoader.h>
#import <QuinceApi/Player.h>
#import <QuinceApi/FunctionGraph.h>
#import <QuinceApi/QuinceObject.h>
#import "FunctionShortCutController.h"

@class MainController, FunctionLoader;



@interface QuinceDocument : NSDocument{

	// 
	NSAutoreleasePool * pool;
	NSUndoManager * undoManager;
	// model objects
	NSMutableArray * objectPool;
	NSMutableArray * objectNodes;
	NSMutableDictionary * dictionary;
	
	// bundles
	NSMutableArray * containerViewClassNames;
	NSMutableArray * containerViewClasses;
	NSMutableArray * functionClassNames;
	NSMutableArray * functionClasses;
	NSMutableArray * childViewClassNames;
	NSMutableArray * childViewClasses;
	NSMutableArray * playerClasses;

	// temp storage 
	NSDictionary * mainControllerDictionary;
	NSArray * tempObjectArray;
	NSDictionary * tempPlayerDict;
    NSDictionary * tempFunctionShortCuts;
    NSMutableSet * mediaFileRegister;
    
	// InterfaceBuilder connections
	
	IBOutlet NSWindow * poolWindow;
	IBOutlet NSWindow * inspectorWindow;
    IBOutlet NSWindow * window;
	IBOutlet NSButton * newObjectWithAudioFileButton;
	IBOutlet NSOutlineView * outlineView;
	IBOutlet NSTableView * functionPoolTable;
	IBOutlet NSScrollView * scrollView;
	IBOutlet NSTextField * statusField;
	IBOutlet NSPopUpButton * playerMenu;
	IBOutlet NSTextField * progressLabel;
	IBOutlet NSProgressIndicator * progressBar;
	IBOutlet NSTextField * timeTextField;
	
	IBOutlet MainController * mainController;
	IBOutlet NSTreeController * objectPoolTreeController;
	IBOutlet NSDictionaryController * objectInspectorController;
	IBOutlet NSTextField * objectInspectorNewParameterTextField;
	IBOutlet NSArrayController * functionPoolController;
	NSMutableArray * functionPool;
	IBOutlet FunctionLoader * functionLoader;

	IBOutlet NSArrayController * functionComposerFunctionPoolController;
	IBOutlet NSPopUpButton * sourceFunctionMenu;
	IBOutlet NSPopUpButton * targetFunctionMenu;
	IBOutlet NSPopUpButton * purposeFunctionMenu;
	IBOutlet NSTextField * functionComposerNameField;
	IBOutlet NSPanel * functionComposerWindow;
	
	
	IBOutlet NSImageView * imageView;
	
	IBOutlet NSButton * playerSettingsButton;
    
    IBOutlet FunctionShortCutController * functionShortCutController;
   
	NSMenu* functionMenu;
	NSMenu* selectionMenu;
	NSMenu* mixDownMenu;
    
	Player * player;
	double cursorTime;
}

-(void)viewSearchDone:(NSMutableArray*)bundleInstanceList;
-(void)functionSearchDone:(NSMutableArray *)bundleInstanceList;
-(void)addFunctionToPool:(Function *)fun;
-(void)childViewSearchDone:(NSMutableArray *)functionClassList;
-(void)playerSearchDone:(NSMutableArray *)playerClassList;
-(void)startSearch:(id)object;
-(void)searchBundles:(NSString *)identifier;
-(void)searchFunctionGraphs;

-(NSMutableArray *)containerViewClassNames;
-(NSScrollView *)mainScrollView;
-(NSArray *)objectInspectorExcludedKeys;
-(NSDictionaryController *)objectInspectorController;
-(BOOL)isPlaying;
-(NSNumber *)playbackObjectCreationLatency;
	
-(IBAction)newObject:(id)sender;
-(IBAction)newObjectForSelectedAudioFile:(id)sender;
-(IBAction)newAudioFile:(id)sender;
-(IBAction)newDataFile:(id)sender;
-(IBAction)duplicateSelectedObjects:(id)sender;
-(void)addObjectToObjectPool:(QuinceObject *)quince;
-(void)removeObjectsWithControllers:(NSMutableArray *)controllers forGood:(BOOL)b;
-(void)removeObject:(QuinceObject *)quince;
-(IBAction)newStrip:(id)sender;
-(IBAction)removeStrip:(id)sender;
-(IBAction)wakeFunctionLoader:(id)sender;
-(IBAction)changePlayer:(id)sender;
-(IBAction)showPlayerSettings:(id)sender;
-(IBAction)newSubObject:(id)sender;

-(BOOL) typeCheckModel:(QuinceObject *)model withView:(ContainerView *)view;
-(void) displayProgress:(BOOL) display;
-(void) setProgressTask:(NSString *) task;
-(void) setIndeterminateProgressTask:(NSString *) task;
-(void) setProgress:(float)progress;
-(void) presentAlertWithText:(NSString *)message;
-(void) setCursorTime:(NSNumber *)time;
-(void)userSetCursorTime:(NSNumber *)time;
-(void)setPlaybackStartTime:(NSNumber *)time;
-(NSNumber *)cursorTime;
-(void)displayTime;

-(IBAction) removeSelectedObjectsFromPool:(id)sender;
-(IBAction) foldSelectedObjectsInPool:(id)sender;
-(IBAction) togglePool:(id)sender;
-(IBAction) toggleInspector:(id)sender;
-(IBAction) showInspector:(id)sender;
-(IBAction) inspectorAddParameter:(id)sender;
-(IBAction) toggleFunctionComposer:(id)sender;
-(IBAction) objectPoolSelectionChanged:(id)sender;
-(IBAction) functionPoolSelectionChanged:(id)sender;
-(IBAction) clearCompatibilities:(id)sender;
-(IBAction) createFunctionGraph:(id)sender;	
-(IBAction) functionComposerTargetFunctionChanged:(id)sender;
-(IBAction) splitAtCursorTime:(id)sender;
-(IBAction) importAudioFile:(id)sender;
-(IBAction) createEnvelopeForNewAudioFile:(id)sender;
-(IBAction) mixDownWithMenuItem:(id)sender;
-(IBAction) windowMenuAction:(id)sender;
-(IBAction) invertSelection:(id)sender;
-(IBAction)toggleShowPositionGuides:(id)sender;
-(IBAction)showFunctionShortCutSettingsWindow:(id)sender;
-(IBAction)cut:(id)sender;
-(IBAction)copy:(id)sender;
-(IBAction)paste:(id)sender;



-(QuinceObjectController *)getSingleSelectedObjectController;
-(NSMutableArray *)getSelectedObjectControllers;
-(Function *)getSingleSelectedFunction;

-(QuinceObjectController *)controllerForNewObjectOfClassNamed:(NSString *)name inPool:(BOOL)addToPool;
-(QuinceObjectController *)controllerForCopyOfQuinceObjectController:(QuinceObjectController *)mc inPool:(BOOL)addToPool;
-(QuinceObject *)newObjectOfClassNamed:(NSString *)className;
-(QuinceObject *)newObjectOfClassNamed:(NSString *)className inPool:(BOOL)addToPool;
-(QuinceObject *)newObjectForSelectedAudioFileOfClassNamed:(NSString *)className inPool:(BOOL)addToPool;
-(void)linkObject:(QuinceObject *)quince toAudioFile:(AudioFile *)audio;
-(AudioFile *)getCurrentlySelectedAudioFile;
-(QuinceObjectController *) controllerForObjectWithID:(NSString *)ID;
-(QuinceObject *)objectWithValue:(id)value forKey:(NSString *)key;
-(QuinceObject *)mediaFileNamed:(NSString *)mfn;
-(NSMutableArray *)playbackObjectList;
-(NSMutableArray *)removeDuplicatesInArrayOfQuinceObjectControllers:(NSMutableArray *)controllers;

-(void)updateFunctionCompatibilityForQuinceObjectController:(QuinceObjectController *)qc;
-(BOOL)isFunction:(Function *)fun compatibleWithType:(NSString *)type;

-(FunctionGraph *)composeFunctionGraphWithSourceName:(NSString *)sourceName targetName:(NSString *)targetName purpose:(NSString *)purpose name:(NSString *)name;
-(void)saveGraph:(FunctionGraph *)graph;

-(NSNumber *)durationOfLongestObjectInPool;
-(AudioFile *)openNewAudioFile;
-(DataFile *)openNewDataFile;

-(ChildView *)newChildViewOfClassNamed:(NSString *)className;
-(id)valueForKeyPath:(NSString *)keyPath;
-(id)valueForKey:(NSString *)key;
-(void)setValue:(id)aValue forKey:(NSString *)aKey;
-(IBAction)addLayer:(id)sender;
-(Function *)functionNamed:(NSString *)name;
-(IBAction)performFunctionWithMenuItem:(id)sender;
-(void)performFunctionOnCurrentSelectionWithFunctionName:(NSString *)f;
-(IBAction)performFunctionOnCurrentSelectionWithMenuItem:(id)sender;
//-(void)replaceControllers:(NSArray *)a withControllers:(NSArray *)b inSuperController:(QuinceObjectController *)superController inView:(ContainerView*)view forFunctionNamed:(NSString*)name;
-(void)performFunctionNamed:(NSString *)functionName onObject:(QuinceObject *)target;
-(void)performFunction:(Function *)function withValuesOfObject:(QuinceObject *)target;

-(void)play;
-(IBAction)togglePlayback:(id)sender;
-(void)updateObjectInspector;
-(IBAction)test:(id)sender;
-(void)interpretKeyPressedInContainerView:(NSString *)s;
-(BOOL)areTheseControllersSiblings:(NSArray *)controllers;

//-(IBAction)toggleFullScreen:(id)sender;
@end




