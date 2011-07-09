//
//  QuinceObject.m
//  quince
//
//  Created by max on 2/19/10.
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


#import "QuinceObject.h"
#import "QuinceDocument.h"

@implementation QuinceObject

#pragma mark initialization methos

-(QuinceObject *)init{
	if((self = [super init])){
		dictionary = [[NSMutableDictionary alloc]init];
		[self setInitialValues];
	}
	return self;
}

-(QuinceObject *)initWithQuinceObject:(QuinceObject *)quince{

	if((self = [super init])){

		dictionary = [[NSMutableDictionary alloc] initWithDictionary:[quince dictionary]];
		[self setValue:[[NSMutableArray alloc]init] forKey:@"subObjects"];
		[self setValue:nil forKey:@"superObject"];

		[self setValue:[self createUUID] forKey:@"id"];
		
		for(QuinceObject *m in [quince valueForKey:@"subObjects"])
			[self addSubObject:[m copyWithZone:nil] withUpdate:NO];
		
		[self update];
	}
	return self;
}

-(NSString *)createUUID{
	CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
	NSString *uuidString = [NSString stringWithString:(NSString*)strRef];
	CFRelease(strRef);
	CFRelease(uuidRef);
	return uuidString;
}

-(QuinceObject *)initWithSubObjects:(NSArray *)subs{
	//NSLog(@"QuinceObject: initWithSubObjects _ unsure about ownership / memory...");
	if((self = [super init])){
		dictionary = [[NSMutableDictionary alloc]init];
		[self setInitialValues];
		//[self setValue:[[NSMutableArray alloc]initWithArray:subs] forKey:@"subObjects"];
		//[self setValue:subs forKey:@"subObjects"];
		
		
		for(QuinceObject * quince in subs){
			//[self addSubObject:quince withUpdate:NO];
			//[controller addSubNodeForQuinceObject:quince];
			//[quince setValue:self forKey:@"superObject"];
			[[self controller]addSubObjectWithController:[quince controller] withUpdate:NO];
		}
		[self update];
	}
	return self;
}

-(QuinceObject *)initWithXMLDictionary:(NSDictionary *)xml{
	//NSLog(@"QuinceObject:initWithXMLDictionary...");
	if((self = [super init])){
		[self setInitialValues];
		dictionary = [[NSMutableDictionary alloc]init];
		[dictionary addEntriesFromDictionary:xml];
		//[self setValue:[[NSMutableArray alloc]init] forKey:@"subObjects"];
		//[[self valueForKey:@"subObjects"]removeAllObjects];// subObjects will be added by the controller!
		//[dictionary removeObjectForKey:@"subObjects"];
		[self setValue:[[[NSMutableArray alloc]init]autorelease] forKey:@"subObjects"];
		//[[dictionary valueForKey:@"subObjects"]removeAllObjects]; 
		
		//dictionary = [[NSMutableDictionary alloc]initWithDictionary:xml];		
		//[self setValue:[self createUUID] forKey:@"id"];
		//[self setValue:[self createSubObjectsFromXMLDictionaries:[xml valueForKey:@"subObjects"]] forKey:@"subObjects"];
		//[self update];	
	}
	return self;

}

-(void)setInitialValues{
	[self setValue:[self getType] forKey:@"type"];
	[self setValue:@"untitled" forKey:@"name"];
	[self setValue:@"_" forKey:@"description"];
	[self setValue:[NSDate date] forKey:@"date"];	
	[self setValue:[NSNumber numberWithDouble:0] forKey:@"duration"];
	[self setValue:[NSNumber numberWithInt:0] forKey:@"start"];
	[self setValue:[NSNumber numberWithInt:0] forKey:@"volume"];
	[self setValue:NO forKey:@"isFolded"];
	NSMutableArray * subs = [[NSMutableArray alloc]init];
	[self setValue:subs forKey:@"subObjects"];
	[subs release];
	[self setValue:nil forKey:@"superObject"];
	
	
	NSMutableArray * offsetKeys = [[NSMutableArray alloc]init];
		[offsetKeys addObject:@"start"];
		[offsetKeys addObject:@"volume"];
		[offsetKeys addObject:@"pitch"];	
		[offsetKeys addObject:@"frequency"];	
	[self setValue:offsetKeys forKey:@"offsetKeys"];
	[offsetKeys release];
	
	[self setValue:[self createUUID] forKey:@"id"];
}

-(QuinceObject*)copyWithZone:(NSZone *)zone{
	//NSLog(@"copy!");
	QuinceObject * copy = [[document controllerForNewObjectOfClassNamed:[self className] inPool:NO]content];
	[copy initWithQuinceObject:self];
	[copy setDocument:document];
	return copy;	
}
 
#pragma mark accessors

-(void)setController:(QuinceObjectController *)mc{

	controller = mc; // weak  reference!
}

-(QuinceObjectController *)controller{
	return controller;
}

-(NSString *)getType{
	return [self className];
}

-(NSString *)type{return [self getType];}

-(NSString *)getSuperType{
	if([[self getType]isEqualToString:@"QuinceObject"])
		return [self getType];
	return [[self superclass]className];
}

-(NSString *)description{
	return [self valueForKey:@"name"];
}

-(NSNumber *)duration{		
	return [self valueForKey:@"duration"];
}

-(NSNumber *)end{
	return [NSNumber numberWithDouble:[[self valueForKey:@"start"] doubleValue] + [[self valueForKey:@"duration"]doubleValue]];
}

-(QuinceObject *)mediaFile{
	NSString * name = [self valueForKey:@"mediaFileName"];
	if(name && [name length]>1 && ![name isEqualToString:@"value"]){ // dirty - when an empty string is entered in the object-inspector, 
																	// "value" is being inserted. don't know why or by whom...
		//NSLog(@"QuinceObject: mediaFileName: found name: %@", name);
		QuinceObject * media = [document objectWithValue:name forKey:@"name"];
		
		if(media) 
			return media;
	}

	if([self valueForKey:@"superObject"])
		return [(QuinceObject *)[self valueForKey:@"superObject"]mediaFile];

	return nil;
}

-(void)setDocument:(QuinceDocument *)doc{
	document = doc; // weak
}

-(QuinceDocument *)document{return document;}

-(NSEnumerator *)keyEnumerator{
	return [dictionary keyEnumerator];
}

-(NSArray *)allKeys{
	return [dictionary allKeys];
}

-(NSMutableDictionary *)xmlDictionary{
	[self sortChronologically];
	NSMutableArray * subs = [[NSMutableArray alloc]init];
	QuinceObject * quince;
	for(quince in [self valueForKey:@"subObjects"])
		[subs addObject:[quince xmlDictionary]];
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
	[dict removeObjectForKey:@"superObject"];
	[dict removeObjectForKey:@"xmlDictionary"];	
	[dict setValue:subs forKey:@"subObjects"];
	if([self valueForKey:@"mediaFile"]){
		[dict setValue:[[self valueForKey:@"mediaFile"]valueForKey:@"id"] forKey:@"mediaFileID"];
		[dict removeObjectForKey:@"mediaFile"];
	}
	//NSLog(@"QuinceObject: xmlDictionary: allKeys %@",[dict allKeys]);
	[subs release];
	return dict;
}

-(NSNumber *)amplitude{

	if(![self valueForKey:@"volume"])
		return [NSNumber numberWithInt:0];

//	20*log10(v);
	

	return [NSNumber numberWithDouble: 	pow(10, [[self valueForKey:@"volume"]doubleValue]/ 20.0)];
	
}

#pragma mark KVC

-(void)setValue:(id)aValue forKey:(NSString *)aKey{
	//NSLog(@"QuinceObject:setValue:forKey:%@", aKey);
	if([aKey isEqualToString:@"dictionary"]){                   // set by ObjectInspector (NSDictionaryController)
		//NSArray * keys = [aValue allKeys];                      // since we don't know if some changed parameters are dependant on one another (like frequency and pitch
        id changedParameter = [controller changedParameter];    // we can not simply copy all values of the dictionary but we have to find the changed parameter and 
       [self setValue:[changedParameter valueForKey:@"value"] forKey:[changedParameter valueForKey:@"key"]]; //set that parameter's value (and dependant parameter's values)
        NSLog(@"changedParameter:%@", changedParameter);        // that's both secure and efficient
      //  for(NSString * dictKey in keys)    // to make sure we have the correct values before changing all the other values...
      //    [self setValue:[aValue valueForKey:dictKey] forKey:dictKey];
        
        [controller updateObjectInspector];
		return;
	}
	
	NSValue * value = [self constrainValue: aValue forKey:aKey];
	
	
	if([aKey isEqualToString:@"frequency"]){
		[self setFrequency:aValue withUpdate:YES];
        [self checkAndUpdateSubsForKey:aKey];
        return;
		//[self setValue:[NSNumber numberWithInt:[self fToM:[aValue doubleValue]]] forKey:@"pitch"];
		//[self setValue:[NSNumber numberWithInt:[self fToC:[aValue doubleValue]]] forKey:@"cent"];
        
	}
	else if([aKey isEqualToString:@"pitch"]){
        [self setPitch:aValue withUpdate:YES];
        [self checkAndUpdateSubsForKey:aKey];
        return;
        //[self setValue:[NSNumber numberWithDouble:[self mToF:[aValue intValue]]] forKey:@"frequency"];
		//[self setValue:[NSNumber numberWithInt:0] forKey:@"cent"];
    }
    else if([aKey isEqualToString:@"cent"]){
        [self setCent:aValue withUpdate:YES];
        [self checkAndUpdateSubsForKey:aKey];
        return;
    }
//	
//        [self willChangeValueForKey:@"frequency"];
//        [self willChangeValueForKey:@"dictionary"];
//        [dictionary setValue:[NSNumber numberWithDouble:[self mToF:[aValue intValue]]] forKey:@"frequency"];
//        [self didChangeValueForKey:@"frequency"];
//        [self didChangeValueForKey:@"dictionary"];
	//}
	/* else if([aKey isEqualToString:@"cent"]){
		int pitch = [[self valueForKey:@"pitch"]intValue];
		double newFreq = [self mToF:pitch]*pow(pow(2, 1/1200), [c intValue]);
		[self setValue:[NSNumber numberWithDouble:newFreq] forKey:@"frequency"];
	} */
	//	[self setCent:aValue withUpdate:YES];

	
	[self willChangeValueForKey:aKey];
	[self willChangeValueForKey:@"dictionary"];
	[dictionary setValue:value forKey:aKey];
	
	[self didChangeValueForKey:aKey];
	[self didChangeValueForKey:@"dictionary"];
	
    [self checkAndUpdateSubsForKey:aKey];
	
}
 
-(void)checkAndUpdateSubsForKey:(NSString *)aKey{
    if([self isFolded] && [self canCreateOffsetForKey:aKey] && [controller isDisplayed]){
        //		NSLog(@"QuinceObject: telling subObjects to updateOffsetForKey:%@", aKey);
		[[self valueForKey:@"subObjects"] makeObjectsPerformSelector:@selector(updateOffsetForKey:) withObject:aKey];
	}
}


-(id)valueForKey:(NSString *)key{
   // NSLog(@"QuinceObject: valueForKey:%@", key);
	if([key isEqualToString:@"dictionary"])
		return [self dictionary];
	else if([key isEqualToString:@"isFolded"])
		return [NSNumber numberWithBool: [self isFolded]];
	if([key isEqualToString:@"object"])
	   return self;
	return [dictionary valueForKey:key];
}

-(id)valueForKeyPath:(NSString *)keyPath{
	NSArray * keys = [keyPath componentsSeparatedByString:@"."];
	id val = self;
	for(NSString * key in keys)
		val = [val valueForKey:key];
	return val;
} 
 
-(void)removeObjectForKey:(NSString *)key{
	[self willChangeValueForKey:key];
	[dictionary removeObjectForKey:key];
	[self didChangeValueForKey:key];
}

-(void)recursivelyRemoveObjectForKey:(NSString *)key{

	if([self subObjectsCount]){
	
		for(QuinceObject * m in [self valueForKey:@"subObjects"])
			[m recursivelyRemoveObjectForKey:key];
	}
	
	[self removeObjectForKey:key];
}

-(long)subObjectsCount{
	return [[self valueForKey:@"subObjects"]count];
} 

-(NSMutableDictionary *)dictionary{
	return dictionary;
}

-(NSValue *)constrainValue:(id)value forKey:(NSString *)key{

	if ([key isEqualToString:@"start"]) {
		if ([value doubleValue]< 0)
			return [NSNumber numberWithInt:0];
	}
	return value;
}

#pragma mark object management

-(void)update{
	
	[self updateDuration];
	
	/* if([self isChild]){
			[[self valueForKey:@"superObject"]update];
		} */
	//[self updateStartOffset];
	//[self setValue:[self startOffset]forKey:@"startOffset"];
}

-(void)updateDuration{
	//NSLog(@"%@: updateLocation", [self valueForKey:@"name"]);
	if([self subObjectsCount]==0)
		return;
	
	double  tempEnd, end=-1, oldDur = [[self duration]doubleValue];
	QuinceObject * quince;
	NSArray * subs  = [self valueForKey:@"subObjects"];
	
	for (quince in subs) {
		tempEnd = [[quince end]doubleValue];
		if(tempEnd > end)
			end = tempEnd;
	}
	
	if(end!=oldDur){
	

		[self setValue:[NSNumber numberWithDouble:end] forKey:@"duration"];
		
		QuinceObject * superObject = [self valueForKey:@"superObject"];
		if(superObject)
			[superObject updateDuration];
	}
	
	[self updateOffsetForKey:@"start"];
}

/* -(void)updateStartOffset{
	[self willChangeValueForKey:@"start"]; 
	[self setValue:[self startOffset] forKey:@"startOffset"];
	[self didChangeValueForKey:@"start"];
	// if the startOffset changes, displaying views should update their "start” values
	// they will ask for "startOffset" themselves accordingly...
} */

-(void)updateOffsetForKey:(NSString *)key{
	
	//NSLog(@"QuinceObject: updateOffsetForKey:%@", key);
	[self willChangeValueForKey:key]; 
	[self setValue:[self offsetForKey:key] forKey:[NSString stringWithFormat:@"%@Offset", key]];
	[self didChangeValueForKey:key];
	// if the offset changes, displaying views should update their <key> values
	// they will ask for "<key>Offset" themselves accordingly...
	[[self valueForKey:@"subObjects"] makeObjectsPerformSelector:@selector(updateOffsetForKey:) withObject:key];
}

-(NSNumber *)offsetForKey:(NSString *)key{

	QuinceObject * superMint = [self valueForKey:@"superObject"];
	if(superMint)
		return [NSNumber numberWithFloat:[[superMint offsetForKey:key]doubleValue] + [[superMint valueForKey:key]doubleValue]];
	else
		return [NSNumber numberWithInt:0];
}

-(NSNumber *)mediaFileStart{

	NSString * fileName =[self valueForKey:@"mediaFileName"];
	QuinceObject * superMint = [self valueForKey:@"superObject"];
	
	if(fileName){ // this quince is directly associated with media file
		NSNumber * afs = [self valueForKey:@"mediaFileStart"];
		if(afs) return afs;
		else return [NSNumber numberWithInt:0];
	}
	if(!fileName && [self valueForKey:@"superObject"])
		return [NSNumber numberWithDouble:[[superMint mediaFileStart]doubleValue] + [[self valueForKey:@"start"]doubleValue]];// [[superMint valueForKey:key]doubleValue]];
	
	return nil;
}

-(BOOL)canCreateOffsetForKey:(NSString *)key{
	
	NSArray * offsetKeys = [self valueForKey:@"offsetKeys"]; // array containing all keys that can be used for offsets
	if([offsetKeys containsObject:key])
		return YES;
	return NO;
}

/* -(NSNumber *)startOffset{

	QuinceObject * superMint = [self valueForKey:@"superObject"];
	
	if(superMint)
		return [NSNumber numberWithFloat:[[superMint startOffset]doubleValue] + [[superMint valueForKey:@"start"]doubleValue]];
	else
		return [NSNumber numberWithInt:0];
}
 */
-(void)sortChronologically{
	[self sortByKey:@"start" ascending:YES];
}

-(void)sortByKey:(NSString *)key ascending:(BOOL)asc{
	
	if ([[self valueForKey:@"subObjects"]count] < 2) return;
	
	NSMutableArray * subs = [self valueForKey:@"subObjects"];
	NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:key ascending:asc];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[subs sortUsingDescriptors:descriptors];
	[sd release];
}


-(BOOL)isFolded{
	return [self subObjectsCount]>0?YES:NO;
}

-(BOOL)isChild{
	return [self valueForKey:@"superObject"] ? YES : NO;
}


-(BOOL)isSuperOf:(QuinceObject *)child{

	if(![self isFolded])return NO;
	if ([child isEqualTo:self])return NO;
	
	for(QuinceObject *q in [self valueForKey:@"subObjects"]){
		if ([q isEqualTo:child] || [q isSuperOf:child]){
			//NSLog(@"QuinceObject: %@ isSuper of %@", self, child);
			return YES;
		}
	}
	
	return NO;
}


-(BOOL)isOneOfTypesInArray:(NSArray *)typeNames{
	
	NSString * name;
	for (name in typeNames) {
		if([self isOfType:name])
			return YES;
	}
	return NO;
}

-(BOOL)isOfType:(NSString *)name{
	return [[self type]isEqualToString:name];	//isKindOfClass:NSClassFromString(name)];
}

-(void)addSubObject:(QuinceObject *)quince withUpdate:(BOOL)b{
	
	[[self valueForKey:@"subObjects"]addObject:quince];
	[quince setValue:self forKey:@"superObject"];
	if(b)[self update];
}

-(void)removeSubObject:(QuinceObject *)quince withUpdate:(BOOL)b{
	if(![[self valueForKey:@"subObjects"]containsObject:quince]){
		NSLog(@"request to remove an object which is not a subObject of this quinceObject instance");
			return; // make sure ‘quince’ really is a subObject!
	}
	[[quince controller] release];
	[[self valueForKey:@"subObjects"]removeObject:quince];
	[quince removeObjectForKey:@"superObject"];

	if(b)[self update];
}

-(QuinceObject *)foldObjects:(NSArray *)subs{

	//QuinceObjectController * foldedController = [document controllerForNewQuinceObjectOfClassNamed:[self className] inPool:NO];
	QuinceObject * folded = [document newObjectOfClassNamed:[self className] inPool:NO];//[foldedController content];
	[folded initWithSubObjects:subs];
	[folded sortChronologically];
	double newStart, start = [[[[folded valueForKey:@"subObjects"] objectAtIndex:0]valueForKey:@"start"]doubleValue];
	
	for(QuinceObject * quince in subs){ 
		newStart = [[quince valueForKey:@"start"]doubleValue] - start;
		[quince setValue:[NSNumber numberWithDouble:newStart] forKey:@"start"];
		if([[self valueForKey:@"subObjects"]containsObject:quince]){// when folding external objects into a new one, 
			[[quince controller]retain];
			[[self controller]removeSubObjectWithController:[quince controller] withUpdate:NO];//the subObjects actually are no subObjects
			
		}
		[quince setValue:folded forKey:@"superObject"];
	}

	[folded setValue:[NSNumber numberWithDouble:start] forKey:@"start"];
	[folded setValue:[NSNumber numberWithInt:0] forKey:@"volume"];
	[folded update];
	[[self controller] addSubObjectWithController:[folded controller] withUpdate:YES];
	return [folded autorelease];	
}

-(NSArray *)unfoldObject:(QuinceObject *)quince{

	if([quince isFolded] == NO)
		return [NSArray arrayWithObject:quince];
	
	double subStart, newStart, start = [[quince valueForKey:@"start"]doubleValue], subVolume, newVolume, volume = [[quince valueForKey:@"volume"]doubleValue];
	NSMutableArray * newSubs = [NSMutableArray array];
	QuinceObject * sub;
	NSArray *subs = [quince valueForKey:@"subObjects"];
	for (sub in subs) {
		subStart = [[sub valueForKey:@"start"]doubleValue];
		newStart = start+subStart;
		[sub setValue:[NSNumber numberWithDouble:newStart] forKey:@"start"];
		subVolume =[[sub valueForKey:@"volume"]doubleValue]; 
		newVolume = volume+subVolume;
		[sub setValue:[NSNumber numberWithDouble:newVolume] forKey:@"volume"];		
		[newSubs addObject:sub];
		[[self controller] addSubObjectWithController:[sub controller] withUpdate:NO];
		[sub setValue:self forKey:@"superObject"];
	}
	
	[[self controller] removeSubObjectWithController:[quince controller] withUpdate:YES];
	
	return newSubs;
}	
 
-(NSValue *)subObjectsRangeForKey:(NSString *)key{

	double min=DBL_MAX, max=DBL_MIN, c;
	QuinceObject * quince;
	NSArray *subs = [self valueForKey:@"subObjects"];
	
	for (quince in subs) {
		c = [[quince valueForKey:key]doubleValue];
		if(c<min)min = c;
		if(c>max)max = c;
	}
	return [NSValue valueWithSize:NSMakeSize(min, max)];
}

-(QuinceObject *)objectWithValue:(id)value forKey:(NSString *)key{

	QuinceObject * quince, * result;

	if([[self valueForKey:key]isEqualTo:value])
		return  self;

	NSArray * subs = [self valueForKey:@"subObjects"];
	
	for(quince in subs){//[self valueForKey:@"subObjects"]){
	
		result = [quince objectWithValue:value forKey:key];
		if (result) 
			return result;
	}
	return nil;
}

-(BOOL)containsFoldedSubObjects{

	for(QuinceObject * sub in [self valueForKey:@"subObjects"]){
		if ([sub isFolded])
			return YES;
	}
	return NO;
}

-(void)flatten{ //not yet working on the controller-level, is it?!!
	for(QuinceObject * sub in [self valueForKey:@"subObjects"]){
		if([sub containsFoldedSubObjects])
			[sub flatten];
		else if([sub isFolded]){
			[self unfoldObject:sub];
			[self flatten]; // now the enumerators are confused, so start a new flatten_call and end this one
			return;
		}
	}
}

-(void) hardSetMediaFileAssociations{

	[self setValue:[self mediaFileStart] forKey:@"mediaFileStart"];
	
	if([self subObjectsCount]>0){
		for(QuinceObject * quince in [self valueForKey:@"subObjects"])
			[quince hardSetMediaFileAssociations];
	}
	
	else if ([self mediaFile])
		[self setValue:[[self mediaFile]valueForKey:@"name"] forKey:@"mediaFileName"];	
		// [self mediaFile] returns super's mediaFile if ‘self’ doesn't have one
}

-(NSArray *)arrayWithValuesForKey:(NSString *)key{

	NSMutableArray * a = [[NSMutableArray alloc]init];
	for(QuinceObject  * quince in [self valueForKey:@"subObjects"]){
		if(![a containsObject:[quince valueForKey:key]])
			[a addObject:[quince valueForKey:key]];
	}
	//NSLog(@"%@", a);
	return [a autorelease];
}

-(NSArray *)subObjectsAtTime:(NSNumber *)time{
	
	NSMutableArray * s = [[NSMutableArray alloc]init];
	double t = [time doubleValue];
	
	for(QuinceObject * m in [self valueForKey:@"subObjects"]){
		
		double start = [[m valueForKey:@"start"]doubleValue]+[[m offsetForKey:@"start"]doubleValue];
		double end = start + [[m valueForKey:@"duration"]doubleValue];
		if (start<=t && t<end)
			[s addObject:m];
	}
	return [s autorelease];
}

-(void)splitAtTime:(NSNumber *)time migrateToController:(QuinceObjectController *)mig{
	
	if(![self superObject]) return;	// can't cut top-level objects
	
	double start, end, cut;
	start = [[self valueForKey:@"start"]doubleValue]+[[self offsetForKey:@"start"]doubleValue];
	end = start+[[self valueForKey:@"duration"]doubleValue];
	cut = [time doubleValue];
	
	if(end <= cut){
		NSLog(@"splitAtTime: start: %f, end: %f, cut:%f, NOTHING TO CUT", start, end, cut);
		return;		// nothing to cut
	}


	NSLog(@"split");

	
	QuinceObjectController * superController = [[self superObject]controller];
	QuinceObjectController * newSplitController = [superController copyOfController:[self controller] withSubObjects:NO addAsSubObject:YES];
	QuinceObject * split = [newSplitController content];
	
	double newDur = cut-start;
	double newSplitDur = end-cut;
	double newSplitStart = cut-[[self offsetForKey:@"start"]doubleValue];//+[[self offsetForKey:@"start"]doubleValue];
	
	[self setValue:[NSNumber numberWithDouble:newDur] forKey:@"duration"];
	[split setValue:[NSNumber numberWithDouble:newSplitDur] forKey:@"duration"];
	[split setValue:[NSNumber numberWithDouble:newSplitStart] forKey:@"start"];
	[split setValue:[NSString stringWithFormat:@"%@_split", [split valueForKey:@"name"]] forKey:@"name"];
	[split updateOffsetForKey:@"start"];
	
	NSMutableArray * subsToMigrate = [[[NSMutableArray alloc]init]autorelease];

	for(QuinceObject * q in [self valueForKey:@"subObjects"]){
		double start = [[q valueForKey:@"start"]doubleValue]+[[q offsetForKey:@"start"]doubleValue];
		if (start >= cut)
			[subsToMigrate addObject:q];
	}
	
	NSLog(@"%u subs to migrate", [subsToMigrate count]);
	
	if([subsToMigrate count]){
		//QuinceObjectController * splitCopy = [superController copyOfController:newSplitController withSubObjects:NO addAsSubObject:NO];
		//[[splitCopy content]setValue:[NSNumber numberWithDouble:0] forKey:@"start"];
		//[[splitCopy content]setValue:[NSString stringWithFormat:@"%@_sub", [[splitCopy content] valueForKey:@"name"]]forKey:@"name"];
		//[newSplitController addSubObjectWithController:splitCopy withUpdate:YES];
		//[[splitCopy content]updateOffsetForKey:@"start"];
		if(mig)
			[[self controller] migrateSubObjects:subsToMigrate toController:mig];
		else
			[[self controller] migrateSubObjects:subsToMigrate toController:newSplitController];
	}
	else if(mig && [self superObject]){
		[[[self superObject]controller]migrateSubObjects:[NSArray arrayWithObject:split] toController:mig];
	}

	
//	NSMutableArray * subsToCut = [[[NSMutableArray alloc]init]autorelease];

	/* for(QuinceObject * q in [self valueForKey:@"subObjects"]){
			double start = [[q valueForKey:@"start"]doubleValue]+[[q offsetForKey:@"start"]doubleValue];
			double end = start + [[q valueForKey:@"duration"]doubleValue];
				if(start<cut && end>cut)
					[q splitAtTime:time migrateToController:newSplitController];
		} */
	NSArray * sot = [self subObjectsAtTime:time];
	int count = [sot count];

	while(count>0){
		NSLog(@"loooop---splittting: count: %d", count);
		[[sot lastObject] splitAtTime:time migrateToController:newSplitController];
		sot = [self subObjectsAtTime:time];
		count = [sot count];
	}

}


-(BOOL)isEqualTo:(QuinceObject *)q{

	
	if(![self checkObject:q forEqualityWithKeys:[self allKeys]] || ![self checkObject:q forEqualityWithKeys:[q allKeys]])
		return NO;
	return YES;
}

-(BOOL)checkObject:(QuinceObject *)q forEqualityWithKeys:(NSArray *)keys{

	for(NSString * key in keys){
		if(![key isEqualToString:@"id"] && ![key isEqualToString:@"superObject"]){
			if(![[self valueForKey:key]isEqualTo:[q valueForKey:key]])
				return NO;
		}
	}
	return YES;
}

#pragma mark utility methods


-(NSArray *)frequencyValuesForTime:(NSNumber *)time{
	
	return [self valuesForKey:@"frequency" forTime:time];
}

-(NSArray *)amplitudeValuesForTime:(NSNumber *)time{
	
	if(![[self valueForKey:@"subObjects"]count])
		return nil;
	
	NSArray * subs = [self subObjectsAtTime:time];
	NSMutableArray * amps = [[NSMutableArray alloc]init];
	for(QuinceObject * m in subs){
		if([m amplitude])
			[amps addObject:[m amplitude]];
	}
	return [amps autorelease];
}

-(NSArray *)valuesForKey:(NSString *)key forTime:(NSNumber *)time{
	if(![[self valueForKey:@"subObjects"]count])
		return nil;
	NSArray * subs = [self subObjectsAtTime:time];
	NSMutableArray * values = [[NSMutableArray alloc]init];
	for(QuinceObject * m in subs){
		if([m valueForKey:key])
			[values addObject:[m valueForKey:key]];
	}
	return [values autorelease];	
}

-(NSArray *)volumeValuesForTime:(NSNumber *)time{
	
	return [self valuesForKey:@"volume" forTime:time];
}



-(NSNumber *)mostIntenseFrequencyForTime:(NSNumber *)time{
	
	NSArray * subs = [self subObjectsAtTime:time];
	float max = -1;
	QuinceObject * maxMint;
	for(QuinceObject * m in subs){
		
		if ([[m amplitude]doubleValue]> max) {
			max = [[m amplitude]doubleValue];
			maxMint = m;
		}
	}
	return [maxMint valueForKey:@"frequency"];
}

-(NSArray *)subObjectKeys{

	NSMutableArray * keys = [[NSMutableArray alloc]init];
	for(QuinceObject * quince in [self valueForKey:@"subObjects"]){
		for(NSString * key in [[quince xmlDictionary]allKeys]){
			if(![self isString:key inArrayOfStrings:keys])
				[keys addObject:key];
		}
	}
	return [keys autorelease];
}

-(NSArray *)allKeysRecursively{

	NSMutableArray * keys = [[[NSMutableArray alloc]init]autorelease];
		
	[self recursivelyAddKeysNotIncludedInArray:keys];

	NSArray * sortedArray = [keys sortedArrayUsingFunction:compareStrings context:NULL];
	return sortedArray;
}

-(void)recursivelyAddKeysNotIncludedInArray:(NSMutableArray *)keys{
	if ([self subObjectsCount]) {
		for(QuinceObject * sub in [self valueForKey:@"subObjects"])
			[sub recursivelyAddKeysNotIncludedInArray:keys];
	}
	
	[self addKeysNotIncludedInArray:keys];
}

-(void)addKeysNotIncludedInArray:(NSMutableArray *)keys{

	NSArray * myKeys = [[self xmlDictionary]allKeys];
	
	for(NSString * key in myKeys){
		if (![self isString:key inArrayOfStrings:keys])
			[keys addObject:key];
	}
}

-(BOOL)isString:(NSString *)s inArrayOfStrings:(NSArray *)a{
	for(NSString * c in a){
		if([c isEqualToString:s])
		   return YES;
	}
	return NO;
}

-(void)delayStartBy:(double)delay{
	
	double newStart = [[self valueForKey:@"start"]doubleValue]+delay;
	[self setValue:[NSNumber numberWithDouble:newStart] forKey:@"start"];
}

-(void)log{

	NSLog(@"QuinceObject: log: %@", dictionary);
}

-(QuinceObject *)superObject{

	if([self valueForKey:@"superObject"])
		return [self valueForKey:@"superObject"];
	
	return nil;
}

//(NSComparisonResult)localizedCompare:(NSString *)aString

NSInteger compareStrings(NSString * a, NSString * b, void * context){

	return [a localizedCompare:b];
}

#pragma mark frequency


-(void)setFrequency:(NSNumber *)f withUpdate:(BOOL)b{
    
    if(!b)
        [self willChangeValueForKey:@"dictionary"];

    [self willChangeValueForKey:@"frequency"];
	[dictionary setValue:f forKey:@"frequency"];
    [self didChangeValueForKey:@"frequency"];
		
    if(b) {
		[self setPitch:[NSNumber numberWithInt:[self fToM:[f doubleValue]]] withUpdate:NO];
		[self setCent:[NSNumber numberWithInt:[self fToC:[f doubleValue]]] withUpdate:NO];
	}
    else
        [self didChangeValueForKey:@"dictionary"];
}



-(void)setPitch:(NSNumber *)p withUpdate:(BOOL)b{	
  
    
	if(!b)
        [self willChangeValueForKey:@"dictionary"];

    [self willChangeValueForKey:@"pitch"];
	[dictionary setValue:p forKey:@"pitch"];
	[self didChangeValueForKey:@"pitch"];

	if(b) {
		[self setFrequency:[NSNumber numberWithDouble:[self mToF:[p intValue]]] withUpdate:NO];
		[self setCent:[NSNumber numberWithInt:0] withUpdate:NO];
	}
    
	else
        [self didChangeValueForKey:@"dictionary"];
}	


    
-(void)setCent:(NSNumber *)c withUpdate:(BOOL)b{	

    if(!b)
        [self willChangeValueForKey:@"dictionary"];

    [self willChangeValueForKey:@"cent"];
	[dictionary setValue:c forKey:@"cent"];
    [self didChangeValueForKey:@"cent"];

	    
    if(b){
		int pitch = [[self valueForKey:@"pitch"]intValue];
		double newFreq = [self mToF:pitch]*pow(pow(2, 1/1200), [c intValue]);
		[self setFrequency:[NSNumber numberWithDouble:newFreq] withUpdate:NO];
	}
    else
        [self didChangeValueForKey:@"dictionary"];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(int)fToM:(double)f{
	
	return (f>0)?log2(f/440)*12+69:0;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(int)fToC:(double)f{ 
	
	double fm = [self mToF:[self fToM:f]];
	return 1200*log2(f/fm);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(double)mToF:(int)f{
	
	if(f<=0) return (0);
    else if(f>1499) return [self mToF: 1499];
    else return(pow(2,(f-69)/12.0)*440.0); 
}



#pragma mark finish

-(void)dealloc{
	NSLog(@"QuinceObject: %@ dealloc", [self valueForKey:@"name"]);
	//[[self valueForKey:@"subObjects"]makeObjectsPerformSelector:@selector(release)];
			// really? aren't they released when the array iy released?
	if([self valueForKey:@"mediaFile"])
		[[self valueForKey:@"mediaFile"]unregisterLinkedObject:self];
	
	for(QuinceObject * sub in [self valueForKey:@"subObjects"])
		[sub release];//[[sub controller ]release];
	 	
	[dictionary release];
	[super dealloc];	
}



@end