//
//  Sum.m
//  quince
//
//  Created by Maximilian Marcoll on 12/08/15.
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
//

#import "Sum.h"

@implementation Sum


// SUM creates a new sequence, containing the sum of all volume values of the source object's subObjects

-(void)perform{
    
	QuinceObject * mum =[(QuinceObject *)[self objectForPurpose:@"source"]copy];
    [mum flatten];
    [mum sortChronologically];
    
    QuinceObjectController * resultController = [[self outputObjectOfType:@"QuinceObject"]controller];

    
	[mum sortChronologically];
	
    NSMutableArray * points = [self getPoints:mum];
    [self createSeqForTimePointsInArray:points fromQuinceObject:mum intoQuinceObject:[resultController content]];
    [self cleanUp:[resultController content]];
        
    [resultController update];
	[resultController setValue:[NSString stringWithFormat:@"%@_∑", [mum valueForKey:@"name"]] forKeyPath:@"selection.name"];

	[self done];
}

-(NSMutableArray *) getPoints:(QuinceObject *)q{
    
    NSMutableArray * p = [[NSMutableArray alloc]init];
    QuinceObject * sub;
    
    NSLog(@"creating points...");
    
    for(sub in [q valueForKey:@"subObjects"]){
        [p addObject:[NSNumber numberWithDouble:[(NSNumber *)[sub valueForKey:@"start"]doubleValue]]];
        [p addObject:[NSNumber numberWithDouble:[(NSNumber *)[sub end]doubleValue]]];
    }

    NSSortDescriptor *asc = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [p sortUsingDescriptors:[NSArray arrayWithObject:asc]];
    NSLog(@"%@",p);
    return [p autorelease];
}

-(void) createSeqForTimePointsInArray: (NSArray *)points fromQuinceObject:(QuinceObject *)m intoQuinceObject:(QuinceObject *)result{
    
    QuinceObject * q = nil;
    long count = [points count];
    NSNumber * n = nil;
    double previousStart;
    int i;
    
    for(i = 0; i < count-1;i++){ //counting to the n-1 because the last "point" is an end!
        
        n = [points objectAtIndex:i];
        
        if(q){
            previousStart = [[q valueForKey:@"start"]doubleValue];
            [q setValue:[NSNumber numberWithDouble:[n doubleValue]-previousStart] forKey:@"duration"];
        }
        
        NSArray * subs = [m subObjectsAtTime:n];
        double sum = [self sumForParameter:@"volume" inArrayOfObjects:subs];
        q = [[document controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];

        [q setValue:[n copy] forKey:@"start"];
        [q setValue:[NSNumber numberWithDouble:sum] forKey:@"volume"];
        [[result controller] addSubObjectWithController:[q controller] withUpdate:NO];//addSubObject:q withUpdate:NO];
    }
    n = [points objectAtIndex:i];                                                                   // since the last "point" is an end,
    previousStart = [[q valueForKey:@"start"]doubleValue];                                          // we need to 
    [q setValue:[NSNumber numberWithDouble:[n doubleValue]-previousStart] forKey:@"duration"];      // adjust the last q's duration
    [result update];
}

-(double) sumForParameter:(NSString *)s inArrayOfObjects:o{
   
    if([s isEqualToString:@"volume"]){
       
        double linSum = 0;
        
        for(QuinceObject * q in o)
            linSum += [self dB2a:[[q valueForKey:@"volume"] doubleValue]];
        
        return [self a2dB:linSum];
    }
    [document presentAlertWithText:@"SUM: NO MATCHING PARAMETER FOUND!"];
    return 0;
}

-(double)a2dB:(double)a{ return 20*log10(a);}
-(double)dB2a:(double)dB{ return pow(10, dB/20.0);}

-(void) cleanUp:(QuinceObject *)q{
    //      join successive objects with same volume level
}


-(BOOL)worksOnSelection{return NO;}
@end
