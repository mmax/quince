//
//  Function.m
//  quince
//
//  Created by max on 3/5/10.
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


#import "Function.h"
#import "QuinceObject.h"
#import "QuinceDocument.h"

@implementation Function

-(Function *)init{

	if((self = [super init])){
		
		dictionary = [[NSMutableDictionary alloc]init];
		[self setValue:[self className] forKey:@"name"];
        [self setIsCompatible:YES];
		//[self setValue:[self inputDescriptors] forKey:@"inputDescriptors"];
		[self reset];
		//addToPool = YES;
	}
	return self;
}


-(void)dealloc{
	//NSLog(@"%@:dealloc", [self className]);	
	[dictionary release];
	[super dealloc];
}

-(id)valueForKey:(NSString *)key{
	//NSLog(@"MintFunction: (%@): valueForKey:%@", [self className], key);
	return [dictionary valueForKey:key];
}

-(void)setValue:(id)value forKey:(NSString *)key{
	//NSLog(@"Function: (%@): setValue: %@ forKey:%@", [self className], value, key);
//	NSLog(@"%@", dictionary);
 //   [self willChangeValueForKey:@"dictionary"];
    [self willChangeValueForKey:key];
	[dictionary setValue:value forKey:key];
    [self didChangeValueForKey:key];
//    [self didChangeValueForKey:@"dictionary"];
}



-(void)setDocument:(QuinceDocument *)doc{
	document = doc;
}

-(NSDictionary *)dictionary{
    return dictionary;
}
-(QuinceDocument *)document{return document;}

-(void)performActionWithInputDescriptors:(NSArray *)inputDescriptors{
	
	
	[self setValue:inputDescriptors forKey:@"inputDescriptors"];
	//NSLog(@"%@: performActionWithInputDescriptors: %@", [self className], inputDescriptors);
	[self perform];
//	[self reset];
}

-(QuinceObject *)objectForPurpose:(NSString *)purpose{

	//NSLog(@"%@: objectForPurpose: inputDescriptors: %@", [self className], [self valueForKey:@"inputDescriptors"]);
	for(NSDictionary * d in [self valueForKey:@"inputDescriptors"]){
		if([[d valueForKey:@"purpose"]isEqualToString:purpose])
			return [d valueForKey:@"object"];
	}
	NSLog(@"ERROR: %@: objectForPurpose: could not find object for purpose: %@ ", [self className], purpose);
	return nil;
}

-(void)reset{
	[self setValue:[self inputDescriptors] forKey:@"inputDescriptors"];
	[self setValue:[NSNumber numberWithBool:NO] forKey:@"_defaults"];
	[dictionary removeObjectForKey:@"result"];
	[dictionary removeObjectForKey:@"output"];
}


-(QuinceObject *)outputObjectOfType:(NSString *)type{
	QuinceObject * quince;
	if([self valueForKey:@"result"]){
		quince = [self valueForKey:@"result"];
		if(![[quince type] isEqualToString:type]){
			[document presentAlertWithText:
			 [NSString stringWithFormat:@"%@: ERROR: given object is of type '%@', expected '%@', creating new!", [self className], [quince type], type]];
		}
		else {
			[self setValue:quince forKey:@"output"];
			return quince;
		}
	}

	quince = [document newObjectOfClassNamed:type inPool:YES]; 
	[self setValue:quince forKey:@"output"];
	return [quince autorelease];
}

-(NSString *)outputType{

	return @"QuinceObject";
}

-(BOOL)typeCheckPurpose:(NSString *)purpose withType:(NSString *)type{

	QuinceObject * quince = [document newObjectOfClassNamed:type];
	NSArray * desc = [self inputDescriptors];
	for(NSDictionary * dict in desc){
	
		if([[dict valueForKey:@"purpose"]isEqualToString:purpose]){
		
			if ([quince isOfType:[dict valueForKey:@"type"]])
				return YES;
			else
				 return NO;
		}
	}
	return NO;
}


-(void)setOutputObjectToObjectWithPurpose:(NSString *)purpose{

	[self setValue:[self objectForPurpose:purpose] forKey:@"output"];
}

-(void)setIsCompatible:(BOOL)b{

    [self setValue:[NSNumber numberWithBool:b] forKey:@"compatible"];
}

-(BOOL)hasInterface{return NO;}


-(void)done{
	[[NSNotificationCenter defaultCenter]postNotificationName:@"functionDone" object:self];
}

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
/////////////// to be implemented by function:

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:[NSString stringWithString:@"source"] forKey:@"purpose"];
	[dictA setValue:[NSString stringWithString:@"QuinceObject"] forKey:@"type"];
	NSMutableArray * ipd = [[NSMutableArray alloc]initWithObjects:dictA, nil];
	[dictA release];
	return [ipd autorelease];
}


-(void)perform{
}

-(BOOL)needsInput{return YES;}	// if a function doesNotNeedInput to operate, 


@end
