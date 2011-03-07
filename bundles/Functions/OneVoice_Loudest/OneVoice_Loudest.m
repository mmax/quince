//
//  OneVoice_Loudest.m
//  quince
//
//  Created by max on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OneVoice_Loudest.h"


@implementation OneVoice_Loudest


-(void)perform{

	[document presentAlertWithText:@"OneVoice_Loudest will look for Events with identical start times. Overlapping Events will not be affected. Use the Legato Function First to make sure there are no overlapping Events in your Sequence."];
	mom = [self objectForPurpose:@"source"];
	QuinceObject * new = [self outputObjectOfType:@"QuinceObject"];
	[mom sortChronologically];
	
	
	
	double time = -1;
	
	[document setIndeterminateProgressTask:@"reducing..."];
	[document displayProgress:YES];
	while (1) {
		time = [self nextSubTimeAfter:time];
		if(time<0) break;
		//NSLog(@"time: %f", time);
		[[new controller] addSubObjectWithController:[[self loudestQuinceInArray:[self subObjectsStartingAtTime:time]]controller] withUpdate:NO];
	}
	
	[new update];
	NSMutableString * name = [[NSMutableString alloc]initWithString:[mom valueForKey:@"name"]];
	[name appendFormat:@"_OV_L"];
	
	[new setValue:name forKey:@"name"];
	[document displayProgress:NO];
	[self done];
}



-(QuinceObject*)loudestQuinceInArray:(NSArray *)fruit{

	double max = -1000000;
	QuinceObject * m = nil;
	
	for(QuinceObject * q in fruit){
		if([[q valueForKey:@"volume"]doubleValue]>max){
			max = [[q valueForKey:@"volume"]doubleValue];
			m = q;
		}
	}
	return m;
	
}
	

-(NSArray *)subObjectsStartingAtTime:(double)t{
	
	NSArray * subs = [mom valueForKey:@"subObjects"];
	
	NSMutableArray * basket = [[[NSMutableArray alloc]init]autorelease];
	
	for(QuinceObject * q in subs){
	
		if([[q valueForKey:@"start"]doubleValue] == t)
			[basket addObject:q];
	}
	//NSLog(@"subObjectsStartingAtTime: %d objects in basket", [basket count]);
	return basket;
}


-(double)nextSubTimeAfter:(double)t{
	
	NSArray * subs = [mom valueForKey:@"subObjects"];
	for(QuinceObject * s in subs){
	
		if ([[s valueForKey:@"start"]doubleValue]>t)
			return [[s valueForKey:@"start"]doubleValue];
	}
	
	return -1;

}

@end
