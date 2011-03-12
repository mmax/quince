//
//  JoinByFrequency.m
//  quince
//
//  Created by max on 11/18/10.
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

#import "JoinByFrequency.h"


@implementation JoinByFrequency

-(JoinByFrequency *)init{
	
	if(self = [super init]){
		[NSBundle loadNibNamed:@"JoinByFrequencyWindow" owner:self];
		maxCent = 0;
	}
	return self;
}


-(void)perform{
	
	[window makeKeyAndOrderFront:nil];	
}


-(IBAction)cancel:(id)sender{

	[window orderOut:nil];
}

-(IBAction)go:(id)sender{
	[document setIndeterminateProgressTask:@"processing..."];
	[document displayProgress:YES];
	maxCent = [percentageField floatValue];
	mom = [self outputObjectOfType:@"QuinceObject"];
	source = [self objectForPurpose:@"source"];
	[source sortChronologically];
	[self joinNextFrom:0 into:nil];
	NSString * s = [NSString stringWithFormat:@"%@_joined_%d%", [source valueForKey:@"name"], (int)maxCent];
	[mom setValue:s forKey:@"name"];
	[mom update];
	[document displayProgress:NO];
	[window orderOut:nil];
	[self done];
}


-(void)joinNextFrom:(int)index into:(QuinceObject *)j{ // index is the index of the object being joined into
	
	
	if(index >= [[source valueForKey:@"subObjects"]count]-1)
		return;
	
	//NSLog(@"here i am");
	QuinceObject * a;
	
	if(j) a=j;
	else a = [[source valueForKey:@"subObjects"]objectAtIndex:index];
	
	QuinceObject * b = [[source valueForKey:@"subObjects"]objectAtIndex:index+1];

	double freqA = [[a valueForKey:@"frequency"]doubleValue];
	double freqB = [[b valueForKey:@"frequency"]doubleValue];		
	
	float cent = fabs(1200.0 * log2(freqA/freqB)); 
	
	if(cent>maxCent){//no joining
		if(!j) // if we have a j we already copied it onto the new output object
			[[mom controller]addSubObjectWithController:[[a copy]controller] withUpdate:NO];//copy the event as it was
		
		if(index == [[source valueForKey:@"subObjects"]count]-2){ // if b was the last event in the source
			[[mom controller]addSubObjectWithController:[[b copy]controller] withUpdate:NO];//copy the event as it was
			return;																			// and finish
		}
		[self joinNextFrom:index+1 into:nil];//continue with the next subObject

	}
	else{
		double duration = [[b end]doubleValue] - [[a valueForKey:@"start"]doubleValue];
		QuinceObject * a2;
		if(j) a2 = a;
		else a2 = [a copy];
		[a2 setValue:[NSNumber numberWithDouble: duration] forKey:@"duration"];
		if(!j)
			[[mom controller]addSubObjectWithController:[a2 controller] withUpdate:NO];
		
		[self joinNextFrom:index+1 into:a2];
	}
	

}

@end
