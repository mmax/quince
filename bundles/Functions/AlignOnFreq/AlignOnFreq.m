//
//  AlignOnFreq.m
//  quince
//
//  Created by max on 7/12/11.
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

#import "AlignOnFreq.h"


@implementation AlignOnFreq

-(void)perform{
    
	QuinceObject * q = [self objectForPurpose:@"source"];
	[q sortChronologically];
	QuinceObject * first = [[q valueForKey:@"subObjects"]objectAtIndex:0];
	double f = [[first valueForKey:@"frequency"]doubleValue];
	
	for(QuinceObject * quince in [q valueForKey:@"subObjects"])
		[quince setValue:[NSNumber numberWithDouble:f] forKey:@"frequency"];
	
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
}


@end
