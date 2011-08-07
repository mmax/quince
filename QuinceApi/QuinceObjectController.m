//
//  QuinceObjectController.m
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

#import "QuinceObjectController.h"


@implementation QuinceObjectController

@synthesize node, document;//, childView;

-(QuinceObjectController *)initWithContent:(id)content{
	if((self = [super initWithContent:content])) {
		[self setNode:[[NSTreeNode alloc] initWithRepresentedObject:self]];
		registeredContainerViews = [[NSMutableSet alloc]init];
		registeredChildViews = [[NSMutableSet alloc]init];
		dictionary = [[NSMutableDictionary alloc]init];
		if(![content valueForKey:@"color"])
			 [self setValue:[NSColor whiteColor] forKey:@"color"];
		else
			[self bind:@"color" toObject:content withKeyPath:@"color" options:nil];
	}
	return self;
}

-(void)dealloc{
	
	if([self content])
		NSLog(@"QuinceObjectController: [content name: %@] dealloc", [[self content]valueForKey:@"name"]);
	else 
		NSLog(@"QuinceObjectController, no content : dealloc");

	[registeredContainerViews release];
	[registeredChildViews release];
	[[self node]release];
	[dictionary release];
//	[[self content]release];
	[super dealloc];
}


-(void)addSubObjectWithController:(QuinceObjectController *)mc withUpdate:(BOOL)b{

	QuinceObject * quince = [mc content];
	QuinceObject * c = [self content];
	//[[node mutableChildNodes]addObject:[mc node]];
	[self addSubNodeForQuinceObject:quince];
	[c addSubObject:quince withUpdate:b];
}


-(void)addSubNodesForFoldedController:(QuinceObjectController *)mc{
	
	QuinceObject * quince = [mc content];
	if(![quince isFolded]) return;
	
	for(QuinceObject * m in [quince valueForKey:@"subObjects"]){
		[mc addSubNodeForQuinceObject:m];
	}
	
}

-(void)removeSubObjectWithController:(QuinceObjectController *)mc withUpdate:(BOOL)b{
	QuinceObject * quince = [mc content];
	QuinceObject * c = [self content];
	[[node mutableChildNodes]removeObject:[mc node]];
	[c removeSubObject:quince withUpdate:b];
}

-(void)removeSubObjects{

	NSArray * subObjects = [NSArray arrayWithArray:[[self content] valueForKey:@"subObjects"]];
	for(QuinceObject * q in subObjects)
		[self removeSubObjectWithController:[q controller] withUpdate:NO];
	
	[self update];
}


-(void)addSubNodeForQuinceObject:(QuinceObject *)quince{
	[document willChangeValueForKey:@"objectNodes"]; // not sure why i have to do this...
	[[node mutableChildNodes]addObject:[[quince controller]node]];
	[document didChangeValueForKey:@"objectNodes"];
}

-(NSArray *)controllersForSubObjects{

	NSMutableArray * sc = [[NSMutableArray alloc]init];
	for(QuinceObject * m in [[self content] valueForKey:@"subObjects"])
		[sc addObject:[m controller]];
	return [sc autorelease];
}

-(void)update{
	[[self content]update];
}

-(QuinceObjectController* )foldControllers:(NSArray *)subControllers{

	NSMutableArray * subObjects = [[NSMutableArray alloc]init];
	for(QuinceObjectController * mc in subControllers)
		[subObjects addObject:[mc content]];
	QuinceObject * c = [self content];
	QuinceObject * folded = [c foldObjects:subObjects];
	[subObjects release];
	return [folded controller];
}


-(void)foldChildViews:(NSArray *)childViews inView:(ContainerView *)sourceView{

	NSMutableArray * controllers = [[NSMutableArray alloc]init];
	for(ChildView * c in childViews){
		[c unbind:[sourceView keyForLocationOnXAxis]];
		[c unbind:[sourceView keyForLocationOnYAxis]];
		[c unbind:[sourceView keyForSizeOnXAxis]];
		[c unbind:[sourceView keyForSizeOnYAxis]];
		[c unbind:@"interiorColor"];
	}	 
	for(ChildView * child in childViews)
		[controllers addObject:[child controller]];
	
	QuinceObjectController * foldedController = [self foldControllers:controllers];
	
	for(ContainerView * view in registeredContainerViews)
		[foldedController prepareForDisplayInView:view];
	
	ChildView * folded = [sourceView createChildViewForFoldedController:foldedController andBeginAnimationForChildViews:childViews];
	[[[document undoManager]prepareWithInvocationTarget:self]unfoldChildView:folded inView:sourceView];
	[[document undoManager]setActionName:@"un-/fold"];
	[controllers release];
	
}

-(void)unfoldChildView:(ChildView *)child inView:(ContainerView *)sourceView{

	NSArray * unfoldedSubControllers = [self unfoldController:[child controller]];
	NSArray * children = [sourceView createChildViewsForUnfoldedControllers:unfoldedSubControllers andBeginAnimationForChildView:child];
	[[[document undoManager]prepareWithInvocationTarget:self]foldChildViews:children inView:sourceView];
	[[document undoManager]setActionName:@"un-/fold"];
}

-(void) unfoldChildViews:(NSArray *)childViews inView:(ContainerView *)sourceView{
	for(ChildView * child in childViews)
		[self unfoldChildView: child inView:sourceView];
}

-(NSArray *)unfoldController:(QuinceObjectController *)mc{

	QuinceObject * quince = [mc content];
	QuinceObject * c = [self content];
	NSArray * subObjects = [c unfoldObject:quince];
	
	NSMutableArray * subControllers = [[NSMutableArray alloc]init];
	
	NSMutableArray * offsetKeys = [[NSMutableArray alloc]init];

	for(ContainerView * v in registeredContainerViews){	// don't care about duplicates yet
	
		[offsetKeys addObject:[v keyForLocationOnXAxis]];
		[offsetKeys addObject:[v keyForLocationOnYAxis]];	
	}
	
	for(quince in subObjects){
		
		for(NSString * key in offsetKeys)
			[quince updateOffsetForKey:key];
		
		[subControllers addObject:[quince controller]];
	}
	[offsetKeys release];
	return [subControllers autorelease];
}

-(void)createNewObjectForPoint:(NSPoint)point inView:(ContainerView *)view{
	
	
	NSString * xKey= [view keyForLocationOnXAxis];
	NSString * yKey= [view keyForLocationOnYAxis];

	double offsetXParam = [[self offsetForKey:xKey]doubleValue] + [[self valueForKeyPath:[NSString stringWithFormat:@"selection.%@", xKey]]doubleValue];
	double offsetXLocation = [[view xDeltaForParameterValue:[NSNumber numberWithDouble:offsetXParam]]doubleValue];

	double offsetYParam = [[self offsetForKey:yKey]doubleValue] + [[self valueForKeyPath:[NSString stringWithFormat:@"selection.%@", yKey]]doubleValue];
	double offsetYLocation = [[view yDeltaForParameterValue:[NSNumber numberWithDouble:offsetYParam]]doubleValue];

	//NSLog(@"mother_ offsetXParam: %f", offsetXParam);

	NSPoint location = NSMakePoint(point.x - offsetXLocation, point.y - offsetYLocation);
	//
	QuinceObjectController * c = [document controllerForNewObjectOfClassNamed:[view defaultObjectClassName] inPool:NO];	
	[self addObjectWithController:c inView:view];

	
	[[c content]updateOffsetForKey:xKey];
	[[c content]updateOffsetForKey:yKey];
	
	
	if([view allowsNewSubObjectsToRepresentAudioFiles]){
		AudioFile * audio = [document getCurrentlySelectedAudioFile];
		if(audio)
			[document linkObject:[c content] toAudioFile:audio];
	}	
	
	NSValue * xValue =[view parameterValueForX:[NSNumber numberWithFloat:location.x]];
	NSValue * yValue =[view parameterValueForY:[NSNumber numberWithFloat:location.y]];
	
	[c setValue: xValue forKeyPath:[NSString stringWithFormat:@"selection.%@", xKey]];
	[c setValue: yValue forKeyPath:[NSString stringWithFormat:@"selection.%@", yKey]];
	/* [self addSubObjectWithController:c withUpdate:YES];
		
		[[[document undoManager]prepareWithInvocationTarget:self] removeObjectWithController:c inView: view];
		[[document undoManager]setActionName:@"create SubObject"]; */

	//[self createChildViewsForQuinceObjectController:c];
	
	//NSLog(@"newObject_startOffset: %@", [c offsetForKey:@"start"]);
    
    NSMutableSet * views = [[NSMutableSet alloc]initWithSet:[self registeredContainerViews]];
    [views removeObject:view];
    for(ContainerView * cv in views){
        [cv createChildViewForQuinceObjectController:c];
    }
    
	[[[c content]superObject]update];	
	[c release];
}

-(void)removeObjectWithController:(QuinceObjectController *)mc inView:(ContainerView *)view{
	[[[document undoManager]prepareWithInvocationTarget:self] addObjectWithController:mc inView:view];
	[[document undoManager]setActionName:@"add/remove  SubObject"];
	
    for(ContainerView * c in [self registeredContainerViews]){
        [c removeChildViewForQuinceObjectController:mc];
        
    }
//    [view removeChildViewForQuinceObjectController:mc];

	[self removeSubObjectWithController:mc withUpdate:YES];


}

-(void)addObjectWithController:(QuinceObjectController *)mc inView:(ContainerView *)view{
	[[[document undoManager]prepareWithInvocationTarget:self] removeObjectWithController:mc inView: view];
	[[document undoManager]setActionName:@"add/remove SubObject"];
	[self addSubObjectWithController:mc withUpdate:YES];
	[view createChildViewForQuinceObjectController:mc];
}

-(void)createChildViewsForQuinceObjectController:(QuinceObjectController *)mc{
	[registeredContainerViews makeObjectsPerformSelector:@selector(createChildViewForQuinceObjectController:) withObject:mc];
}

-(void)registerContainerView:(ContainerView *)view{
	//NSLog(@"QuinceObjectController: registering containerView");
	[registeredContainerViews addObject:view];
	//NSLog(@"QuinceObjectController: registering containerView: new # %d", [registeredContainerViews count]);
}

-(void)unregisterContainerView:(ContainerView *)view{
	[registeredContainerViews removeObject:view];
}

-(NSSet *)registeredContainerViews{
	return registeredContainerViews;
}

-(NSNumber *)offsetForKey:(NSString *)key{
	return [[self content] offsetForKey:key];
} 

-(BOOL)isDisplayed{
	return [registeredContainerViews count] > 0 ? YES : NO;
}

-(void)prepareForDisplayInView:(ContainerView *)view{

	NSString * xKey = [view keyForLocationOnXAxis];
	NSString * yKey = [view keyForLocationOnYAxis];
	QuinceObject * content = [self content];
	
	[content updateOffsetForKey:xKey];	
	[content updateOffsetForKey:yKey];	
}

-(QuinceObjectController *)superController{

	return [[[self content]valueForKey:@"superObject"]controller];
}

-(void)initContentWithXMLDictionary:(NSDictionary *)dict{
	
	NSArray * subs = [NSArray arrayWithArray:[dict valueForKey:@"subObjects"]];
	//NSLog(@"before initWithXML...: %d", [subs count]);
	
	[[self content]initWithXMLDictionary:dict];

	//NSLog(@"found %d subObjects", [subs count]);
	//NSLog(@"dictionary: %@", dictionary);
	for(NSDictionary * d in subs){
	//	NSLog(@"QuinceObjectController: creating subObject...");
		QuinceObjectController * mc = [document controllerForNewObjectOfClassNamed:[d valueForKey:@"type"] inPool:NO];
		[mc initContentWithXMLDictionary:d];
		[self addSubObjectWithController:mc withUpdate:NO];
	}
}

-(void)repositionViewsForKey:(NSString *)key{

	NSArray * subs = [[self content]valueForKey:@"subObjects"];
	
	for(QuinceObject * quince in subs){
		[quince willChangeValueForKey:key];
		[quince didChangeValueForKey:key];
	}
	[self update];
	[registeredContainerViews makeObjectsPerformSelector:@selector(updateViewsForCurrentSize)];
}

/* -(id)valueForKey:(NSString *)key{

	NSLog(@"%@: %@", [self className], key);
	return [super valueForKey:key];
} */
/* -(id)valueForKey:(NSString *)key{
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
*/
-(void)setValue:(id)aValue forKey:(NSString *)aKey{
		
	[self willChangeValueForKey:aKey];
	[super setValue:aValue forKey:aKey];
	[self didChangeValueForKey:aKey];
	
	if([aKey isEqualToString:@"color"]){
		//NSLog(@"hier jetzt! - key: %@", aKey);//:containerViews: %@", registeredContainerViews);
		//[registeredContainerViews makeObjectsPerformSelector:@selector(recolorChildren)];
	}
}


-(void)changeColor:(id)sender{
	//NSLog(@"changeColor: %@", sender);
	NSColor * c = [sender color];
	[[self content]setValue:c forKey:@"color"];
	for(ContainerView * mcv in registeredContainerViews)
		[mcv setNeedsDisplay:YES];

}

-(void)sortChronologically{

	[[self content]sortChronologically];
}

-(QuinceObjectController *)controllerOfNextSubObjectAfterController:(QuinceObjectController *)mc{
	
	[self sortChronologically];
	NSArray * subs = [[self content]valueForKey:@"subObjects"];
	
	if(![subs containsObject:[mc content]])
		return nil;
	
	int index = [subs indexOfObject:[mc content]];
	
	if (index < [subs count]-1)
		return [[subs objectAtIndex:index+1]controller];

	return [[subs lastObject]controller];
}

-(QuinceObjectController *)controllerOfPreviousSubObjectBeforeController:(QuinceObjectController *)mc{

	[self sortChronologically];
	NSArray * subs = [[self content]valueForKey:@"subObjects"];
	
	if(![subs containsObject:[mc content]])
		return nil;
	
	int index = [subs indexOfObject:[mc content]];
	
	if(index > 0)
		return [[subs objectAtIndex:index-1]controller];
	
	return [[subs objectAtIndex:0]controller];

}

-(QuinceObjectController *)copyOfController:(QuinceObjectController *)mc withSubObjects:(BOOL)subs addAsSubObject:(BOOL)b{

	QuinceObjectController * qc = [document controllerForCopyOfQuinceObjectController:mc inPool:NO];
	if(b)
		[self addSubObjectWithController:qc withUpdate:YES];

	if(!subs)
		[qc removeSubObjects];
	
	return qc;
}

-(void)migrateSubObjects:(NSArray *)subs toController:(QuinceObjectController*)mc{
	//NSArray * c = [NSArray arrayWithArray:subs];
	double start  = [[[mc content]valueForKey:@"start"]doubleValue] + [[[mc content]offsetForKey:@"start"]doubleValue];
	QuinceObject * quince = [self content];
	NSLog(@"QuinceObjectController:migrateSubObjects. current subObjsctsCount: %d newOwner subCount: %d", [[[self content]valueForKey:@"subObjects"]count], [[[mc content]valueForKey:@"subObjects"]count]);
	for(QuinceObject * q in subs){
		double prevSubStart = [[q valueForKey:@"start"]doubleValue]+[[q offsetForKey:@"start"]doubleValue];
		double newSubStart = prevSubStart - start;

		[self removeSubObjectWithController:[q controller] withUpdate:NO];
		[mc addSubObjectWithController:[q controller] withUpdate:NO];
		NSLog(@"migrating subObject: %@. self subCount: %d, newOwner subCount: %d", [q valueForKey:@"name"], [[[self content]valueForKey:@"subObjects"]count], [[[mc content]valueForKey:@"subObjects"]count]);
		NSLog(@"sub->super->name: %@", [[q superObject]valueForKey:@"name"]);
		[q setValue:[NSNumber numberWithDouble:newSubStart] forKey:@"start"];
	}
	[self update];
	[mc update];
	NSLog(@"%@", quince);
}

-(void) toggleMute{

	if([[[self content]valueForKey:@"muted"]boolValue]){
		[[self content]setValue:[NSNumber numberWithBool:NO] forKey:@"muted"];
		//[registeredChildViews makeObjectsPerformSelector:@selector(unmute)];
	}
	else {
		[[self content]setValue:[NSNumber numberWithBool:YES] forKey:@"muted"];
		//[registeredChildViews makeObjectsPerformSelector:@selector(mute)];
	}

}

-(void)registerChildView:(ChildView *)child{
	if([registeredChildViews containsObject:child])return;
	[registeredChildViews addObject:child];

}

-(void)unregisterChildView:(ChildView *)child{
	[registeredChildViews removeObject:child];
}

-(NSString*)description{

	return [NSString stringWithFormat:@"QuinceObjectController: %@", [[self content]description] ];
}

-(id)changedParameter{

    return [[[document objectInspectorController]selectedObjects]lastObject];
}

-(void)updateObjectInspector{

    [document updateObjectInspector];
}

-(void)createFreqEntry{
    [[self content]createFreqEntry];
}

-(void)createFreqBEntry{
    [[self content]createFreqBEntry];
}

-(void)switchGlissandoDirection{
    [[self content]switchGlissandoDirection];
}

@end
