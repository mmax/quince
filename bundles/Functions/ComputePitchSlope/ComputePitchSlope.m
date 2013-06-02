//
//  ComputePitchSlope.m
//  quince
//
//  Created by Maximilian Marcoll on 6/2/13.
//  Copyright (c) 2013 Maximilian Marcoll. All rights reserved.
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



#import "ComputePitchSlope.h"

@implementation ComputePitchSlope


-(void)perform{

	QuinceObject * quince = [self objectForPurpose:@"source"];
    
    double dur, s, e, slope;
    
    for(QuinceObject * q in [quince valueForKey:@"subObjects"]){

        slope = 1;
        if([q valueForKey:@"frequencyB"]){
            dur = [[q valueForKey:@"duration"]doubleValue];
            s = [[q valueForKey:@"pitchF"]doubleValue];
            e = [q fToMD:[[q valueForKey:@"frequencyB"]doubleValue]];
            slope = (e-s)/dur;
            if([[q valueForKey:@"glissandoDirection"]intValue] == 0)
                slope *=-1;
        }
        [q setValue:[NSNumber numberWithDouble:slope]forKey:@"pitchSlope"];
    }
    
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];

}


@end
