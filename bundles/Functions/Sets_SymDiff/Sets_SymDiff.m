//
//  Sets_SymDiff.m
//  quince
//
//  Created by max on 9/3/10.
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

#import "Sets_SymDiff.h"


@implementation Sets_SymDiff

-(void)perform{
	
	QuinceObject * mom = [self outputObjectOfType:@"QuinceObject"];
	QuinceObject * a = [self objectForPurpose:@"a"];
	QuinceObject * b = [self objectForPurpose:@"b"];
	
	for(QuinceObject*q in [a valueForKey:@"subObjects"]){
		
		if(![self isQuince:q inArrayOfQuinces:[b valueForKey:@"subObjects"]])
			[[mom controller]addSubObjectWithController:[document controllerForCopyOfQuinceObjectController:[q controller] inPool:NO] withUpdate:NO];	
	}
	
	for(QuinceObject*q in [b valueForKey:@"subObjects"]){
		
		if(![self isQuince:q inArrayOfQuinces:[a valueForKey:@"subObjects"]])
			[[mom controller]addSubObjectWithController:[document controllerForCopyOfQuinceObjectController:[q controller] inPool:NO] withUpdate:NO];	
	}

	[[mom controller]update];
	[self done];
	
}


-(BOOL) isQuince:(QuinceObject *)q inArrayOfQuinces:(NSArray *)array{

	for(QuinceObject * a in array){
		if([a isEqualTo:q])
			return YES;
	}
	return NO;
}

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"a" forKey:@"purpose"];
	[dictA setValue:@"QuinceObject" forKey:@"type"];
	
	NSMutableDictionary * dictB = [[NSMutableDictionary alloc]init];
	[dictB setValue:@"b" forKey:@"purpose"];
	[dictB setValue:@"QuinceObject" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc ]initWithObjects:dictA, dictB, nil];
	[dictA release];
	[dictB release];
	return [ipd autorelease];
}

@end
