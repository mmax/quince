//
//  FixGlissandoEndPoints.m
//  quince
//
//  Created by max on 7/18/11.
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


#import "FixGlissandoEndPoints.h"
#import <QuinceApi/QuinceDocument.h>
#import <QuinceApi/QuinceObject.h>


@implementation FixGlissandoEndPoints


-(void)perform{
	
    if(![self checkObjects]){
        [document presentAlertWithText:@"FixGlissandoEndPoints: Error: Unable to perform on input object. Try using LEGATO first."];
        return;
    }
    
	QuinceObject * quinceA, *quinceB, * mother = [self objectForPurpose:@"source"];
	NSArray * subs = [mother valueForKey:@"subObjects"];
    int dirA, dirB;
	double startB, startA;
	
	
	for(int i=0;i<[subs count]-1;i++){
		quinceA = [subs objectAtIndex:i];
        quinceB = [subs objectAtIndex:i+1];
        dirA = [[quinceA valueForKey:@"glissandoDirection"]intValue];
        dirB = [[quinceB valueForKey:@"glissandoDirection"]intValue];
        
        
        if(dirA > 0)
            startA = [[quinceA valueForKey:@"frequency"]doubleValue];
        else
            startA = [[quinceA valueForKey:@"frequencyB"]doubleValue];
        
        if(dirB > 0)
            startB = [[quinceB valueForKey:@"frequency"]doubleValue];
        else
            startB = [[quinceB valueForKey:@"frequencyB"]doubleValue];
        
        //set startFreq:
        [quinceA setValue:[NSNumber  numberWithDouble:startA] forKey:@"frequency"];
        
        // setEndFreq:
        [quinceA setValue:[NSNumber  numberWithDouble:startB] forKey:@"frequencyB"];
        
        // QuinceObject will change direction and values if necessary...
    }
    
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
}


-(BOOL)checkObjects{
    
    QuinceObject * quinceA, *quinceB, * mother = [self objectForPurpose:@"source"];
	NSArray * subs = [mother valueForKey:@"subObjects"];
	double startB, endA;	
	[mother sortChronologically];
    
    for(int i=0;i<[subs count]-1;i++){
        quinceA = [subs objectAtIndex:i];
        quinceB = [subs objectAtIndex:i+1];
		endA = [[quinceA end]doubleValue];
		startB = [[quinceB valueForKey:@"start"]doubleValue];
        if(endA > startB+.001)
            return NO;       
    }
    return YES;
    
}

@end
