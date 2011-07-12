//
//  EqlDstrbtn_Pitch.m
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

#import "EqlDstrbtn_Pitch.h"


@implementation EqlDstrbtn_Pitch


-(void)perform{
	
	QuinceObject * quince, * mother = [self objectForPurpose:@"source"];
	[mother sortByKey:@"frequency" ascending:YES];
	
	double max  = -1000, incrementCent, min = [[[[mother valueForKey:@"subObjects"]objectAtIndex:0]valueForKey:@"frequency"]doubleValue], f , factor;
	int i, count = [mother subObjectsCount];
	for(quince in [mother valueForKey:@"subObjects"]){
		if([[quince valueForKey:@"frequency"]doubleValue]>max)
			max = [[quince valueForKey:@"frequency"]doubleValue];
	}
	
	incrementCent = 1200 * log2(max/min) / (count-1);
	
	for(i=0;i<count;i++){
		quince = [[mother valueForKey:@"subObjects"]objectAtIndex:i];
        factor = pow(pow(pow(2, 1.0/1200.0), incrementCent), i);
        f = min * factor;
		[quince setValue:[NSNumber numberWithDouble:f] forKey:@"frequency"];
	}
	[mother sortChronologically];
    [mother update];
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
}

@end
