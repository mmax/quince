//
//  QuinceObject.h
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


/*
 key: nonStandardReadIn 
 value: BOOL, 
	
	for objects which do not store all their data in the file, 
	but are dependend on other objects to get their data (like an Envelope)
*/

#import <Cocoa/Cocoa.h>

@class ContainerView, QuinceDocument, QuinceObjectController;

@interface QuinceObject : NSObject {

	NSMutableDictionary * dictionary;	// strong
	QuinceDocument * document;			// weak
	QuinceObjectController * controller;	// weak
}

-(QuinceObject *)initWithQuinceObject:(QuinceObject *)quince;
-(QuinceObject *)initWithSubObjects:(NSArray *)subs;
-(QuinceObject *)initWithXMLDictionary:(NSDictionary *)xml;
-(void)setInitialValues;
-(QuinceObject*)copyWithZone:(NSZone *)zone;
-(NSString *)createUUID;


-(QuinceObjectController *)controller;
-(void)setController:(QuinceObjectController *)mc;
-(void)setDocument:(QuinceDocument *)doc;
-(QuinceDocument *)document;
-(long)subObjectsCount;
-(void)setValue:(id)aValue forKey:(NSString *)aKey;
-(void)checkAndUpdateSubsForKey:(NSString *)aKey;
-(id)valueForKey:(NSString *)key;
-(NSValue *)constrainValue:(id)value forKey:(NSString *)key;
-(NSMutableDictionary *)dictionary;
-(BOOL)isOneOfTypesInArray:(NSArray *)typeNames;
-(BOOL)isOfType:(NSString *)name;
-(NSString *)getType;
-(NSString *)type;
-(NSString *)getSuperType;
-(void)addSubObject:(QuinceObject *)quince withUpdate:(BOOL)b;
-(void)removeSubObject:(QuinceObject *)quince withUpdate:(BOOL)b;
-(NSString *)description;
-(BOOL)isFolded;
-(BOOL)isChild;
-(QuinceObject *)foldObjects:(NSArray *)subs;
-(NSArray *)unfoldObject:(QuinceObject *)quince;
-(NSValue *)subObjectsRangeForKey:(NSString *)key;
-(NSNumber *)duration;
-(void)updateDuration;
-(void)update;
-(void)updateOffsetForKey:(NSString *)key;
-(NSNumber *)offsetForKey:(NSString *)key;
-(BOOL)canCreateOffsetForKey:(NSString *)key;
-(NSNumber*) amplitude;

-(void)sortByKey:(NSString *)key ascending:(BOOL)asc;
-(void)sortChronologically;
-(NSNumber *)end;
-(QuinceObject *)mediaFile;
-(NSNumber *)mediaFileStart;
-(void)hardSetMediaFileAssociations;
-(NSArray *)arrayWithValuesForKey:(NSString *)key;

-(NSMutableDictionary *)xmlDictionary;
-(QuinceObject *)objectWithValue:(id)value forKey:(NSString *)key;
-(void)delayStartBy:(double)delay;
-(void)log;
-(BOOL)containsFoldedSubObjects;
-(void)flatten;

-(NSArray *)subObjectKeys;
-(NSArray *)allKeysRecursively;
-(void)recursivelyAddKeysNotIncludedInArray:(NSMutableArray *)keys;
-(void)addKeysNotIncludedInArray:(NSMutableArray *)keys;

-(BOOL)isString:(NSString *)s inArrayOfStrings:(NSArray *)a;
-(NSArray *)allKeys;
-(void)removeObjectForKey:(NSString *)key;
-(void)recursivelyRemoveObjectForKey:(NSString *)key;

-(NSArray *)subObjectsAtTime:(NSNumber *)time;
-(void)splitAtTime:(NSNumber *)time migrateToController:(QuinceObjectController *)mig;
-(NSArray *)frequencyValuesForTime:(NSNumber *)time;
-(NSArray *)amplitudeValuesForTime:(NSNumber *)time;
-(NSArray *)volumeValuesForTime:(NSNumber *)time;
-(NSNumber *)mostIntenseFrequencyForTime:(NSNumber *)time;
-(NSArray *)valuesForKey:(NSString *)key forTime:(NSNumber *)time;

NSInteger compareStrings(NSString * a, NSString * b, void * context);
-(QuinceObject *)superObject;
-(void)setFrequency:(NSNumber *)f withUpdate:(BOOL)b;
-(void)setPitch:(NSNumber *)p withUpdate:(BOOL)b;
-(void)setCent:(NSNumber *)c withUpdate:(BOOL)b;
-(double)mToF:(int)f;
-(int)fToC:(double)f;
-(int)fToM:(double)f;

-(BOOL)isSuperOf:(QuinceObject *)child;

-(BOOL)isEqualTo:(QuinceObject *)q;
-(BOOL)checkObject:(QuinceObject *)q forEqualityWithKeys:(NSArray *)keys;
@end
