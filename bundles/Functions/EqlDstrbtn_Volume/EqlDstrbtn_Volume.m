//
//  EqlDstrbtn_Volume
//  quince
//
//  Created by max on 5/4/10.
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

#import "EqlDstrbtn_Volume.h"


@implementation EqlDstrbtn_Volume


-(void)perform{
	
	QuinceObject * quince, * mother = [self objectForPurpose:@"source"];
	[mother sortByKey:@"volume" ascending:YES];
	
	double max  = -1000, increment, min = [[[[mother valueForKey:@"subObjects"]objectAtIndex:0]valueForKey:@"volume"]doubleValue];
	int i, count = [mother subObjectsCount];
	for(quince in [mother valueForKey:@"subObjects"]){
		if([[quince valueForKey:@"volume"]doubleValue]>max)
			max = [[quince valueForKey:@"volume"]doubleValue];
	}
	
	increment = (max-min) / (count-1);
	
	for(i=0;i<count;i++){
		quince = [[mother valueForKey:@"subObjects"]objectAtIndex:i];
		[quince setValue:[NSNumber numberWithDouble:increment*i+min] forKey:@"volume"];
	}
	
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
}

@end
