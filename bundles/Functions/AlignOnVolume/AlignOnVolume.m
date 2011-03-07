//
//  AlingOnVolume.m
//  MINT
//
//  Created by max on 5/4/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//

#import "AlignOnVolume.h"


@implementation AlignOnVolume


-(void)perform{

	QuinceObject * mother = [self objectForPurpose:@"source"];
	[mother sortChronologically];
	QuinceObject * first = [[mother valueForKey:@"subObjects"]objectAtIndex:0];
	double volume = [[first valueForKey:@"volume"]doubleValue];
	
	for(QuinceObject * quince in [mother valueForKey:@"subObjects"])
		[quince setValue:[NSNumber numberWithDouble:volume] forKey:@"volume"];
	
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
}


@end
