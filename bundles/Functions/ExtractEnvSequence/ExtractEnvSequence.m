//
//  ExtractEnvSequence.m
//  quince
//
//  Created by max on 4/13/11.
//  Copyright 2011 Maximilian Marcoll. All rights reserved.
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
