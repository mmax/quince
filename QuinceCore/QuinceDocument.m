//
//  QuinceDocument.m
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

#import <QuinceApi/QuinceDocument.h>

#import <QuinceApi/FunctionLoader.h>


NSString* const kContainerViewBundlePrefixIDStr = @"QuinceContainerViewBundle";
NSString* const kChildViewBundlePrefixIDStr = @"QuinceChildViewBundle";
NSString* const kFunctionBundlePrefixIDStr = @"QuinceFunctionBundle";
NSString* const kPlayerBundlePrefixIDStr = @"QuincePlayerBundle";


@implementation QuinceDocument

#pragma mark document-specific

- (id)init {
	
    self = [super init];
    if (self) {
		//pool = [[NSAutoreleasePool alloc]init];
		objectPool = [[NSMutableArray alloc]init];
		containerViewClassNames = [[NSMutableArray alloc]init];
		functionClassNames = [[NSMutableArray alloc]init];
		objectNodes = [[NSMutableArray alloc]init];
		[scrollView setDocumentView:[[[NSView alloc]initWithFrame:[scrollView bounds]]autorelease]];
		mainControllerDictionary = nil;
		[objectPoolTreeController setChildrenKeyPath:@"subObjects"];
		dictionary = [[NSMutableDictionary alloc]init];
		[dictionary setValue:nil forKey:@"selectedObject"];
		functionPool = [[NSMutableArray alloc]init];
		[self setCursorTime:[NSNumber numberWithInt:0]];
		undoManager = [self undoManager];//convinience...
		[self setValue:[NSNumber numberWithInt:0] forKey:@"playbackStartTime"];

		[self setValue:[NSNumber numberWithBool:YES] forKey:@"playbackStopped"];
		[self setValue:[NSNumber numberWithBool:NO] forKey:@"playbackStarted"];
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"showPositionGuides"];
    }
    return self;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)dealloc{
	
	[objectPool release];
	[containerViewClassNames release];
	[functionClassNames release];
	[objectNodes release];
	
	[functionPool release];
	[dictionary release];
	[super dealloc];
	
}


/////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo{
	
	[[NSNotificationCenter defaultCenter]removeObserver:mainController];
	[super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo ];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSString *)windowNibName{ 
    return @"QuinceDocument";
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)windowControllerDidLoadNib:(NSWindowController *) aController{

    [super windowControllerDidLoadNib:aController];
	
	
	NSApplication * app = [NSApplication sharedApplication];
	NSMenu * main = [app mainMenu];
	NSMenuItem * functionItem = [main itemWithTitle:@"Functions"];
	NSMenuItem * selectionItem = [main itemWithTitle:@"Selection"];
	NSMenuItem * playerItem = [main itemWithTitle:@"Player"];
	NSMenu * playerSubMenu = [playerItem submenu];
	NSMenuItem * mixDownMenuItem = [playerSubMenu itemWithTitle:@"MixDown"];
	mixDownMenu = [mixDownMenuItem submenu];
    
	functionMenu = [functionItem submenu];
	selectionMenu = [selectionItem submenu];
    NSString * task = @"loading objects...";
	//[functionMenu removeAllItems];
	
	NSArray * funItems = [functionMenu itemArray];
	for(NSMenuItem * item in funItems)
		[functionMenu removeItem:item];
	
	//[selectionMenu removeAllItems];	
	NSArray * selItems = [selectionMenu itemArray];
	for(NSMenuItem * item in selItems)
		[selectionMenu removeItem:item];
	
	NSArray * mixDownItems = [mixDownMenu itemArray];
	for(NSMenuItem * item in mixDownItems)
		[mixDownMenu removeItem:item];

	
	[self startSearch:nil];
    
    [self setIndeterminateProgressTask:@"loading objects..."];
    [self displayProgress:YES];
	[objectPoolTreeController bind:@"contentArray" toObject:self withKeyPath:@"objectNodes" options:nil];
	//[functionPoolController bind:@"contentArray" toObject:self withKeyPath:@"functionPool" options:nil];
	if(!functionComposerFunctionPoolController)NSLog(@"doc: windowControllerDidLoadNib: no functionComposerFunctionPoolController bad bad bad bad bad bad bad!");
	[functionComposerFunctionPoolController bind:@"contentArray" toObject:self withKeyPath:@"functionPool" options:nil];
	
	[mainController getReady];

	NSMutableSet * specialNeeds = [[NSMutableSet alloc]init];
	if([tempObjectArray count]){// if we read in a file, we have an array with objects to load now
		
		for(NSDictionary * objectDict in tempObjectArray){
			//NSLog(@"Document: objectDict: %@", objectDict);
            task = [NSString stringWithFormat:@"loading objects... %@", [objectDict valueForKey:@"name"]];
            [self setIndeterminateProgressTask:task];
            
			if (![[objectDict valueForKey:@"nonStandardReadIn"]boolValue]){
				QuinceObjectController * mc = [self controllerForNewObjectOfClassNamed:[objectDict valueForKey:@"type"] inPool:NO];
				//NSLog(@"doc subobjects: %d", [[objectDict valueForKey:@"subObjects"]count]);
				[mc initContentWithXMLDictionary:objectDict];
				[self addObjectToObjectPool:[mc content]];
			}
			else {
				[specialNeeds addObject:objectDict];
			}

		}
	}
	
	for(NSDictionary * objectDict in specialNeeds){ 
			// same initialization as the others, but we have to make sure that all other objects are already there...
		QuinceObjectController * mc = [self controllerForNewObjectOfClassNamed:[objectDict valueForKey:@"type"] inPool:NO];
		[mc initContentWithXMLDictionary:objectDict];
		[self addObjectToObjectPool:[mc content]];
	}
	
	// falls objects special needs haben müssten wir eigentlich warten, 
	// bis alle objects mit dem ausführen von functions fertig sind, 
	// erst dann dürfen die views bestückt werden... 
	// für den fall dass eine function in separatem thread performt...??
	
	if(mainControllerDictionary)// if we read in a file, we have a dictionary with views for the main controller to create
		[mainController createViewsFromDictionary:mainControllerDictionary];
	else{
//		StripController * strip = [mainController createStrip];
//		[strip addLayer];

        [self newStrip:nil];
    }
	
	if(tempPlayerDict){

		[playerMenu selectItemWithTitle:[tempPlayerDict valueForKey:@"name"]];
		[self changePlayer:nil];
		[player setSettings:[tempPlayerDict valueForKey:@"settings"]];
	}

    [functionShortCutController setConnectionsWithDict:tempFunctionShortCuts];
    
 	[[NSDocumentController sharedDocumentController]setAutosavingDelay:300];
	
	[functionPoolTable setTarget:functionLoader];
	[functionPoolTable setDoubleAction:@selector(awake)];
	[specialNeeds release];
	
    [self displayProgress:NO];
	//[[aController window] makeFirstResponder:[[[mainController stripControllers] objectAtIndex:0]activeView]];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
// dirty
//-(BOOL)isDocumentEdited{return YES;}

/////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError{
    [self setIndeterminateProgressTask:@"writing data..."];
    [self displayProgress:YES];

	NSString * error;
	NSDictionary * views = [mainController xmlDictionary];//[[NSMutableDictionary alloc]init];
	NSMutableDictionary * session = [[NSMutableDictionary alloc]init];
	NSMutableArray * objects = [[NSMutableArray alloc]init];

	for(QuinceObjectController * mc in objectPool)
		[objects addObject:[[mc content] xmlDictionary]];
	
    [session setValue:[functionShortCutController dictionary] forKey:@"functionShortCuts"];
	[session setValue:[player xmlDictionary] forKey:@"player"];
	[session setValue:views forKey:@"views"];
	[session setValue:objects forKey:@"objects"];
	/* NSLog(@"writing file:"); 
		NSLog(@"session: %@", session);
	 */	
	NSData * data = [NSPropertyListSerialization dataFromPropertyList:session
															   format:NSPropertyListXMLFormat_v1_0
												errorDescription:&error];	 	 
	
	[session release];
	[objects release];
	[self displayProgress:NO];
    
	if(!data) {
		NSLog(@"%@", error);
		return nil;
	}
	return data;
	
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError{
  
	NSString *error;
	NSPropertyListFormat format;
	NSDictionary * session = [NSPropertyListSerialization propertyListFromData:data
															  mutabilityOption:NSPropertyListImmutable
																		format:&format
															  errorDescription:&error];
	
	tempObjectArray = [session valueForKey:@"objects"];
	mainControllerDictionary = [session valueForKey:@"views"];
	tempPlayerDict = [session valueForKey:@"player"];
    tempFunctionShortCuts = [session valueForKey:@"functionShortCuts"];
	
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)validateUserInterfaceItem:(id)anItem{
	
	return YES;
	
	SEL theAction = [anItem action];
	
    if (theAction == @selector(copy:)){
        if ( 1 ){					///* there is a current selection and it is copyable */
            return YES;
        }
        return NO;
    } 
	else if (theAction == @selector(paste:)){
        if ( 1){/* there is a something on the pasteboard we can use and
				 the user interface is in a configuration in which it makes sense to paste */ 
            return YES;
        }
        return NO;
    } 
	else{
		/* check for other relevant actions ... */
	}
	// subclass of NSDocument, so invoke super's implementation
	return [super validateUserInterfaceItem:anItem];
	
}


/////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark load bundles

-(void)startSearch:(id)object{
	
	[self setIndeterminateProgressTask:@"searching for ContainerView Bundles..."];
	[self displayProgress:YES];
	
	[self searchBundles:kContainerViewBundlePrefixIDStr];

	[self setIndeterminateProgressTask:@"searching for ChildView Bundles..."];
	[self searchBundles:kChildViewBundlePrefixIDStr];
	
	[self setIndeterminateProgressTask:@"searching for Function Bundles..."];
	[self searchBundles:kFunctionBundlePrefixIDStr];
	
	[self setIndeterminateProgressTask:@"searching for Player Bundles..."];
	[self searchBundles:kPlayerBundlePrefixIDStr];

	[self setIndeterminateProgressTask:@"searching for Function Graphs..."];
	[self searchFunctionGraphs];
	
	[self displayProgress:NO];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)searchBundles:(NSString *)identifier{ // based on the BundleLoader example project

	NSMutableArray* bundlePaths = [[NSMutableArray alloc]init];
	NSString* currPath;
	NSMutableArray*	bundleSearchPaths = [[NSMutableArray alloc]init];
	NSArray* librarySearchPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSSystemDomainMask, YES);

    NSEnumerator* searchPathEnum = [librarySearchPaths objectEnumerator];
    while ((currPath = [searchPathEnum nextObject]))
		[bundleSearchPaths addObject: [NSString stringWithFormat:@"%@/quince", currPath]];
	
	//NSLog(@"%@", bundleSearchPaths);
	searchPathEnum = [bundleSearchPaths objectEnumerator];
	while ((currPath = [searchPathEnum nextObject])){
        NSDirectoryEnumerator *bundleEnum;
        NSString *currBundlePath;
        bundleEnum = [[NSFileManager defaultManager] enumeratorAtPath:currPath];
        if (bundleEnum){
            while ((currBundlePath = [bundleEnum nextObject])){
                if ([[currBundlePath pathExtension] isEqualToString:@"bundle"])// we found a bundle, add it to the list
					[bundlePaths addObject:[currPath stringByAppendingPathComponent:currBundlePath]];
            }
        }
    }
	//NSLog(@"MyDocument:searchBundles:bundles found, now filtering");
	// now that we have all bundle paths, start finding the ones we really want to load -
	NSRange searchRange = NSMakeRange(0, [identifier length]);
	
	NSEnumerator* pathEnum = [bundlePaths objectEnumerator];
	NSMutableArray * classList = [[NSMutableArray alloc]init];
	
    while ((currPath = [pathEnum nextObject])) {
        
		NSBundle* currBundle = [NSBundle bundleWithPath:currPath];

        if (currBundle){
			NSString* bundleIDStr = [currBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
			//NSLog(@"got bundle, now testing for type...");
			// check the bundle ID to see if it starts with our prefix string
			// we want to only load the bundles we care about:
			//
			if ([bundleIDStr compare:identifier options:NSLiteralSearch range:searchRange] == NSOrderedSame){
				// note: principleClass method actually loads the bundle for us, or we can call [currBundle load] directly.
				//NSLog(@"bundle is of type %@", identifier);
				Class currPrincipalClass = [currBundle principalClass];
				if (currPrincipalClass){
					//NSLog(@"got principal class, now adding to array...");
					[classList addObject:currPrincipalClass];
				}
			}
        }
    }
	//NSLog(@"done, now returning to main thread...");
	// we are done, update the UI on the main thread
	
	[classList autorelease];
	
	if([identifier isEqualToString:kContainerViewBundlePrefixIDStr]){
		[self performSelectorOnMainThread:@selector(viewSearchDone:)
						   withObject:classList			// pass back our list 
						waitUntilDone:YES];				// don't block
	}
	else if([identifier isEqualToString:kFunctionBundlePrefixIDStr]){
			[self performSelectorOnMainThread:@selector(functionSearchDone:)
							  withObject:classList			// pass back our list 
						   waitUntilDone:YES];				// don't block
	}
	else if([identifier isEqualToString:kChildViewBundlePrefixIDStr]){
		[self performSelectorOnMainThread:@selector(childViewSearchDone:)
							   withObject:classList		// pass back our list 
							waitUntilDone:YES];				// don't block
	}
	else if([identifier isEqualToString:kPlayerBundlePrefixIDStr]){
		[self performSelectorOnMainThread:@selector(playerSearchDone:)
							   withObject:classList		// pass back our list 
							waitUntilDone:YES];				// don't block
	}	
	[bundlePaths release];
	[bundleSearchPaths release];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)searchFunctionGraphs{
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSSystemDomainMask, YES);
//	NSString * path = [NSString stringWithFormat:@"%@/Mint/FunctionGraphs/%@.plist", [paths lastObject], [graph valueForKey:@"name"]];
	NSMutableArray * plistPaths = [[NSMutableArray alloc]init];

	for (NSString * p in paths){
		NSString * path = [NSString stringWithFormat:@"%@/quince/FunctionGraphs", p];
        NSDirectoryEnumerator *contentEnum;
		NSString * curPath;
        contentEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
		//NSLog(@"%@", path);
		if (contentEnum){
            while ((curPath = [contentEnum nextObject])){
				//NSLog(@"%@", curPath);
                if ([[curPath pathExtension] isEqualToString:@"plist"])
					[plistPaths addObject:[path stringByAppendingPathComponent:curPath]];
				//NSLog(@"%@", plistPaths);
            }
        }
	}
	
	
	for(NSString * path in plistPaths){
	
		NSDictionary * dict = [[NSDictionary alloc ]initWithContentsOfFile:path];
		NSString * targetName = [dict valueForKey:@"targetName"];
		NSString * sourceName = [dict valueForKey:@"sourceName"];
		NSString * purpose = [dict valueForKey:@"targetPurpose"];		
		NSString * name = [[[path lastPathComponent]componentsSeparatedByString:@"."]objectAtIndex:0];
		//NSLog(@"found graph: source: %@ target: %@ purpose: %@ name:%@", sourceName, targetName, purpose, name);
		[self composeFunctionGraphWithSourceName:sourceName targetName:targetName purpose:purpose name:name];
		[dict release];
	}
	[plistPaths release];
	/* NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
		NSArray * descriptors = [NSArray arrayWithObject:sd];
		[functionPool sortUsingDescriptors:descriptors]; */
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

// -------------------------------------------------------------------------------
//	searchDone:
// -------------------------------------------------------------------------------
- (void)viewSearchDone:(NSMutableArray*)viewClassList{

	NSEnumerator * e = [viewClassList objectEnumerator];
	containerViewClasses = viewClassList;
	Class a;
	while ((a = [e nextObject]))
		[containerViewClassNames addObject:[a className]];
	[mainController setContainerViewClasses:viewClassList];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)functionSearchDone:(NSMutableArray *)functionClassList{
    [self setIndeterminateProgressTask:@"adding Functions"];
	NSEnumerator * e = [functionClassList objectEnumerator];
	functionClasses = functionClassList;
	Function * fun;
	Class a;
	while ((a = [e nextObject])){
		[functionClassNames addObject:[a className]];
		fun = [[a alloc]init];
		[self addFunctionToPool:fun];
		/* [fun setDocument:self];
				[functionPool addObject:fun];	
				//[fun release];

				NSMenuItem * functionItem = [[[NSMenuItem alloc]init]autorelease];
				[functionItem setTitle:[a className]];
				[functionItem setTarget:self];
				[functionItem setAction:@selector(performFunctionWithMenuItem:)];
				[functionMenu addItem:functionItem];
				
				if([[fun inputDescriptors]count] == 1 && [fun needsInput] && [[[[fun inputDescriptors]lastObject]valueForKey:@"type"]isEqualToString:@"QuinceObject"]){
					NSMenuItem * selectionItem = [[NSMenuItem alloc]init];
					[selectionItem setTitle:[a className]];
					[selectionItem setTarget:self];
					[selectionItem setAction:@selector(performFunctionOnCurrentSelectionWithMenuItem:)];
					[selectionMenu addItem:selectionItem];
					[selectionItem release];
				}
		 */	}
    
    NSMenuItem * separator = [NSMenuItem separatorItem];
    [selectionMenu addItem:separator];
    NSMenuItem * separator2 = [NSMenuItem separatorItem];
    [functionMenu addItem:separator2];
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)addFunctionToPool:(Function *)fun{
    
	[fun setDocument:self];
	[functionPoolController addObject:fun];	
//	NSLog(@"addFunctionToPool:%@", [fun valueForKey:@"name"]);
	NSMenuItem * functionItem = [[[NSMenuItem alloc]init]autorelease];
	[functionItem setTitle:[fun valueForKey:@"name"]];
	[functionItem setTarget:self];
	[functionItem setAction:@selector(performFunctionWithMenuItem:)];
	[functionMenu addItem:functionItem];
	
	if([[fun inputDescriptors]count] == 1 && [fun needsInput] && [[[[fun inputDescriptors]lastObject]valueForKey:@"type"]isEqualToString:@"QuinceObject"]){
		NSMenuItem * selectionItem = [[NSMenuItem alloc]init];
		[selectionItem setTitle:[fun valueForKey:@"name"]];
		[selectionItem setTarget:self];
		[selectionItem setAction:@selector(performFunctionOnCurrentSelectionWithMenuItem:)];
		[selectionMenu addItem:selectionItem];
		[selectionItem release];
        
        [functionShortCutController addFunctionWithName:[fun valueForKey:@"name"]];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)childViewSearchDone:(NSMutableArray *)childViewClassList{
    [self setIndeterminateProgressTask:@"adding ChildViews"];
	NSEnumerator * e = [childViewClassList objectEnumerator];
	childViewClasses = childViewClassList;
	Class a;
	while ((a = [e nextObject]))
		[childViewClassNames addObject:[a className]];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////	

-(void)playerSearchDone:(NSMutableArray *)playerClassList{
    [self setIndeterminateProgressTask:@"adding Players"];
	playerClasses = playerClassList;
	[playerMenu removeAllItems];
	for(Class a in playerClassList)
		[playerMenu addItemWithTitle:[a className]];
	


	NSMenuItem * item = [[[NSMenuItem alloc]init]autorelease];
	[item setTitle:@"Current"];
	[item setTarget:self];
	[item setAction:@selector(mixDownWithMenuItem:)];
	[mixDownMenu addItem:item];
//	[item release];
	
	for(Class a in playerClassList){
		NSMenuItem * item = [[[NSMenuItem alloc]init]autorelease];
		[item setTitle:[a className]];
		[item setTarget:self];
		[item setAction:@selector(mixDownWithMenuItem:)];
		[mixDownMenu addItem:item];
        [item setEnabled:NO];
//		[item release];
		
	}
    NSApplication * app = [NSApplication sharedApplication];
	NSMenu * main = [app mainMenu];
	NSMenuItem * playerItem = [main itemWithTitle:@"Players"];
	NSMenu * playerSubMenu = [playerItem submenu];
	NSMenuItem * mixDownMenuItem = [playerSubMenu itemWithTitle:@"MixDown"];
    [mixDownMenuItem setEnabled:YES];
    
	[[playerMenu target] performSelector:[playerMenu action]];
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark action messages	

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)newObject:(id)sender{
	QuinceObject * quince = [self newObjectOfClassNamed:@"QuinceObject" inPool:YES];
	[undoManager registerUndoWithTarget:self selector:@selector(removeObject:) object:quince];
	//[[undoManager prepareWithInvocationTarget:self] removeObject:quince];
	[undoManager setActionName:@"new Object"];
	[quince release];// turn the controller in the pool into the only owner of ‘quince’
}
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)newObjectForSelectedAudioFile:(id)sender{


	[self newObjectForSelectedAudioFileOfClassNamed:@"QuinceObject" inPool:YES];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)newAudioFile:(id)sender{
	
	[self openNewAudioFile];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)newDataFile:(id)sender{
	[self openNewDataFile];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)duplicateSelectedObjects:(id)sender{
    
	NSArray * selection = [self getSelectedObjectControllers];
	
	for(QuinceObjectController * mc in selection){
		[self controllerForCopyOfQuinceObjectController:mc inPool:YES];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)newStrip:(id)sender{
	
	if(!mainController){NSLog(@"no mainController!");return;}
	StripController * strip = [mainController createStrip];
	LayerController * lc =  [strip addLayer];
    [lc selectDefaultView];
	/* [undoManager registerUndoWithTarget:mainController selector:@selector(removeStripWithStripController:) object:strip];
		[undoManager setActionName:@"new Strip"]; */
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)removeStrip:(id)sender{
	//[undoManager registerUndoWithTarget:mainController selector:@selector(createViewsFromDictionary:) object:[mainController dictionary]];
	[mainController removeActiveStrip];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction) togglePool:(id)sender{

	/* if([poolWindow isVisible])
		[poolWindow orderOut:nil];
	else */

		[poolWindow makeKeyAndOrderFront:nil];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction) toggleInspector:(id)sender{


	/* if([inspectorWindow isVisible])
		[inspectorWindow orderOut:nil];
	else */
		[inspectorWindow makeKeyAndOrderFront:nil];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction) showInspector:(id)sender{
	[inspectorWindow makeKeyAndOrderFront:nil];
	
}
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction) inspectorAddParameter:(id)sender{
	NSString * parameterName = [objectInspectorNewParameterTextField stringValue];
	QuinceObject * quince = [objectInspectorController content];
	[quince setValue:[NSNumber numberWithInt:0] forKey:parameterName];
	[self updateObjectInspector];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)toggleFunctionComposer:(id)sender{

	/* if([functionComposerWindow isVisible])
		[functionComposerWindow orderOut:nil];
	else */
		[functionComposerWindow makeKeyAndOrderFront:nil];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction)objectPoolSelectionChanged:(id)sender{

    for(QuinceObjectController * c in objectPool)
        [[c content]setIsCompatible:YES recursively:YES];
    // better way would be to set up a flag and to check wether this is actually necessary...
    
	
    
    
    // now validate interface items
	
	int count = [[objectPoolTreeController selectedObjects]count];
	if(count>1 || ![[[self getSingleSelectedObjectController]content]isOfType:@"AudioFile"]){
		[newObjectWithAudioFileButton setEnabled:NO];
	//	[newObjectWithAudioFileMenuItem setEnabled:NO];
	}
	else if(count ==1 && [[[self getSingleSelectedObjectController]content]isOfType:@"AudioFile"]){
		[newObjectWithAudioFileButton setEnabled:YES];
	//	[newObjectWithAudioFileMenuItem setEnabled:YES];
	}
	
	AudioFile * audio = [self getCurrentlySelectedAudioFile];

	NSString * s = @"no reference";

	if(audio){
		s = [NSString stringWithFormat:@"%@", [audio valueForKey:@"name"]];
	}
	
	[statusField setStringValue:s];
	QuinceObjectController * mc = [self getSingleSelectedObjectController];
	[self setValue:mc forKey:@"selectedObject"];
	
    [self updateFunctionCompatibilityForQuinceObjectController:[self getSingleSelectedObjectController]];
	
    

    
	//enabling/disabling pool entries...
	
	/* NSArray * columns = [outlineView tableColumns];
		int row = [outlineView selectedRow];
		for(NSTableColumn * tc in columns){
		
			[[tc dataCellForRow:row]setEnabled:NO];
		}
	 */	
	//NSLog(@"row: %d", row);
}
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)functionPoolSelectionChanged:(id)sender{ // will be called by functionLoader because functionLoader is Target of functionPoolTable!
    
    for(Function * f in functionPool)
        [f setIsCompatible:YES];
    
    Function * f = [self getSingleSelectedFunction];
    
    NSMutableArray * types = [[NSMutableArray alloc]init];
    
    NSArray * desc = [f inputDescriptors];
    
    for(NSDictionary * d in desc)
        [types addObject:[d valueForKey:@"type"]];
    
    for(QuinceObjectController * c in objectPool){
        [[c content]setCompatibilityWithTypes:types recursively:YES];
        
    }
    
}

-(IBAction)clearCompatibilities:(id)sender{

    for(Function * f in functionPool)
        [f setIsCompatible:YES];
    
    for(QuinceObjectController * c in objectPool)
        [[c content]setIsCompatible:YES recursively:YES];
        
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)addLayer:(id)sender{

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)foldSelectedObjectsInPool:(id)sender{

	NSMutableArray * controllers = [self getSelectedObjectControllers];


	QuinceObject * mother;
	BOOL sib = [self areTheseControllersSiblings:controllers];
	if(sib)
		mother = [[[controllers lastObject]content]superObject];
	else
		mother = [self newObjectOfClassNamed:@"QuinceObject" inPool:NO];
	
	//[mother setValue:@"_superTmp" forKey:@"name"];
	/* for(QuinceObjectController * c in controllers){
			[mother addSubObjectWithController:c withUpdate:YES];
		}
		 */
	QuinceObjectController * foldedController = [[mother controller]foldControllers:controllers];
	
	if(!sib){
		for(QuinceObjectController * q in controllers)
			[[[q superController]registeredContainerViews]makeObjectsPerformSelector:@selector(reload)]; 
		// could be done a lot more efficient i guess
		
		
		[self addObjectToObjectPool:[foldedController content]];
		[self removeObjectsWithControllers:controllers forGood:NO];//remove the objects from pool, but keep them in memory!
	//[[mother controller]release];
		[mother release];
	}
	else {
		[[[mother controller]registeredContainerViews]makeObjectsPerformSelector:@selector(reload)];
	}

	
	//NSLog(@"_superTmp should be destroyed now");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)removeSelectedObjectsFromPool:(id)sender{
	NSMutableArray * controllers = [self getSelectedObjectControllers];
	[self removeObjectsWithControllers: controllers forGood:YES];
//	QuinceObjectController * mc = [controllers lastObject];
	//[controllers release];
	//[mc release];
//	NSLog(@"controllers: %@", controllers);
	[self objectPoolSelectionChanged:nil];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)wakeFunctionLoader:(id)sender{
	[functionLoader awake];	
}
	
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)changePlayer:(id)sender{
	//NSLog(@"changePlayer: not implemented yet");
	// nothing to do! new player will be created in MintDocument:play
	NSString * playerName = [playerMenu titleOfSelectedItem];
	player = [[NSClassFromString(playerName) alloc]init];
	[player setDocument:self];
	if ([player window])
		[playerSettingsButton setEnabled:YES];
	else 
		[playerSettingsButton setEnabled:NO];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)functionComposerTargetFunctionChanged:(id)sender{

	NSString * targetName = [targetFunctionMenu titleOfSelectedItem];
	Function * fun = [self functionNamed:targetName];
	[purposeFunctionMenu removeAllItems];
	for(NSDictionary * dict in [fun inputDescriptors])
		[purposeFunctionMenu addItemWithTitle:[dict valueForKey:@"purpose"]];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)createFunctionGraph:(id)sender{

	NSString * sourceName = [sourceFunctionMenu titleOfSelectedItem];
	NSString * targetName = [targetFunctionMenu titleOfSelectedItem];
	NSString * purpose = [purposeFunctionMenu titleOfSelectedItem];
	NSString * name = [functionComposerNameField stringValue];
	
	if([name isEqualToString:@""]){
	
		[self presentAlertWithText:@"Please enter a name for your FunctionGraph!"];
		return;
	}
	
	//NSLog(@"MintDocument: createFunctionGraph:\nsourceName: %@\ntargetName: %@\npurpose: %@\nname: %@\n", sourceName, targetName, purpose, name);
	
	Function * target = [self functionNamed:targetName];
	Function * source = [self functionNamed:sourceName];
	
	if(![target typeCheckPurpose:purpose withType:[source outputType]]){
	
		[self presentAlertWithText:[NSString stringWithFormat:@"incompatible type: ‘%@’ for purpose ‘%@’ of function ‘%@’", [source outputType], purpose, targetName]];
		return;
	}
	[functionComposerWindow orderOut:nil];
	
	FunctionGraph * graph = [self composeFunctionGraphWithSourceName:sourceName targetName:targetName purpose:purpose name:name];
	[self saveGraph:graph];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)splitAtCursorTime:(id)sender{

	[self presentAlertWithText:@"not yet ready to use..."];
	QuinceObject * mom = [[[mainController activeView]contentController]content];
	NSArray * subs = [mom subObjectsAtTime:[self cursorTime]];
	if([subs count]==0)NSLog(@"doc: no objects found to cut...");
	for(QuinceObject * q in subs)
		[q splitAtTime:[self cursorTime] migrateToController:nil];
//	[subs makeObjectsPerformSelector:@selector(splitAtTime:migrateToController:) withObject:[self cursorTime] :nil];
	[[mainController activeView] reload]; 
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)importAudioFile:(id)sender{

	[self newAudioFile:sender];
	[poolWindow makeKeyAndOrderFront:sender];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction) createEnvelopeForNewAudioFile:(id)sender{

	AudioFile * af = [self openNewAudioFile];
	Function * fun = [self functionNamed:@"Audio2Envelope"];
	if(!fun){
		[self presentAlertWithText:@"could not find funtion Audio2Envelope"];
		return;
	}
	[fun reset];
	
	NSMutableArray * de = [fun inputDescriptors];
	[[de lastObject]setValue:af forKey:@"object"];
	[fun performActionWithInputDescriptors:de];
	[poolWindow makeKeyAndOrderFront:sender];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)showPlayerSettings:(id)sender{
	
	
	if(!player)
		[self changePlayer:nil];
	[player showWindow];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)mixDownWithMenuItem:(id)sender{
	NSString * s = [sender title];
	if([s isEqualToString:@"Current"])
		[player mixDown];
	else {
		Player * p = [[NSClassFromString(s) alloc]init];
		[p setDocument:self];
		[p mixDown];
		[p release];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction) windowMenuAction:(id)sender{

    NSString * win = [sender title];
    if([win isEqualToString:@"Project"]){
        [poolWindow close];
        [inspectorWindow close];
        [window makeKeyAndOrderFront:nil];
    }
    else if([win isEqualToString:@"Pool"]){
        [inspectorWindow close];
        [poolWindow makeKeyAndOrderFront:self];
    }
    else if([win isEqualToString:@"Inspector"])
        [inspectorWindow makeKeyAndOrderFront:self];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)invertSelection:(id)sender{

    ContainerView * currentView = [mainController activeView];	// get the currently active view
	NSArray * selectedChildViews = [currentView selection];	
    NSMutableArray * allChildViews = [currentView childViews];    
    NSMutableArray * unselectedChildViews = [[[NSMutableArray alloc]init]autorelease];
        
    for(ChildView * c in allChildViews){
    
        if(![selectedChildViews containsObject:c])
            [unselectedChildViews addObject:c];
    }
    
    [currentView deselectAllChildViews];
    [currentView selectChildViews:unselectedChildViews];
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


-(IBAction)toggleShowPositionGuides:(id)sender{
    
    if([sender state]==NSOnState)
        [sender setState:NSOffState];
    else
        [sender setState:NSOnState];
    
    BOOL b = NO;
    
    if([sender state] == NSOnState)
        b = YES;
    
    [self setValue:[NSNumber numberWithBool:b] forKey:@"showPositionGuides"];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)showFunctionShortCutSettingsWindow:(id)sender{
   
    
    if(!functionShortCutController){
    
        [self presentAlertWithText:@"no editor found!"];
        NSLog(@"doc: showFunctionShortCutSettingsWindow: no editor!");
        return;
    }
    
    [functionShortCutController awake];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark ACCESSORS

-(NSMutableArray *)containerViewClassNames{
	return containerViewClassNames;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSScrollView *)mainScrollView{
	return scrollView;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSArray *)objectInspectorExcludedKeys{

	return [objectInspectorController excludedKeys];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDictionaryController *)objectInspectorController{
    return objectInspectorController;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isPlaying{
	if(player)
		return [player isPlaying];
	return NO;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSNumber *)playbackObjectCreationLatency{
	return [NSNumber numberWithFloat:0.1];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark object management

-(void)addObjectToObjectPool:(QuinceObject *)quince{
	if(!objectPool){
		NSLog(@"trying to add into non existent objectPool!");
		return;
	}
	[quince setDocument:self];
	
	QuinceObjectController * mc = [quince controller];
	
	if(![objectPool containsObject:mc]){
		[objectPool addObject:mc];
		[mc release];// turn the quince's reference to its controller into a weak one
	}
	
	
	[[self mutableArrayValueForKey:@"objectNodes"]addObject:[mc node]];	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)removeObjectsWithControllers:(NSMutableArray *)controllers forGood:(BOOL)b{

	if(!b)		// if we want to keep the controllers alive, turn quinces into owners of their controllers
		[controllers makeObjectsPerformSelector:@selector(retain)];
				// needed for top-level-folding: the controllers should not remain in the pool
				// but we still need them - their contentObjects are becoming subObjects of a new object
	
	for(QuinceObjectController * mc in controllers){
	
		/* for(MintContainerView * view in [mc registeredContainerViews])
					[[view layerController]clear];
				
				[objectPool removeObject:mc];
				[[self mutableArrayValueForKey:@"objectNodes"]removeObject:[mc node]]; */
		
		[self removeObject:[mc content]];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)removeObject:(QuinceObject *)quince{

	QuinceObjectController * mc = [quince controller];
	
//	[undoManager registerUndoWithTarget:self selector:@selector(addObjectToObjectPool:) object:quince];
//	[undoManager setActionName:@"Remove Object"];

	
	for(ContainerView * view in [mc registeredContainerViews])
		[[view layerController]clear];
	
	[objectPool removeObject:mc];
	[[self mutableArrayValueForKey:@"objectNodes"]removeObject:[mc node]];
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSArray *)getObjectsWithTypesInArray:(NSArray *)typeNames{
	
	NSMutableArray * objects = [[NSMutableArray alloc]init];
	for(QuinceObjectController * mc in objectPool){
		if([[mc content] isOneOfTypesInArray:typeNames])
			[objects addObject:[mc content]];
	}
	return [objects autorelease];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(QuinceObjectController *)getSingleSelectedObjectController{
	return [[self getSelectedObjectControllers]lastObject];
}
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSMutableArray *)getSelectedObjectControllers{
	NSArray * nodes = [objectPoolTreeController selectedNodes];
	NSMutableArray * selectedObjectControllers = [[NSMutableArray alloc]init];
	QuinceObject * m;
	for(NSTreeNode * n in nodes){
		m = [[n representedObject]representedObject]; // WHY is it a tree node representing a tree node representing a QuinceObject?!?!?!?!?!
		[selectedObjectControllers addObject:m];
	}
	return [selectedObjectControllers autorelease];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(Function *)getSingleSelectedFunction{
	
	Function * fun =[[functionPoolController selectedObjects]lastObject];//[[NSClassFromString(name) alloc]init];
	return fun;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)typeCheckModel:(QuinceObject *)model withView:(ContainerView *)view{

	BOOL result =  [model isOneOfTypesInArray:[view types]];
	return result;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(QuinceObjectController *)controllerForNewObjectOfClassNamed:(NSString *)name inPool:(BOOL)addToPool{
	QuinceObject * quince = [self newObjectOfClassNamed:name inPool:addToPool];
	QuinceObjectController * mc = [quince controller];
	[quince release]; //the controller is owner of quince, and maybe the pool, too
	return mc;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(QuinceObjectController *)controllerForCopyOfQuinceObjectController:(QuinceObjectController *)mc inPool:(BOOL)addToPool{
	
	QuinceObject * c = [mc content];
	QuinceObject * copy = [c copyWithZone:nil];//copyWithZone makes sure we have a new QuinceObjectController 
	if(addToPool)[self addObjectToObjectPool:copy];
	QuinceObjectController* controller = [copy controller];
	[copy release];
	return controller;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(QuinceObject *)newObjectOfClassNamed:(NSString *)className{
	
	QuinceObject * quince = [[NSClassFromString(className) alloc]init];
	if(!quince){
	
		[self presentAlertWithText:[NSString stringWithFormat:@"Unable to create object of class: %@", className]];
		return nil;
	}
	QuinceObjectController * mc = [[QuinceObjectController alloc]initWithContent:quince];
	[mc setDocument:self];
	[quince setDocument:self];
	[quince setController:mc]; // weak reference!
	return quince; // the method's name starts with new, callers will assume they own the returned object -> no ‘autorelease’
	// so there are two owners of ‘quince’ now: the controller and the caller of this method
	// at this point ‘quince’ is the only owner of it's controller!
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(QuinceObject *)newObjectOfClassNamed:(NSString *)className inPool:(BOOL)addToPool{
	QuinceObject * quince = [self newObjectOfClassNamed:className];
	if(addToPool)[self addObjectToObjectPool:quince];
	return quince;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(QuinceObject *)newObjectForSelectedAudioFileOfClassNamed:(NSString *)className inPool:(BOOL)addToPool{

	AudioFile * audio = [self getCurrentlySelectedAudioFile];

	if(!audio){
		[self presentAlertWithText:@"No Audio File Object Selected"];
		return nil;
	}
	QuinceObject * quince = [self newObjectOfClassNamed:@"QuinceObject" inPool:YES];
	[self linkObject:quince toAudioFile:audio];
	
	[undoManager registerUndoWithTarget:self selector:@selector(removeObject:) object:quince];
	//[[undoManager prepareWithInvocationTarget:self] removeObject:quince];
	[undoManager setActionName:@"New Object for selected AudioFile"];
	
	return quince;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)linkObject:(QuinceObject *)quince toAudioFile:(AudioFile *)audio{

	[quince setValue:[audio valueForKey:@"name"] forKey:@"mediaFileName"];
	[audio registerLinkedObject:quince rename:YES];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(AudioFile *)getCurrentlySelectedAudioFile{
	
	if([[objectPoolTreeController selectedObjects]count] != 1)
		return nil;
	
	AudioFile * audio = [[self getSingleSelectedObjectController]content];
	if([audio isOfType:@"AudioFile"])
		return audio;

	return nil;

}
/////////////////////////////////////////////////////////////////////////////////////////////////////


-(ChildView *)newChildViewOfClassNamed:(NSString *)className{
	
	ChildView * child = [[NSClassFromString(className) alloc]init];
	return child; // the method's name starts with new, callers will assume they own the returned object -> no ‘autorelease’
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(QuinceObjectController *) controllerForObjectWithID:(NSString *)ID{
	return [[self objectWithValue:ID forKey:@"id"]controller];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(QuinceObject *)objectWithValue:(id)value forKey:(NSString *)key{
	QuinceObject *result;
	for(QuinceObjectController * mc in objectPool){
		result = [[mc content] objectWithValue:value forKey:key];
		if(result)
			return result;
	}
	//[self presentAlertWithText:[NSString stringWithFormat:@"could not find quinceObject with %@: %@", key, value]];
	return nil;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSMutableArray *)playbackObjectList{

    [self setIndeterminateProgressTask:@"preparing copies..."];
    [self displayProgress:YES];
    
	NSMutableArray * topLevel = [mainController topLevelPlaybackList]; // an array with arrays for strips with top-level quinceObjectControllers

	NSMutableArray * tl2 = [[NSMutableArray alloc]init];
	for(NSArray * a in topLevel)
		[tl2 addObjectsFromArray:a];

	//NSLog(@"doc: playbackObjectList: topLevel: before remove dup: %@", tl2);		
	topLevel = [self removeDuplicatesInArrayOfQuinceObjectControllers:tl2];
	//NSLog(@"doc: playbackObjectList: topLevel: after remove dup: %@", topLevel);	
	NSMutableArray * flat = [[NSMutableArray alloc]init];

	// hard-set audioFile associations
	for(QuinceObjectController * tlo in topLevel)
		[[tlo content]hardSetMediaFileAssociations];
	
	// create flat list
    [self setIndeterminateProgressTask:@"creating flat object list..."];
	for(QuinceObjectController * tlo in topLevel){
		
		QuinceObject * copy = [tlo content];//[[tlo content]copy]; // actually we already have copies (see StripController:TopLevelPlaybackList)
		[copy flatten];
		NSArray * subs = [copy valueForKey:@"subObjects"];
		if([subs count]){
			for(QuinceObject * quince in subs)
				[flat addObject:quince];
		}
		else 
			[flat addObject:copy];
		
		[copy release];
	}
		
	NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:@"start" ascending:YES];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[flat sortUsingDescriptors:descriptors];
	[sd release];
	[tl2 release];
    [self displayProgress:NO];
//	NSLog(@"doc: playbackObjectList: %@", flat);		
	return [flat autorelease];
}
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSMutableArray *)removeDuplicatesInArrayOfQuinceObjectControllers:(NSMutableArray *)controllers{

	NSMutableArray * n = [[[NSMutableArray alloc]init]autorelease];
	NSMutableArray * remove = [[[NSMutableArray alloc]init]autorelease];
	
	BOOL addFlag, involvedFlag;
	
	/* for(QuinceObjectController * q in controllers){
			if ([[q content]isOfType:@"Envelope"]) {
				[controllers removeObject:q];
				return [self removeDuplicatesInArrayOfQuinceObjectControllers:controllers];
			}
		} */
	
	for(QuinceObjectController * q in controllers){
	
		if(![n containsObject:q]){

			if([n count]==0) 
				addFlag = YES;
			else 
				addFlag = NO;
			
			involvedFlag = NO;
			
			for(QuinceObjectController * p in n){
				if([[q content]isSuperOf:[p content]]) {
					[remove addObject:p];
					addFlag = YES;				// mark q for adding
					involvedFlag = YES;
				}	
			}
			
			for(QuinceObjectController * p in n){
			
				if([[p content]isSuperOf:[q content]]){
					addFlag = NO;				// don't add
					involvedFlag = YES;
				}
			}
			
			if(addFlag)
				[n addObject:q];
			
			if([remove count]){
				[n removeObjectsInArray:remove];
				[remove removeAllObjects];
			}
			if(!involvedFlag && !addFlag)
				[n addObject:q];
		}
		
	}
	
	
		
	
	return n;//[n autorelease];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(FunctionGraph *)composeFunctionGraphWithSourceName:(NSString *)sourceName targetName:(NSString *)targetName purpose:(NSString *)purpose name:(NSString *)name{
	
	FunctionGraph * graph = [[FunctionGraph alloc]init];
	[graph setValue:name forKey:@"name"];
	[graph setValue:[self functionNamed:sourceName]forKey:@"source"];

	Function * target =[self functionNamed:targetName];
	[graph setValue:target forKey:@"target"];
	
	[graph setValue:purpose forKey:@"targetPurpose"];
	[[graph valueForKey:@"source"]setDocument:self];
	[[graph valueForKey:@"target"]setDocument:self];
	if([target isKindOfClass:NSClassFromString(@"FunctionGraph")])
		[graph setValue:[NSString stringWithFormat:@"%@.%@", [target valueForKey:@"name"], [target valueForKey:@"targetPath"]] forKey:@"targetPath"];
	else {
		[graph setValue:[target valueForKey:@"name"] forKey:@"targetPath"];
	}

	[graph setDocument:self];
	[self addFunctionToPool:graph];
	return [graph autorelease];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)saveGraph:(FunctionGraph *)graph{

	NSDictionary * dict = [graph xmlDictionary];
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSSystemDomainMask, YES);
	NSString * path = [NSString stringWithFormat:@"%@/quince/FunctionGraphs/%@.plist", [paths lastObject], [graph valueForKey:@"name"]];
	[dict writeToFile:path atomically:NO];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSNumber *)durationOfLongestObjectInPool{

	double candidate, max = 0;
	
	for(QuinceObjectController * mc in objectPool){
		candidate = [[[mc content]valueForKey:@"duration"]doubleValue];
		if(candidate > max)
			max = candidate;
	}
	
	return [NSNumber numberWithDouble:max];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


-(AudioFile * )openNewAudioFile{
	
	AudioFile * af = (AudioFile *)[self newObjectOfClassNamed:@"AudioFile" inPool:NO];
	if([af openFile]){
        [self objectPoolSelectionChanged:nil];
        [self addObjectToObjectPool:af];
    }
	return af;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(DataFile *)openNewDataFile{
	
	DataFile * df = (DataFile *)[self newObjectOfClassNamed:@"DataFile" inPool:YES];
	[df openFile];
	[self objectPoolSelectionChanged:nil];
	return df;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


-(BOOL)areTheseControllersSiblings:(NSArray *)controllers{

	if(![controllers count]>0)return NO;
	if(![controllers count]==1)return YES;
	
	NSString * firstId = [[[[controllers objectAtIndex:0]content]superObject]valueForKey:@"id"];
	
	for(int i=1;i<[controllers count];i++){
		if (![[[[[controllers objectAtIndex:i]content]superObject]valueForKey:@"id"]isEqualToString:firstId]) {
			return NO;
		}
	}
	return YES;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark KVC

-(id)valueForKey:(NSString *)key{
//	NSLog(@"Doc: key: %@", key);
	return [dictionary valueForKey:key];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(id)valueForKeyPath:(NSString *)keyPath{

    if(!keyPath){
        NSLog(@"QuinceDocument: valueForKeyPath: ERROR: no valid keyPath!");
        return nil;
    }
	//NSLog(@"QuinceDocument: valueForKeyPath: keyPath: %@", keyPath);
    if([keyPath isEqualToString:@"objectNodes"]){
		return objectNodes;
	}
	if([keyPath isEqualToString:@"functionPool"])
		return functionPool;
	
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
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark user feedback

-(void) displayProgress:(BOOL) display {
	
	if(display) {

		[[progressBar window] makeKeyAndOrderFront:nil];
		[[progressBar window]display];
		
		if([progressBar isIndeterminate]) {
			[progressBar startAnimation:nil];
			[progressBar displayIfNeeded];
		}		
	}	
	else {
		
		if([progressBar isIndeterminate]) {
			[progressBar stopAnimation:nil];
			[progressBar setIndeterminate:NO];
			[progressBar setUsesThreadedAnimation:NO];
		}
		[[progressBar window] orderOut:nil];
		[self setProgress:0];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) setProgressTask:(NSString *) task {
	
	if([progressBar isIndeterminate]) {
		[progressBar stopAnimation:nil];
		[progressBar setIndeterminate:NO];
		[progressBar setUsesThreadedAnimation:YES];
	}
	[progressLabel setStringValue:task];
	[progressBar setUsesThreadedAnimation:YES];
	[[progressBar window]display];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) setProgress:(float)progress {
//    if(!progress){
//        NSLog(@"DOC: setProgress: invalid progress value!");
//        return;
//    }
//    NSLog(@"DOC: setProgress: %f", progress);
    [self setValue:[NSNumber numberWithFloat:progress] forKey:@"progress"];
	//[progressBar setDoubleValue:progress];
	//[progressBar displayIfNeeded];
} 


/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) setIndeterminateProgressTask:(NSString *) task {
	
	[progressBar setIndeterminate:YES];
	[progressBar setUsesThreadedAnimation:YES];
	[progressLabel setStringValue:task];
	[[progressBar window]display];
} 

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)presentAlertWithText:(NSString *)message{
	NSAlert * alert = [NSAlert alertWithMessageText:message defaultButton:@"OK" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@""];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert layout];
	[alert runModal];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)userSetCursorTime:(NSNumber *)time{
	//NSLog(@"userSetCursorTime %@", time);
	NSAutoreleasePool * cursorPool = [[NSAutoreleasePool alloc]init];
	cursorTime = [time doubleValue];
	[mainController drawCursorForTime:[time doubleValue]];
	//NSLog(@"calling displayTime");
	[self displayTime];
	[cursorPool release];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////



-(void)setCursorTime:(NSNumber *)time{
	if([self isPlaying])
		[self userSetCursorTime:time];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setPlaybackStartTime:(NSNumber *)time{

	[self setValue:time forKey:@"playbackStartTime"];
	[self userSetCursorTime:time];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSNumber *)cursorTime{
	return [NSNumber numberWithFloat:cursorTime];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)displayTime{
	int min, sec, ms;
	double t = cursorTime;
	sec = t;
	ms = (t-sec)*1000;
	min = sec/60;
	sec -= (min*60);
	NSString *minString, *secString, *msString;
	if(min<10) minString = [NSString stringWithFormat:@"0%d", min];
	else minString = [NSString stringWithFormat:@"%d", min];
	if(sec < 10) secString = [NSString stringWithFormat:@"0%d", sec];
	else secString = [NSString stringWithFormat:@"%d", sec];	
	if(ms < 10) msString = [NSString stringWithFormat:@"00%d", ms];
	else if(ms<100) msString = [NSString stringWithFormat:@"0%d", ms];	
	else msString = [NSString stringWithFormat:@"%d", ms];	
	[timeTextField setStringValue:[NSString stringWithFormat:@"%@:%@:%@", minString, secString, msString]];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)updateObjectInspector{
	
	QuinceObject * quince = [objectInspectorController content];
	[objectInspectorController setContent:quince];
}
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)updateFunctionCompatibilityForQuinceObjectController:(QuinceObjectController *)qc{


    NSString * type = [(QuinceObject*)[qc content] type];
    BOOL comp = NO;
    
    //NSLog(@"updating compatibilities...");
    Function * f;
    for(f in functionPool){
        if([self isFunction:f compatibleWithType:type])
            comp = YES;
        else
            comp = NO;
        
        [f setIsCompatible:comp];//] :[NSNumber numberWithBool:comp] forKey:@"compatible"];
        //NSLog(@"%@: compatible With %@: %@", [f valueForKey:@"name"], type, [f valueForKey:@"compatible"]);
        
       //        [functionPoolTable reloadData];
    
       // NSLog(@"%@", [f dictionary]);
    }
    //[functionPoolController rearrangeObjects];
    


}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)isFunction:(Function *)fun compatibleWithType:(NSString *)type{
    
    NSArray * desc = [fun inputDescriptors];
    
    for(NSDictionary * d in desc){
        if([[d valueForKey:@"type"]isEqualToString:type])
            return YES;
    }
    return NO;
}
        
#pragma mark perform functions


/////////////////////////////////////////////////////////////////////////////////////////////////////

-(Function *)functionNamed:(NSString *)name{

	for(Function * fun in functionPool){//[functionPool arrangedObjects]){ // functionPool is an NSArrayController
		if([[fun valueForKey:@"name"]isEqualToString:name])		// unlike objectPool
			return fun;
	}
	return nil;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


-(IBAction)performFunctionWithMenuItem:(id)sender{

	[functionLoader awakeWithFunction:[self functionNamed:[sender title]]];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)performFunctionOnCurrentSelectionWithFunctionName:(NSString *)f{
    
	
	ContainerView * currentView = [mainController activeView];	// get the currently active view
	NSArray * selectedChildViews = [currentView selection];			// get an array containing the selected childViews
	NSMutableArray * selectionControllers = [[NSMutableArray alloc]init];
	QuinceObjectController * superController = [[currentView layerController]valueForKey:@"content"];	// currentView's content controller
	
	for(ChildView * child in selectedChildViews)				// store their contollers in an array
		[selectionControllers addObject:[child controller]];
    
	QuinceObject * mother = [self newObjectOfClassNamed:@"QuinceObject" inPool:NO];	//create an empty Object
	
	for (QuinceObjectController * mc in selectionControllers){			// and add the selection as subobjects
		QuinceObjectController * copy = [self controllerForCopyOfQuinceObjectController:mc inPool:NO];
		[[mother controller] addSubObjectWithController:copy withUpdate:NO];
	}
	
	Function * fun = [self functionNamed:f];		// get the selected function
	[fun reset];
	NSArray * inputDescriptors = [fun inputDescriptors];
	[[inputDescriptors lastObject]setValue:mother forKey:@"object"];	

	[fun performActionWithInputDescriptors:inputDescriptors];		// perform the function,
    
	NSMutableArray * newControllers = [[NSMutableArray alloc]init];
	
	for(QuinceObject * q in [mother valueForKey:@"subObjects"]){
		[newControllers addObject:[q controller]];
	}
	
	[self replaceControllers:selectionControllers withControllers:newControllers inSuperController:superController inView:currentView forFunctionNamed:f];
	
	[selectionControllers release];
	[newControllers release];
	[mother release];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)performFunctionOnCurrentSelectionWithMenuItem:(id)sender{
    [self performFunctionOnCurrentSelectionWithFunctionName:[sender title]];
    return;
	//NSLog(@"performFunctionOnCurrentSelectionWithMenuItem:%@", [sender title]);
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)replaceControllers:(NSArray *)a withControllers:(NSArray *)b inSuperController:(QuinceObjectController *)superController 
				   inView:(ContainerView*)view forFunctionNamed:(NSString*)name{

	[[undoManager prepareWithInvocationTarget:self] replaceControllers:b withControllers:a inSuperController:superController inView:view forFunctionNamed:name];
	[undoManager setActionName:name];
	
	for (QuinceObjectController * mc in a)	
		[superController removeSubObjectWithController:mc withUpdate:NO];
	
	for (QuinceObjectController * mc in b)
		[superController addSubObjectWithController:mc withUpdate:NO];

	[superController update];
	
	for(ContainerView * c in [superController registeredContainerViews])
		[c reload];
	
//    for(ContainerView * c in [superController registeredContainerViews])
//        [c replaceChildViewsForControllers:a withChildViewsForControllers:b];
    
	for(QuinceObjectController * mc in b){
		ChildView * cv = [view childViewWithController:mc];
		[view selectChildView:cv];
	}
	

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)performFunctionNamed:(NSString *)functionName onObject:(QuinceObject *)target{


	Function * fun = [self functionNamed:functionName];
	[fun setValue:target forKey:@"result"];
	[self performFunction:fun withValuesOfObject:target];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)performFunction:(Function *)function withValuesOfObject:(QuinceObject *)target{

	NSArray * inputDescriptors = [function inputDescriptors];
	
	for(NSMutableDictionary * dict in inputDescriptors){
	
		NSString * key = [dict valueForKey:@"purpose"];
		//NSLog(@"feeding function with object:%@ for key:%@", [target valueForKey:key], key);
		[dict setValue:[target valueForKey:key] forKey:@"object"];
	}

	[function performActionWithInputDescriptors:inputDescriptors];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark playback
-(void)play{
	
	if(player){
		if([player isPlaying]){
			[player stop];
			[self setValue:[NSNumber numberWithBool:YES] forKey:@"playbackStopped"];
			[self setValue:[NSNumber numberWithBool:NO] forKey:@"playbackStarted"];
			[self userSetCursorTime:[self valueForKey:@"playbackStartTime"]]; 
						// little dirty this setCursorTime / userSetCursorTime workaround...
			return;
		}
		//[player release];
		//[self setValue:[NSNumber numberWithBool:NO] forKey:@"playbackStopped"];
		//[self setValue:[NSNumber numberWithBool:YES] forKey:@"playbackStarted"];
	}
	
	if(!player){
		NSString * playerName = [playerMenu titleOfSelectedItem];
		player = [[NSClassFromString(playerName) alloc]init];
		[player setDocument:self];
	}
	[player setStartTime:[self valueForKey:@"playbackStartTime"]];//[NSNumber numberWithDouble:cursorTime]];
	[player play];
	[self setValue:[NSNumber numberWithBool:NO] forKey:@"playbackStopped"];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"playbackStarted"];

}
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)togglePlayback:(id)sender{
	[self play];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark other

-(void)interpretKeyPressedInContainerView:(NSString *)s{

    NSString * funName = [functionShortCutController functionNameForKey:s];
    if (funName && ![funName isEqualToString:@"Undefined"]) {
        [self performFunctionOnCurrentSelectionWithFunctionName:funName];
        return;
    }

}


/////////////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)test:(id)sender{

	
	NSNumber * s = [NSNumber numberWithInt:1];
	NSNumber * t = [NSNumber numberWithInt:1];
	
	if([s isEqual:t])
		NSLog(@"YES");
	else 
		NSLog(@"NO");

	[[[self getSingleSelectedObjectController]content]arrayWithValuesForKey:@"start"];
}


@end