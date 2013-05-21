//
//  Shuffle.m
//  quince
//
//  Created by Maximilian Marcoll on 5/21/13.
//  Copyright (c) 2013 Maximilian Marcoll. All rights reserved.
//

#import "Shuffle.h"

@implementation Shuffle

-(void)perform{
	QuinceObject * mother = [self objectForPurpose:@"source"];
	NSArray * subs = [mother valueForKey:@"subObjects"];
	[mother sortChronologically];
	
	for(int i=0;i<[subs count]-1;i++)
		[[subs objectAtIndex:i+1] setValue:[NSNumber numberWithDouble:[[[subs objectAtIndex:i]end]doubleValue]] forKey:@"start"];
    
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
}



@end
