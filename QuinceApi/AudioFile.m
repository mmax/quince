//
//  AudioFile.m
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


#import "AudioFile.h"


@implementation AudioFile


-(AudioFile *)init{

	if(self = [super init]){
	
		NSMutableSet * set = [[[NSMutableSet alloc]init]autorelease];
		[self setValue: set forKey:@"registeredLinkedObjects"];
	}
	return self;	   
}


-(void)dealloc{

	for(QuinceObject * quince in [self valueForKey:@"registeredLinkedObjects"])
		[quince removeObjectForKey:@"audioFile"];
	
	[super dealloc];
}

-(NSArray *)fileTypes{
	return [NSArray arrayWithObjects:@"aif", @"aiff", @"aifc", @"wav", @"wave", nil];
}

-(void)registerLinkedObject:(QuinceObject *)quince rename:(BOOL)b{
	NSMutableSet * reg = [self valueForKey:@"registeredLinkedObjects"];
	if ([reg containsObject:quince])
		return;
	
	[reg addObject:quince];
	
	if(!b)return;

	NSArray * comp = [[self valueForKey:@"name"]componentsSeparatedByString:@"."];
	unsigned long index = [comp count] > 2 ? [comp count]-2 : 0;
	[quince setValue:[NSString stringWithFormat:@"%@_%ld", [comp objectAtIndex:index], [self getNewLinkedObjectNamePostfixNumber]] forKey:@"name"];
}

-(long)getNewLinkedObjectNamePostfixNumber{

	long max = 0;
	for(QuinceObject * quince in [self valueForKey:@"registeredLinkedObjects"]){
	
		NSArray * comp = [[quince valueForKey:@"name"] componentsSeparatedByString:@"_"];
		long number = [[comp lastObject]integerValue];
		if(number > max)max = number;
	}
	return max+1;
}

-(void)unregisterLinkedObject:(QuinceObject *)quince{
	NSMutableSet * reg = [self valueForKey:@"registeredLinkedObjects"];
	if (![reg containsObject:quince])
		return;
	[reg removeObject:quince];
//	[self setValue:reg forKey:@"registeredLinkedObjects"];
}

-(NSMutableDictionary *)xmlDictionary{
	NSMutableDictionary * dict = [super xmlDictionary];
	[dict removeObjectForKey:@"registeredLinkedObjects"];
	NSMutableArray * ids = [[NSMutableArray alloc]init];
	for(QuinceObject * quince in [self valueForKey:@"registeredLinkedObjects"])
		[ids addObject:[quince valueForKey:@"id"]];
	[dict setValue:ids forKey:@"registeredLinkedObjectIDS"];
	return dict;

}




-(void)cutAllConnections{

	
}

@end
