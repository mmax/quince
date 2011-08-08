//
//  OneVoice_Loudest.m
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

#import "OneVoice_Loudest.h"


@implementation OneVoice_Loudest


-(void)perform{

	//[document presentAlertWithText:@"OneVoice_Loudest will look for Events with identical start times. Overlapping Events will not be affected. Use the Legato Function First to make sure there are no overlapping Events in your Sequence."];
	mom = [self objectForPurpose:@"source"];
	QuinceObject * new = [self outputObjectOfType:@"QuinceObject"];
	[mom sortChronologically];
	
	
	
	double time = -1;
	
	[document setProgressTask:@"reducing..."];
	[document displayProgress:YES];
	while (1) {
		time = [self nextSubTimeAfter:time];
		if(time<0) break;
		//NSLog(@"time: %f", time);
        QuinceObjectController *c = [[self loudestQuinceInArray:[self subObjectsStartingAtTime:time]]controller];
        float i = [[mom valueForKey:@"subObjects"]indexOfObject:[c content]];
        float progress = i/[mom subObjectsCount]*100.0;
        [document setProgress:progress];
		[[new controller] addSubObjectWithController:c withUpdate:NO];
	}
	
	[new update];
	NSMutableString * name = [[NSMutableString alloc]initWithString:[mom valueForKey:@"name"]];
	[name appendFormat:@"_OVL"];
	
	[new setValue:name forKey:@"name"];
	[document displayProgress:NO];
	[self done];
}



-(QuinceObject*)loudestQuinceInArray:(NSArray *)fruit{

	//double max = -1000000;
	//QuinceObject * m = nil;
	
    NSSortDescriptor * desc = [NSSortDescriptor sortDescriptorWithKey:@"volume" ascending:YES];
    
    NSArray * sorted = [fruit sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
	
    return [sorted lastObject];
//    for(QuinceObject * q in fruit){
//		if([[q valueForKey:@"volume"]doubleValue]>max){
//			max = [[q valueForKey:@"volume"]doubleValue];
//			m = q;
//		}
//	}
//	return m;
	
}
	

-(NSArray *)subObjectsStartingAtTime:(double)t{
	
	NSArray * subs = [mom valueForKey:@"subObjects"];
	
	NSMutableArray * basket = [[[NSMutableArray alloc]init]autorelease];
	double start;
    
	for(QuinceObject * q in subs){
        start = [[q valueForKey:@"start"]doubleValue];
		if(start == t)
			[basket addObject:q];

        if(start>t)
            break;
	}
	//NSLog(@"subObjectsStartingAtTime: %d objects in basket", [basket count]);
	return basket;
}


-(double)nextSubTimeAfter:(double)t{
	
	NSArray * subs = [mom valueForKey:@"subObjects"];
    double start;
	for(QuinceObject * s in subs){
        start =[[s valueForKey:@"start"]doubleValue];
		if (start>t)
			return start;
	}
	
	return -1;
}

@end
