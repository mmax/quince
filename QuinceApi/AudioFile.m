//
//  MintFile.m
//  MINT
//
//  Created by max on 3/5/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
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
	int index = [comp count] > 2 ? [comp count]-2 : 0;
	[quince setValue:[NSString stringWithFormat:@"%@_%d", [comp objectAtIndex:index], [self getNewLinkedObjectNamePostfixNumber]] forKey:@"name"];
}

-(int)getNewLinkedObjectNamePostfixNumber{

	int max = 0;
	for(QuinceObject * quince in [self valueForKey:@"registeredLinkedObjects"]){
	
		NSArray * comp = [[quince valueForKey:@"name"] componentsSeparatedByString:@"_"];
		int number = [[comp lastObject]integerValue];
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
