//
//  ExtractEnvSequence.m
//  quince
//
//  Created by max on 4/13/11.
//  Copyright 2011 Maximilian Marcoll. All rights reserved.


#import "ExtractEnvSequence.h"


@implementation ExtractEnvSequence


-(void)perform{
	
	QuinceObject * source = [self objectForPurpose:@"source"];
	QuinceObject * result = [self outputObjectOfType:@"QuinceObject"];
	QuinceObject * s;
	
	[source sortChronologically];
	[source update];
	double max, countStart = 0, prevMax=-90, dur;
	NSArray * timePoints = [[self createTimePointsArray] retain];
	NSNumber * n;
	for( n in timePoints){
		
		NSArray * volumes =[source volumeValuesForTime:n];
		if([volumes count]>0)
			max = [self maximumNumberInArray:volumes];
		
		if(max != prevMax){
			dur = [n doubleValue]-countStart;			
			s = [document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
			[s setValue:[NSNumber numberWithDouble:countStart] forKey:@"start"];
			[s setValue:[NSNumber numberWithDouble:prevMax] forKey:@"volume"];
			[s setValue:[NSNumber numberWithDouble:dur] forKey:@"duration"];			

			[[result controller]addSubObjectWithController:[s controller] withUpdate:NO];
	
			prevMax = max;
			countStart = [n doubleValue];
		}
	}
	
	s = [document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
	[s setValue:[NSNumber numberWithDouble:countStart] forKey:@"start"];
	[s setValue:[NSNumber numberWithDouble:prevMax] forKey:@"volume"];		
	
	[[result controller]addSubObjectWithController:[s controller] withUpdate:NO];	
	
	dur = [[[[source valueForKey:@"subObjects"]lastObject] end]doubleValue] - countStart;
	[[[result valueForKey:@"subObjects"]lastObject]setValue:[NSNumber numberWithDouble:dur] forKey:@"duration"];
	
	[[result controller] update];
	[[result controller] setValue:[NSString stringWithFormat:@"%@_EnvSeq", [source valueForKey:@"name"]] forKeyPath:@"selection.name"];
	[timePoints release];
	[self done];
}

-(double)maximumNumberInArray:(NSArray *)array{
	
	double temp, max = [[array lastObject]doubleValue];
	for(NSNumber * n in array){
		temp = [n doubleValue];
		if(temp>max)
			max = temp;
	}
	
	return max;
}


-(NSArray *)createTimePointsArray{

	NSMutableArray * times = [[NSMutableArray alloc]init];
	NSArray *subs = [[self objectForPurpose:@"source"]valueForKey:@"subObjects"];
	
	for(QuinceObject * q in subs){
	
		[times addObject:[q valueForKey:@"start"]];
		[times addObject:[q end]];
	}
	
	[times sortUsingSelector:@selector(compare:)];
	return [times autorelease];
}


@end
